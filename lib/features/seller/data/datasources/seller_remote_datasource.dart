import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../../../../core/utils/logger.dart';
import '../../domain/entities/seller_profile.dart';
import '../../domain/repositories/seller_repository.dart';
import '../models/seller_profile_model.dart';

/// Seller remote data source

abstract class SellerRemoteDataSource {
  Future<SellerProfileModel?> getSellerProfile();
  Future<SellerProfileModel> createSellerProfile({
    required String businessName,
    required BusinessType businessType,
    String? description,
    String? address,
    String? city,
    List<String>? contactPhones,
  });
  Future<SellerProfileModel> updateSellerProfile(Map<String, dynamic> updates);
  Future<List<SubscriptionPlanDetails>> getSubscriptionPlans();
  Future<SellerProfileModel> subscribeToPlan(SubscriptionPlan plan);
  Future<SellerProfileModel> cancelSubscription();
  Future<String> uploadLogo(String filePath);
  Future<String> uploadCover(String filePath);
  Future<bool> canBecomeASeller();
}

class SellerRemoteDataSourceImpl implements SellerRemoteDataSource {
  final supabase.SupabaseClient _supabase;

  SellerRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<SellerProfileModel?> getSellerProfile() async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Getting seller profile');
      await Future.delayed(const Duration(milliseconds: 400));
      final mock = MockData.currentSellerProfile;
      if (mock == null) return null;
      return SellerProfileModel.fromEntity(mock);
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const app_exceptions.AuthException(message: 'Not authenticated');
      }

      final response = await _supabase
          .from(ApiEndpoints.sellerProfiles)
          .select()
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (response == null) return null;

      return SellerProfileModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error getting seller profile', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is app_exceptions.AuthException) rethrow;
      AppLogger.error('Error getting seller profile', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<SellerProfileModel> createSellerProfile({
    required String businessName,
    required BusinessType businessType,
    String? description,
    String? address,
    String? city,
    List<String>? contactPhones,
  }) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Creating seller profile for $businessName');
      await Future.delayed(const Duration(milliseconds: 500));
      final seller = MockData.promoteCurrentUserToSeller(
        businessName: businessName,
        businessType: businessType,
        description: description,
        address: address,
        city: city,
        contactPhones: contactPhones,
      );
      return SellerProfileModel.fromEntity(seller);
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const app_exceptions.AuthException(message: 'Not authenticated');
      }

      final now = DateTime.now().toIso8601String();
      final data = {
        'user_id': currentUser.id,
        'business_name': businessName,
        'business_type': businessType.name,
        'description': description,
        'address': address,
        'city': city,
        'contact_phones': contactPhones ?? [],
        'is_verified': false,
        'subscription_type': 'free',
        'total_listings': 0,
        'active_listings': 0,
        'total_sold': 0,
        'total_views': 0,
        'avg_rating': 0,
        'total_reviews': 0,
        'followers_count': 0,
        'created_at': now,
        'updated_at': now,
      };

      final response = await _supabase
          .from(ApiEndpoints.sellerProfiles)
          .insert(data)
          .select()
          .single();

      // Update user role to seller
      await _supabase
          .from(ApiEndpoints.profiles)
          .update({
            'role': 'seller',
            'updated_at': now,
          })
          .eq('id', currentUser.id);

      AppLogger.info('Seller profile created successfully');
      return SellerProfileModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error creating seller profile', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is app_exceptions.AuthException) rethrow;
      AppLogger.error('Error creating seller profile', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<SellerProfileModel> updateSellerProfile(Map<String, dynamic> updates) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Updating seller profile');
      await Future.delayed(const Duration(milliseconds: 400));
      final current = MockData.currentSellerProfile;
      if (current == null) {
        throw const app_exceptions.ServerException(
          message: 'No seller profile to update',
        );
      }
      final updated = current.copyWith(
        businessName: updates['business_name'] as String? ?? current.businessName,
        description: updates['description'] as String? ?? current.description,
        logoUrl: updates['logo_url'] as String? ?? current.logoUrl,
        coverUrl: updates['cover_url'] as String? ?? current.coverUrl,
        address: updates['address'] as String? ?? current.address,
        city: updates['city'] as String? ?? current.city,
        district: updates['district'] as String? ?? current.district,
        telegram: updates['telegram'] as String? ?? current.telegram,
        instagram: updates['instagram'] as String? ?? current.instagram,
        website: updates['website'] as String? ?? current.website,
        contactPhones: (updates['contact_phones'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            current.contactPhones,
        updatedAt: DateTime.now(),
      );
      MockData.currentSellerProfile = updated;
      return SellerProfileModel.fromEntity(updated);
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const app_exceptions.AuthException(message: 'Not authenticated');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from(ApiEndpoints.sellerProfiles)
          .update(updates)
          .eq('user_id', currentUser.id)
          .select()
          .single();

      return SellerProfileModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error updating seller profile', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is app_exceptions.AuthException) rethrow;
      AppLogger.error('Error updating seller profile', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<List<SubscriptionPlanDetails>> getSubscriptionPlans() async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Getting subscription plans');
      await Future.delayed(const Duration(milliseconds: 500));
      return _getDefaultPlans();
    }

    try {
      final response = await _supabase
          .from(ApiEndpoints.subscriptionPlans)
          .select()
          .order('price_monthly');

      return (response as List).map((json) {
        final plan = SubscriptionPlan.fromString(json['type'] as String);
        return SubscriptionPlanDetails(
          plan: plan,
          name: json['name'] as String? ?? plan.label,
          description: json['description'] as String? ?? plan.audienceLabel,
          monthlyPrice: json['price_monthly'] as int? ?? plan.monthlyPrice,
          yearlyPrice: json['price_yearly'] as int? ?? plan.yearlyPrice,
          maxListings: json['max_listings'] as int? ?? plan.maxListings,
          seatsLimit: json['seats_limit'] as int? ?? plan.seatsLimit,
          additionalSeatPrice:
              json['additional_seat_price'] as int? ?? plan.additionalSeatPrice,
          hasVerifiedBadge:
              json['has_verified_badge'] as bool? ?? plan.hasVerifiedBadge,
          analyticsLevel:
              json['analytics_level'] as String? ?? plan.analyticsLevel,
          hasPersonalManager:
              json['has_personal_manager'] as bool? ?? plan.hasPersonalManager,
          hasApiAccess: json['has_api_access'] as bool? ?? plan.hasApiAccess,
          hasMultiBranch:
              json['has_multi_branch'] as bool? ?? plan.hasMultiBranch,
          audienceLabel:
              json['audience_label'] as String? ?? plan.audienceLabel,
          features: (json['features'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              plan.features,
          isPopular: json['is_popular'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      AppLogger.error('Error getting subscription plans', e);
      return _getDefaultPlans();
    }
  }

  /// Single source of truth — every detail is derived from [SubscriptionPlan].
  /// Pro plan is flagged as popular ("Tavsiya etiladi") for conversion UX.
  List<SubscriptionPlanDetails> _getDefaultPlans() {
    return SubscriptionPlan.values
        .map((plan) => SubscriptionPlanDetails(
              plan: plan,
              name: plan.label,
              description: plan.audienceLabel,
              monthlyPrice: plan.monthlyPrice,
              yearlyPrice: plan.yearlyPrice,
              maxListings: plan.maxListings,
              seatsLimit: plan.seatsLimit,
              additionalSeatPrice: plan.additionalSeatPrice,
              hasVerifiedBadge: plan.hasVerifiedBadge,
              analyticsLevel: plan.analyticsLevel,
              hasPersonalManager: plan.hasPersonalManager,
              hasApiAccess: plan.hasApiAccess,
              hasMultiBranch: plan.hasMultiBranch,
              audienceLabel: plan.audienceLabel,
              features: plan.features,
              isPopular: plan == SubscriptionPlan.pro,
            ))
        .toList();
  }

  @override
  Future<SellerProfileModel> subscribeToPlan(SubscriptionPlan plan) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Subscribing to ${plan.name}');
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();
      return SellerProfileModel(
        id: 'test_seller',
        userId: 'test_user',
        businessName: 'Test Business',
        businessType: BusinessType.individual,
        isVerified: false,
        subscriptionPlan: plan,
        subscriptionExpiresAt: now.add(const Duration(days: 30)),
        stats: const SellerStats(),
        createdAt: now,
        updatedAt: now,
      );
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const app_exceptions.AuthException(message: 'Not authenticated');
      }

      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 30));

      final response = await _supabase
          .from(ApiEndpoints.sellerProfiles)
          .update({
            'subscription_type': plan.name,
            'subscription_expires_at': expiresAt.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .eq('user_id', currentUser.id)
          .select()
          .single();

      return SellerProfileModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error subscribing to plan', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is app_exceptions.AuthException) rethrow;
      AppLogger.error('Error subscribing to plan', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<SellerProfileModel> cancelSubscription() async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Cancelling subscription');
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();
      return SellerProfileModel(
        id: 'test_seller',
        userId: 'test_user',
        businessName: 'Test Business',
        businessType: BusinessType.individual,
        isVerified: false,
        subscriptionPlan: SubscriptionPlan.free,
        stats: const SellerStats(),
        createdAt: now,
        updatedAt: now,
      );
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const app_exceptions.AuthException(message: 'Not authenticated');
      }

      final response = await _supabase
          .from(ApiEndpoints.sellerProfiles)
          .update({
            'subscription_type': 'free',
            'subscription_expires_at': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', currentUser.id)
          .select()
          .single();

      return SellerProfileModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      AppLogger.error('Database error cancelling subscription', e);
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      if (e is app_exceptions.AuthException) rethrow;
      AppLogger.error('Error cancelling subscription', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadLogo(String filePath) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Uploading logo');
      await Future.delayed(const Duration(milliseconds: 500));
      return 'https://ui-avatars.com/api/?name=Test&size=200&background=0088cc&color=fff';
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const app_exceptions.AuthException(message: 'Not authenticated');
      }

      final file = File(filePath);
      final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from(ApiEndpoints.logosBucket)
          .upload(fileName, file);

      final url = _supabase.storage
          .from(ApiEndpoints.logosBucket)
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      AppLogger.error('Error uploading logo', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadCover(String filePath) async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Uploading cover');
      await Future.delayed(const Duration(milliseconds: 500));
      return 'https://picsum.photos/800/400?random=99';
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw const app_exceptions.AuthException(message: 'Not authenticated');
      }

      final file = File(filePath);
      final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from(ApiEndpoints.coversBucket)
          .upload(fileName, file);

      final url = _supabase.storage
          .from(ApiEndpoints.coversBucket)
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      AppLogger.error('Error uploading cover', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> canBecomeASeller() async {
    if (TestConfig.isTestMode) {
      AppLogger.info('TEST MODE: Checking if can become a seller');
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // Check if user already has a seller profile
      final existing = await _supabase
          .from(ApiEndpoints.sellerProfiles)
          .select('id')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      return existing == null;
    } catch (e) {
      return false;
    }
  }
}
