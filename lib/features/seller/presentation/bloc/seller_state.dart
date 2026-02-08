import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/seller_profile.dart';
import '../../domain/repositories/seller_repository.dart';

/// Seller BLoC state

enum SellerStatus {
  initial,
  loading,
  loaded,
  upgrading,
  upgraded,
  error,
}

class SellerState extends Equatable {
  final SellerStatus status;
  final SellerProfile? profile;
  final List<SubscriptionPlanDetails> plans;
  final Failure? failure;

  // Upgrade flow state
  final BusinessType? selectedBusinessType;
  final String? businessName;
  final String? description;
  final String? address;
  final String? city;
  final List<String> contactPhones;
  final SubscriptionPlan? selectedPlan;
  final int currentStep;

  const SellerState({
    this.status = SellerStatus.initial,
    this.profile,
    this.plans = const [],
    this.failure,
    this.selectedBusinessType,
    this.businessName,
    this.description,
    this.address,
    this.city,
    this.contactPhones = const [],
    this.selectedPlan,
    this.currentStep = 0,
  });

  bool get isLoading => status == SellerStatus.loading;
  bool get isUpgrading => status == SellerStatus.upgrading;
  bool get hasError => status == SellerStatus.error;
  bool get isUpgraded => status == SellerStatus.upgraded;
  bool get isSeller => profile != null;

  bool get canProceedToBusinessInfo => selectedBusinessType != null;
  bool get canProceedToPlanSelection =>
      businessName != null && businessName!.isNotEmpty;
  bool get canCompleteUpgrade =>
      selectedBusinessType != null &&
      businessName != null &&
      businessName!.isNotEmpty;

  SellerState copyWith({
    SellerStatus? status,
    SellerProfile? profile,
    List<SubscriptionPlanDetails>? plans,
    Failure? failure,
    BusinessType? selectedBusinessType,
    String? businessName,
    String? description,
    String? address,
    String? city,
    List<String>? contactPhones,
    SubscriptionPlan? selectedPlan,
    int? currentStep,
    bool clearFailure = false,
    bool clearProfile = false,
  }) {
    return SellerState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      plans: plans ?? this.plans,
      failure: clearFailure ? null : (failure ?? this.failure),
      selectedBusinessType: selectedBusinessType ?? this.selectedBusinessType,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      contactPhones: contactPhones ?? this.contactPhones,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  SellerState resetUpgradeFlow() {
    return SellerState(
      status: status,
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
        selectedBusinessType,
        businessName,
        description,
        address,
        city,
        contactPhones,
        selectedPlan,
        currentStep,
      ];
}
