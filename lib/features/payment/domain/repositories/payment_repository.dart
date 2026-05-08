import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../entities/billing_cycle.dart';
import '../entities/payment.dart';
import '../entities/payment_gateway.dart';
import '../entities/payment_product.dart';
import '../entities/payment_status.dart';

/// Contract for payment persistence and lifecycle operations.
abstract class PaymentRepository {
  Future<Either<Failure, Payment>> createPayment(CreatePaymentParams params);

  Future<Either<Failure, PaymentStatus>> getPaymentStatus(String paymentId);

  /// Long-lived stream — emits updates until the payment reaches a terminal
  /// status. Implementations should close the stream on terminal states.
  Stream<Either<Failure, PaymentStatus>> watchPaymentStatus(String paymentId);

  Future<Either<Failure, List<Payment>>> getUserPayments(String userId);

  Future<Either<Failure, Payment>> cancelPayment(String paymentId);
}

class CreatePaymentParams extends Equatable {
  final PaymentProduct productType;
  final SubscriptionPlan? plan;
  final BillingCycle? billingCycle;
  final int? seatCount;
  final String? boostPackageId;
  final PaymentGateway gateway;
  final int amount;
  final String currency;

  const CreatePaymentParams({
    required this.productType,
    this.plan,
    this.billingCycle,
    this.seatCount,
    this.boostPackageId,
    required this.gateway,
    required this.amount,
    this.currency = 'UZS',
  });

  @override
  List<Object?> get props => [
        productType,
        plan,
        billingCycle,
        seatCount,
        boostPackageId,
        gateway,
        amount,
        currency,
      ];
}
