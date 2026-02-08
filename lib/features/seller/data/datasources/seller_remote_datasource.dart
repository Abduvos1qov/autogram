import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
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
  final SupabaseClient _supabase;

  SellerRemoteDataSourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<SellerProfileModel?> getSellerProfile() async {
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
    } catch (e) {
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
          .from(ApiEndpoints.users)
          .update({
            'role': 'seller',
            'updated_at': now,
          })
          .eq('id', currentUser.id);

      AppLogger.info('Seller profile created successfully');
      return SellerProfileModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating seller profile', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<SellerProfileModel> updateSellerProfile(Map<String, dynamic> updates) async {
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
    } catch (e) {
      AppLogger.error('Error updating seller profile', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<List<SubscriptionPlanDetails>> getSubscriptionPlans() async {
    try {
      final response = await _supabase
          .from(ApiEndpoints.subscriptionPlans)
          .select()
          .order('price_monthly');

      return (response as List).map((json) {
        return SubscriptionPlanDetails(
          plan: SubscriptionPlan.fromString(json['type'] as String),
          name: json['name'] as String,
          description: json['description'] as String? ?? '',
          monthlyPrice: json['price_monthly'] as int,
          yearlyPrice: json['price_yearly'] as int,
          maxListings: json['max_listings'] as int,
          features: (json['features'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
          isPopular: json['is_popular'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      AppLogger.error('Error getting subscription plans', e);
      // Return default plans
      return [
        SubscriptionPlanDetails(
          plan: SubscriptionPlan.free,
          name: 'Bepul',
          description: 'Boshlash uchun ideal',
          monthlyPrice: 0,
          yearlyPrice: 0,
          maxListings: 3,
          features: SubscriptionPlan.free.features,
        ),
        SubscriptionPlanDetails(
          plan: SubscriptionPlan.basic,
          name: 'Boshlang\'ich',
          description: 'Kichik biznes uchun',
          monthlyPrice: 99000,
          yearlyPrice: 999000,
          maxListings: 10,
          features: SubscriptionPlan.basic.features,
        ),
        SubscriptionPlanDetails(
          plan: SubscriptionPlan.professional,
          name: 'Professional',
          description: 'Ko\'proq e\'lonlar va imkoniyatlar',
          monthlyPrice: 299000,
          yearlyPrice: 2999000,
          maxListings: 50,
          features: SubscriptionPlan.professional.features,
          isPopular: true,
        ),
        SubscriptionPlanDetails(
          plan: SubscriptionPlan.premium,
          name: 'Premium',
          description: 'Maksimal imkoniyatlar',
          monthlyPrice: 599000,
          yearlyPrice: 5999000,
          maxListings: 999,
          features: SubscriptionPlan.premium.features,
        ),
      ];
    }
  }

  @override
  Future<SellerProfileModel> subscribeToPlan(SubscriptionPlan plan) async {
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
    } catch (e) {
      AppLogger.error('Error subscribing to plan', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<SellerProfileModel> cancelSubscription() async {
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
    } catch (e) {
      AppLogger.error('Error cancelling subscription', e);
      throw app_exceptions.ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadLogo(String filePath) async {
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
