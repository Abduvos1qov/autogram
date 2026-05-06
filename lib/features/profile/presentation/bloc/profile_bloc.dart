import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateAvatarUseCase _updateAvatarUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UpdateAvatarUseCase updateAvatarUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _updateAvatarUseCase = updateAvatarUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
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
    emit(state.copyWith(status: ProfileStatus.loading, clearFailure: true));

    final result = await _getProfileUseCase(const NoParams());

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
    emit(state.copyWith(status: ProfileStatus.updating, clearFailure: true));

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        fullName: event.fullName,
        email: event.email,
        language: event.language,
      ),
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
    emit(state.copyWith(status: ProfileStatus.updating, clearFailure: true));

    final result = await _updateAvatarUseCase(
      UpdateAvatarParams(event.imageFile),
    );

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
    emit(state.copyWith(status: ProfileStatus.updating, clearFailure: true));

    final result = await _deleteAccountUseCase(const NoParams());

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
      },
    );
  }
}
