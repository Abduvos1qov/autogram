import 'package:equatable/equatable.dart';

import '../../../payment/domain/entities/billing_cycle.dart';
import '../../domain/entities/seller_profile.dart';

/// Seller BLoC events

abstract class SellerEvent extends Equatable {
  const SellerEvent();

  @override
  List<Object?> get props => [];
}

/// Load seller profile
class SellerProfileLoadRequested extends SellerEvent {
  const SellerProfileLoadRequested();
}

/// Update business info — collected on the BusinessInfoScreen.
///
/// [businessType] is now part of the form rather than a dedicated step, so it
/// arrives bundled with the rest of the business fields.
class SellerBusinessInfoUpdated extends SellerEvent {
  final BusinessType businessType;
  final String businessName;
  final String? description;
  final String? address;
  final String? city;
  final List<String>? contactPhones;

  const SellerBusinessInfoUpdated({
    required this.businessType,
    required this.businessName,
    this.description,
    this.address,
    this.city,
    this.contactPhones,
  });

  @override
  List<Object?> get props => [
    businessType,
    businessName,
    description,
    address,
    city,
    contactPhones,
  ];
}

/// Select subscription plan + billing cycle from the upgrade plan-picker.
///
/// The billing cycle is bundled here so the bloc can replay it later when
/// returning from the payment round-trip without the picker being on stack.
class SellerPlanSelected extends SellerEvent {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;

  const SellerPlanSelected(this.plan, this.billingCycle);

  @override
  List<Object?> get props => [plan, billingCycle];
}

/// Complete upgrade to seller
class SellerUpgradeRequested extends SellerEvent {
  const SellerUpgradeRequested();
}

/// Subscribe to plan
class SellerSubscribeRequested extends SellerEvent {
  final SubscriptionPlan plan;

  const SellerSubscribeRequested(this.plan);

  @override
  List<Object?> get props => [plan];
}

/// Cancel subscription
class SellerCancelSubscriptionRequested extends SellerEvent {
  const SellerCancelSubscriptionRequested();
}

/// Load subscription plans
class SellerPlansLoadRequested extends SellerEvent {
  const SellerPlansLoadRequested();
}

/// Upload logo
class SellerLogoUploadRequested extends SellerEvent {
  final String filePath;

  const SellerLogoUploadRequested(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Upload cover
class SellerCoverUploadRequested extends SellerEvent {
  final String filePath;

  const SellerCoverUploadRequested(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Reset upgrade flow
class SellerUpgradeFlowReset extends SellerEvent {
  const SellerUpgradeFlowReset();
}
