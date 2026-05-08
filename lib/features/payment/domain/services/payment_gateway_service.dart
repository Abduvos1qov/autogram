import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../entities/payment_gateway.dart';
import '../entities/payment_status.dart';

/// Per-gateway service contract.
///
/// Each gateway (Click, Payme, Octobank) provides a concrete implementation.
/// The repository implementation routes by [PaymentGateway] to the matching
/// service.
abstract class PaymentGatewayService {
  /// Identifies which gateway this service handles.
  PaymentGateway get gateway;

  /// Returns the hosted checkout URL the WebView should open for [payment].
  Future<Either<Failure, String>> getCheckoutUrl(Payment payment);

  /// One-shot status read.
  Future<Either<Failure, PaymentStatus>> getStatus(String paymentId);

  /// Long-lived status stream — see [PaymentRepository.watchPaymentStatus].
  Stream<Either<Failure, PaymentStatus>> watchStatus(String paymentId);
}
