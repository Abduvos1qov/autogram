import 'package:equatable/equatable.dart';

import '../../../seller/domain/entities/seller_profile.dart';
import 'billing_cycle.dart';
import 'payment_gateway.dart';
import 'payment_product.dart';
import 'payment_status.dart';

/// A payment transaction in Autogram.
///
/// Amount is stored as an integer in the smallest unit of [currency]
/// (typically UZS som). Subscription payments carry [billingCycle] and [plan];
/// additional-seat payments carry [seatCount]; boost payments carry the boost
/// product id in [productId].
class Payment extends Equatable {
  final String id;
  final String userId;
  final int amount;
  final String currency;
  final PaymentStatus status;
  final PaymentGateway gateway;
  final PaymentProduct productType;
  final String? productId;
  final BillingCycle? billingCycle;
  final int? seatCount;
  final SubscriptionPlan? plan;
  final Map<String, dynamic> metadata;
  final String? checkoutUrl;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Payment({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'UZS',
    required this.status,
    required this.gateway,
    required this.productType,
    this.productId,
    this.billingCycle,
    this.seatCount,
    this.plan,
    this.metadata = const {},
    this.checkoutUrl,
    required this.createdAt,
    this.completedAt,
  });

  Payment copyWith({
    String? id,
    String? userId,
    int? amount,
    String? currency,
    PaymentStatus? status,
    PaymentGateway? gateway,
    PaymentProduct? productType,
    String? productId,
    BillingCycle? billingCycle,
    int? seatCount,
    SubscriptionPlan? plan,
    Map<String, dynamic>? metadata,
    String? checkoutUrl,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      gateway: gateway ?? this.gateway,
      productType: productType ?? this.productType,
      productId: productId ?? this.productId,
      billingCycle: billingCycle ?? this.billingCycle,
      seatCount: seatCount ?? this.seatCount,
      plan: plan ?? this.plan,
      metadata: metadata ?? this.metadata,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        currency,
        status,
        gateway,
        productType,
        productId,
        billingCycle,
        seatCount,
        plan,
        metadata,
        checkoutUrl,
        createdAt,
        completedAt,
      ];
}
