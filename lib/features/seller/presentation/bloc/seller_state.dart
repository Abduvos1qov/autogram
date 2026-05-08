import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../payment/domain/entities/billing_cycle.dart';
import '../../domain/entities/seller_profile.dart';
import '../../domain/repositories/seller_repository.dart';

/// Seller BLoC state

enum SellerStatus { initial, loading, loaded, upgrading, upgraded, error }

class SellerState extends Equatable {
  final SellerStatus status;
  final SellerProfile? profile;
  final List<SubscriptionPlanDetails> plans;
  final Failure? failure;

  // Upgrade flow state.
  // Step ordering: 0 = plan picker, 1 = business info (terminal step).
  final SubscriptionPlan? selectedPlan;
  final BillingCycle selectedBillingCycle;
  final BusinessType? selectedBusinessType;
  final String? businessName;
  final String? description;
  final String? address;
  final String? city;
  final List<String> contactPhones;
  final int currentStep;

  const SellerState({
    this.status = SellerStatus.initial,
    this.profile,
    this.plans = const [],
    this.failure,
    this.selectedPlan,
    this.selectedBillingCycle = BillingCycle.monthly,
    this.selectedBusinessType,
    this.businessName,
    this.description,
    this.address,
    this.city,
    this.contactPhones = const [],
    this.currentStep = 0,
  });

  bool get isLoading => status == SellerStatus.loading;
  bool get isUpgrading => status == SellerStatus.upgrading;
  bool get hasError => status == SellerStatus.error;
  bool get isUpgraded => status == SellerStatus.upgraded;
  bool get isSeller => profile != null;

  bool get canProceedToBusinessInfo => selectedPlan != null;
  bool get canCompleteUpgrade =>
      selectedPlan != null &&
      selectedBusinessType != null &&
      businessName != null &&
      businessName!.isNotEmpty;

  SellerState copyWith({
    SellerStatus? status,
    SellerProfile? profile,
    List<SubscriptionPlanDetails>? plans,
    Failure? failure,
    SubscriptionPlan? selectedPlan,
    BillingCycle? selectedBillingCycle,
    BusinessType? selectedBusinessType,
    String? businessName,
    String? description,
    String? address,
    String? city,
    List<String>? contactPhones,
    int? currentStep,
    bool clearFailure = false,
    bool clearProfile = false,
  }) {
    return SellerState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      plans: plans ?? this.plans,
      failure: clearFailure ? null : (failure ?? this.failure),
      selectedPlan: selectedPlan ?? this.selectedPlan,
      selectedBillingCycle: selectedBillingCycle ?? this.selectedBillingCycle,
      selectedBusinessType: selectedBusinessType ?? this.selectedBusinessType,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      contactPhones: contactPhones ?? this.contactPhones,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  /// Resets the upgrade flow fields. Preserves [status], [profile] and [plans]
  /// by default — pass [status] to override (e.g. when called immediately
  /// after a successful upgrade).
  SellerState resetUpgradeFlow({SellerStatus? status}) {
    return SellerState(
      status: status ?? this.status,
      profile: profile,
      plans: plans,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    plans,
    failure,
    selectedPlan,
    selectedBillingCycle,
    selectedBusinessType,
    businessName,
    description,
    address,
    city,
    contactPhones,
    currentStep,
  ];
}
