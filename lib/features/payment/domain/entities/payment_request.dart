import 'package:equatable/equatable.dart';

import '../../../seller/domain/entities/seller_profile.dart';
import 'billing_cycle.dart';
import 'boost_package.dart';
import 'payment_product.dart';

/// Payment intent passed from selection screens to the checkout flow.
///
/// Carries enough product context for the checkout screen to render
/// the order summary without a backend round-trip. Use the named
/// constructors ([PaymentRequest.subscription], [PaymentRequest.seats],
/// [PaymentRequest.boost]) so each product type only sets the fields
/// it needs.
class PaymentRequest extends Equatable {
  final PaymentProduct productType;
  final SubscriptionPlan? plan;
  final BillingCycle? billingCycle;
  final int? seatCount;
  final int? unitSeatPrice;
  final BoostPackage? boostPackage;

  const PaymentRequest({
    required this.productType,
    this.plan,
    this.billingCycle,
    this.seatCount,
    this.unitSeatPrice,
    this.boostPackage,
  });

  const PaymentRequest.subscription({
    required SubscriptionPlan plan,
    required BillingCycle billingCycle,
  }) : this(
          productType: PaymentProduct.subscription,
          plan: plan,
          billingCycle: billingCycle,
        );

  const PaymentRequest.seats({
    required SubscriptionPlan plan,
    required int seatCount,
    required int unitSeatPrice,
  }) : this(
          productType: PaymentProduct.additionalSeat,
          plan: plan,
          seatCount: seatCount,
          unitSeatPrice: unitSeatPrice,
        );

  const PaymentRequest.boost({
    required BoostPackage boostPackage,
  }) : this(
          productType: PaymentProduct.boost,
          boostPackage: boostPackage,
        );

  @override
  List<Object?> get props => [
        productType,
        plan,
        billingCycle,
        seatCount,
        unitSeatPrice,
        boostPackage,
      ];
}
