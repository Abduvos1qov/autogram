import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

/// Profile repository interface

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, UserProfile>> updateProfile({
    String? fullName,
    String? email,
    String? language,
  });
  Future<Either<Failure, String>> updateAvatar(File imageFile);
  Future<Either<Failure, void>> deleteAccount();
}
