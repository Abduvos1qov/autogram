import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_gateway.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/services/payment_gateway_service.dart';
import 'mock_payment_gateway_service.dart';

/// Click gateway implementation of [PaymentGatewayService].
///
/// Production stub. The real implementation is gated on Supabase Edge
/// Functions (`create-click-payment`, `click-status`) and a Realtime
/// subscription on the `payments` table — see Phase 6 of the payment
/// rollout. Until those land, every call delegates to
/// [MockPaymentGatewayService] so the rest of the app (Bloc, WebView,
/// success screen) can be exercised end-to-end during development.
class ClickPaymentGatewayServiceImpl implements PaymentGatewayService {
  // ignore: unused_field
  final SupabaseClient _supabaseClient;
  final MockPaymentGatewayService _mockFallback;

  ClickPaymentGatewayServiceImpl({
    required SupabaseClient supabaseClient,
    required MockPaymentGatewayService mockFallback,
  })  : _supabaseClient = supabaseClient,
        _mockFallback = mockFallback;

  @override
  PaymentGateway get gateway => PaymentGateway.click;

  @override
  Future<Either<Failure, String>> getCheckoutUrl(Payment payment) async {
    // TODO(backend): Call Supabase Edge Function 'create-click-payment'.
    //   Request:  { payment_id, amount, currency, return_url }
    //   Response: { checkout_url, click_transaction_id }
    //   On error map to ServerFailure with the upstream message.
    AppLogger.warning(
      'ClickPaymentGatewayServiceImpl.getCheckoutUrl is not implemented. '
      'Falling back to mock for payment ${payment.id}.',
    );
    return _mockFallback.getCheckoutUrl(payment);
  }

  @override
  Future<Either<Failure, PaymentStatus>> getStatus(String paymentId) async {
    // TODO(backend): Either call Edge Function 'click-status' or read the
    // `payments` row directly via supabaseClient.from('payments')
    //   .select('status').eq('id', paymentId).single() and map with
    //   PaymentStatus.fromString.
    AppLogger.warning(
      'ClickPaymentGatewayServiceImpl.getStatus is not implemented. '
      'Falling back to mock for $paymentId.',
    );
    return _mockFallback.getStatus(paymentId);
  }

  @override
  Stream<Either<Failure, PaymentStatus>> watchStatus(String paymentId) {
    // TODO(backend): Subscribe via supabaseClient
    //   .channel('payments:id=eq.$paymentId')
    //   .onPostgresChanges(...) and emit PaymentStatus.fromString(row.status).
    //   Alternative: poll the Edge Function every 2s with backoff.
    AppLogger.warning(
      'ClickPaymentGatewayServiceImpl.watchStatus is not implemented. '
      'Falling back to mock for $paymentId.',
    );
    return _mockFallback.watchStatus(paymentId);
  }
}
