import 'package:dartz/dartz.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl with RepositoryMixin implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  PaymentRepositoryImpl({
    required PaymentRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Payment>> createPayment(CreatePaymentParams params) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.createPayment(params);
    });
  }

  @override
  Future<Either<Failure, PaymentStatus>> getPaymentStatus(String paymentId) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getPaymentStatus(paymentId);
    });
  }

  @override
  Stream<Either<Failure, PaymentStatus>> watchPaymentStatus(String paymentId) {
    return _remoteDataSource
        .watchPaymentStatus(paymentId)
        .map<Either<Failure, PaymentStatus>>((status) => Right(status))
        .handleError(
      (Object error) {
        return Left<Failure, PaymentStatus>(
          ErrorHandler.handleException(error),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<Payment>>> getUserPayments(String userId) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getUserPayments(userId);
    });
  }

  @override
  Future<Either<Failure, Payment>> cancelPayment(String paymentId) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.cancelPayment(paymentId);
    });
  }
}
