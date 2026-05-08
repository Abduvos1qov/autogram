import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_gateway.dart';
import '../../domain/entities/payment_product.dart';
import '../../domain/entities/payment_status.dart';

/// Data model for [Payment]. Persisted as a row in the Supabase
/// `payments` table; carries hand-written `fromJson` / `toJson` so we
/// stay tolerant of missing or unexpected backend fields.
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.amount,
    super.currency,
    required super.status,
    required super.gateway,
    required super.productType,
    super.productId,
    super.billingCycle,
    super.seatCount,
    super.plan,
    super.metadata,
    super.checkoutUrl,
    required super.createdAt,
    super.completedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final billingCycleRaw = json['billing_cycle'] as String?;
    final planRaw = json['plan'] as String?;
    final metadataRaw = json['metadata'];

    return PaymentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'UZS',
      status: PaymentStatus.fromString(json['status'] as String? ?? 'pending'),
      gateway: PaymentGateway.fromString(json['gateway'] as String? ?? 'click'),
      productType: PaymentProduct.fromString(
        json['product_type'] as String? ?? 'subscription',
      ),
      productId: json['product_id'] as String?,
      billingCycle: billingCycleRaw != null
          ? BillingCycle.fromString(billingCycleRaw)
          : null,
      seatCount: (json['seat_count'] as num?)?.toInt(),
      plan: planRaw != null ? SubscriptionPlan.fromString(planRaw) : null,
      metadata: metadataRaw is Map
          ? Map<String, dynamic>.from(metadataRaw)
          : const {},
      checkoutUrl: json['checkout_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'status': status.value,
      'gateway': gateway.value,
      'product_type': productType.value,
      'product_id': productId,
      'billing_cycle': billingCycle?.value,
      'seat_count': seatCount,
      'plan': plan?.name,
      'metadata': metadata,
      'checkout_url': checkoutUrl,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory PaymentModel.fromEntity(Payment entity) {
    return PaymentModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      gateway: entity.gateway,
      productType: entity.productType,
      productId: entity.productId,
      billingCycle: entity.billingCycle,
      seatCount: entity.seatCount,
      plan: entity.plan,
      metadata: entity.metadata,
      checkoutUrl: entity.checkoutUrl,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
    );
  }
}
