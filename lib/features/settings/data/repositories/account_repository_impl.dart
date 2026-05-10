import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl with RepositoryMixin implements AccountRepository {
  final AccountRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AccountRepositoryImpl({
    required AccountRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, void>> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.requestEmailChange(
        newEmail: newEmail,
        currentPassword: currentPassword,
      );
    });
  }

  @override
  Future<Either<Failure, void>> verifyEmailChange({
    required String newEmail,
    required String otp,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.verifyEmailChange(
        newEmail: newEmail,
        otp: otp,
      );
    });
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    });
  }

  @override
  Future<Either<Failure, void>> requestPhoneChange({
    required String newPhone,
    required String currentPassword,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.requestPhoneChange(
        newPhone: newPhone,
        currentPassword: currentPassword,
      );
    });
  }

  @override
  Future<Either<Failure, void>> verifyPhoneChange({
    required String newPhone,
    required String otp,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.verifyPhoneChange(
        newPhone: newPhone,
        otp: otp,
      );
    });
  }
}
