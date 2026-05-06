import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl with RepositoryMixin implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UserProfile>> getProfile() {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getProfile();
    });
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? fullName,
    String? email,
    String? language,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.updateProfile(
        fullName: fullName,
        email: email,
        language: language,
      );
    });
  }

  @override
  Future<Either<Failure, String>> updateAvatar(File imageFile) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.updateAvatar(imageFile);
    });
  }

  @override
  Future<Either<Failure, void>> deleteAccount() {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.deleteAccount();
    });
  }
}
