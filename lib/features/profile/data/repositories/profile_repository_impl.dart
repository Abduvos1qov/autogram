import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Mock profile repository implementation for test mode
class ProfileRepositoryImpl implements ProfileRepository {
  UserProfile _mockProfile = UserProfile(
    id: 'user-001',
    phone: '+998901234567',
    email: 'test@autogram.uz',
    fullName: 'Test Foydalanuvchi',
    avatarUrl: null,
    role: 'buyer',
    isVerified: true,
    isActive: true,
    language: 'uz',
    sellerProfileId: null,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
  );

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_mockProfile);
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? fullName,
    String? email,
    String? language,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockProfile = _mockProfile.copyWith(
      fullName: fullName,
      email: email,
      language: language,
      updatedAt: DateTime.now(),
    );
    return Right(_mockProfile);
  }

  @override
  Future<Either<Failure, String>> updateAvatar(File imageFile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final avatarUrl = 'https://example.com/avatars/mock-avatar.jpg';
    _mockProfile = _mockProfile.copyWith(avatarUrl: avatarUrl);
    return Right(avatarUrl);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }
}