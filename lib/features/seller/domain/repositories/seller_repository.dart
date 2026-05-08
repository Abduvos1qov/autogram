import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/seller_profile.dart';

/// Seller repository interface

abstract class SellerRepository {
  /// Get current user's seller profile
  Future<Either<Failure, SellerProfile?>> getSellerProfile();

  /// Create seller profile (upgrade to seller)
  Future<Either<Failure, SellerProfile>> createSellerProfile({
    required String businessName,
    required BusinessType businessType,
    String? description,
    String? address,
    String? city,
    List<String>? contactPhones,
  });

  /// Update seller profile
  Future<Either<Failure, SellerProfile>> updateSellerProfile({
    String? businessName,
    BusinessType? businessType,
    String? description,
    String? logoUrl,
    String? coverUrl,
    String? address,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    List<String>? contactPhones,
    String? telegram,
    String? instagram,
    String? website,
    Map<String, WorkingHours>? workingHours,
  });

  /// Get subscription plans
  Future<Either<Failure, List<SubscriptionPlanDetails>>> getSubscriptionPlans();

  /// Subscribe to a plan
  Future<Either<Failure, SellerProfile>> subscribeToPlan(SubscriptionPlan plan);

  /// Cancel subscription
  Future<Either<Failure, SellerProfile>> cancelSubscription();

  /// Upload seller logo
  Future<Either<Failure, String>> uploadLogo(String filePath);

  /// Upload seller cover
  Future<Either<Failure, String>> uploadCover(String filePath);

  /// Check if user can become seller
  Future<Either<Failure, bool>> canBecomeASeller();
}

class SubscriptionPlanDetails extends Equatable {
  final SubscriptionPlan plan;
  final String name;
  final String description;
  final int monthlyPrice;
  final int yearlyPrice;
  final int maxListings;
  final int seatsLimit;
  final int additionalSeatPrice;
  final bool hasVerifiedBadge;
  final String analyticsLevel;
  final bool hasPersonalManager;
  final bool hasApiAccess;
  final bool hasMultiBranch;
  final String audienceLabel;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlanDetails({
    required this.plan,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.maxListings,
    required this.seatsLimit,
    required this.additionalSeatPrice,
    required this.hasVerifiedBadge,
    required this.analyticsLevel,
    required this.hasPersonalManager,
    required this.hasApiAccess,
    required this.hasMultiBranch,
    required this.audienceLabel,
    required this.features,
    this.isPopular = false,
  });

  @override
  List<Object?> get props => [
        plan,
        name,
        description,
        monthlyPrice,
        yearlyPrice,
        maxListings,
        seatsLimit,
        additionalSeatPrice,
        hasVerifiedBadge,
        analyticsLevel,
        hasPersonalManager,
        hasApiAccess,
        hasMultiBranch,
        audienceLabel,
        features,
        isPopular,
      ];
}
