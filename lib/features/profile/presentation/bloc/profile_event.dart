import 'dart:io';

import 'package:equatable/equatable.dart';

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
  List<Object?> get props => [imageFile.path];
}

class ProfileDeleteRequested extends ProfileEvent {
  const ProfileDeleteRequested();
}
