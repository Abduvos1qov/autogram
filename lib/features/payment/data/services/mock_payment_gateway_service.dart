import 'package:dartz/dartz.dart';

import '../../../../core/config/test_config.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_gateway.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/services/payment_gateway_service.dart';
import '../datasources/payment_remote_datasource.dart';

/// In-memory mock implementation of [PaymentGatewayService].
///
/// Used in test mode and as a development fallback when real gateway
/// (Click / Payme / Octobank) backends are not yet wired. Tracks payment
/// status in a per-instance [Map] keyed by `paymentId` so subsequent
/// status reads return the last simulated value.
///
/// In test mode every status mutation is mirrored into the
/// [PaymentRemoteDataSourceImpl] in-memory store via
/// [PaymentRemoteDataSourceImpl.updateTestPaymentStatus] so polling reads
/// from the data source observe the simulated transitions.
class MockPaymentGatewayService implements PaymentGatewayService {
  final Map<String, PaymentStatus> _statuses = {};

  @override
  PaymentGateway get gateway => PaymentGateway.click;

  @override
  Future<Either<Failure, String>> getCheckoutUrl(Payment payment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final url = 'https://mock.checkout/${payment.id}';
    _statuses[payment.id] = PaymentStatus.processing;
    _syncToDataSource(
      payment.id,
      PaymentStatus.processing,
      checkoutUrl: url,
    );
    return Right(url);
  }

  @override
  Future<Either<Failure, PaymentStatus>> getStatus(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final status = _statuses[paymentId] ?? PaymentStatus.pending;
    return Right(status);
  }

  @override
  Stream<Either<Failure, PaymentStatus>> watchStatus(String paymentId) async* {
    yield Right(_statuses[paymentId] ?? PaymentStatus.processing);
    await Future.delayed(const Duration(seconds: 5));
    _statuses[paymentId] = PaymentStatus.success;
    _syncToDataSource(paymentId, PaymentStatus.success);
    yield const Right(PaymentStatus.success);
  }

  /// Test/debug helper — force a payment into [PaymentStatus.failed].
  void simulateFailure(String paymentId) {
    _statuses[paymentId] = PaymentStatus.failed;
    _syncToDataSource(paymentId, PaymentStatus.failed);
  }

  /// Test/debug helper — force a payment into [PaymentStatus.cancelled].
  void simulateCancellation(String paymentId) {
    _statuses[paymentId] = PaymentStatus.cancelled;
    _syncToDataSource(paymentId, PaymentStatus.cancelled);
  }

  /// Mirrors the in-memory mock state into the data source's test store so
  /// the rest of the stack (repository polling, bloc) sees the same value.
  /// No-op outside test mode — production gateways update the real
  /// `payments` table via webhooks.
  void _syncToDataSource(
    String paymentId,
    PaymentStatus status, {
    String? checkoutUrl,
  }) {
    if (!TestConfig.isTestMode) return;
    PaymentRemoteDataSourceImpl.updateTestPaymentStatus(
      paymentId,
      status,
      checkoutUrl: checkoutUrl,
    );
  }
}
