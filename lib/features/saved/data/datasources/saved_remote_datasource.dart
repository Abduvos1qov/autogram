import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/saved_item_model.dart';

/// Saved remote data source

abstract class SavedRemoteDataSource {
  Future<List<SavedItemModel>> getSavedItems();
  Future<void> removeFromSaved(String listingId);
  Future<void> clearAllSaved();
}

class SavedRemoteDataSourceImpl implements SavedRemoteDataSource {
  final SupabaseClient supabaseClient;

  SavedRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<SavedItemModel>> getSavedItems() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      final response = await supabaseClient
          .from(ApiEndpoints.saves)
          .select('''
            *,
            listings(
              *,
              seller_profiles(id, business_name, is_verified),
              listing_auto_details(year, mileage, transmission)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SavedItemModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> removeFromSaved(String listingId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      await supabaseClient
          .from(ApiEndpoints.saves)
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> clearAllSaved() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw const AuthException(message: 'Not authenticated');

      await supabaseClient
          .from(ApiEndpoints.saves)
          .delete()
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
