import 'package:equatable/equatable.dart';

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

/// Select business type
class SellerBusinessTypeSelected extends SellerEvent {
  final BusinessType type;

  const SellerBusinessTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

/// Update business info
class SellerBusinessInfoUpdated extends SellerEvent {
  final String businessName;
  final String? description;
  final String? address;
  final String? city;
  final List<String>? contactPhones;

  const SellerBusinessInfoUpdated({
    required this.businessName,
    this.description,
    this.address,
    this.city,
    this.contactPhones,
  });

  @override
  List<Object?> get props => [
        businessName,
        description,
        address,
        city,
        contactPhones,
      ];
}

/// Select subscription plan
class SellerPlanSelected extends SellerEvent {
  final SubscriptionPlan plan;

  const SellerPlanSelected(this.plan);

  @override
  List<Object?> get props => [plan];
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
