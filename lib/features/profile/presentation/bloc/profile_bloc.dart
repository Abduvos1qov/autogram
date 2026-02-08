import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

// Events
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? fullName;
  final String? email;
  final String? language;

  const ProfileUpdateRequested({
    this.fullName,
    this.email,
    this.language,
  });

  @override
  List<Object?> get props => [fullName, email, language];
}

class ProfileAvatarUpdateRequested extends ProfileEvent {
  final File imageFile;
  const ProfileAvatarUpdateRequested(this.imageFile);
  @override
  List<Object?> get props => [imageFile];
}

class ProfileDeleteRequested extends ProfileEvent {
  const ProfileDeleteRequested();
}

// State
enum ProfileStatus { initial, loading, loaded, updating, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final Failure? failure;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.failure,
  });

  bool get isLoading => status == ProfileStatus.loading;
  bool get isUpdating => status == ProfileStatus.updating;
  bool get hasError => status == ProfileStatus.error;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    Failure? failure,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, profile, failure];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileAvatarUpdateRequested>(_onAvatarUpdateRequested);
    on<ProfileDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Loading profile');
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await _repository.getProfile();

    result.fold(
      (failure) {
        AppLogger.error('Failed to load profile: ${failure.message}');
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
      },
      (profile) {
        AppLogger.info('Profile loaded: ${profile.fullName}');
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
        ));
      },
    );
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Updating profile');
    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await _repository.updateProfile(
      fullName: event.fullName,
      email: event.email,
      language: event.language,
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to update profile: ${failure.message}');
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
      },
      (profile) {
        AppLogger.info('Profile updated');
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
        ));
      },
    );
  }

  Future<void> _onAvatarUpdateRequested(
    ProfileAvatarUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Updating avatar');
    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await _repository.updateAvatar(event.imageFile);

    result.fold(
      (failure) {
        AppLogger.error('Failed to update avatar: ${failure.message}');
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
      },
      (avatarUrl) {
        AppLogger.info('Avatar updated');
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          profile: state.profile?.copyWith(avatarUrl: avatarUrl),
        ));
      },
    );
  }

  Future<void> _onDeleteRequested(
    ProfileDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.info('Deleting account');
    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await _repository.deleteAccount();

    result.fold(
      (failure) {
        AppLogger.error('Failed to delete account: ${failure.message}');
        emit(state.copyWith(
          status: ProfileStatus.error,
          failure: failure,
        ));
      },
      (_) {
        AppLogger.info('Account deleted');
        // Auth bloc will handle logout
      },
    );
  }
}
