import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/test_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/message.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Chat remote data source

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel> getOrCreateConversation({
    required String sellerId,
    String? listingId,
  });
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  });
  Future<void> markAsRead(String conversationId);
  Stream<MessageModel> watchMessages(String conversationId);
  Stream<List<ConversationModel>> watchConversations();
  Future<int> getUnreadCount();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl({required this.supabaseClient});

  String get _currentUserId => supabaseClient.auth.currentUser?.id ?? '';

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      // Check if test mode
      if (TestConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        return MockData.mockConversations
            .map((conv) => ConversationModel.fromEntity(conv))
            .toList();
      }

      final response = await supabaseClient
          .from(ApiEndpoints.conversations)
          .select('''
            *,
            listings(id, title, video_thumbnail_url, price),
            buyer:users!buyer_id(id, full_name, avatar_url),
            seller_profiles(id, business_name, logo_url, is_verified)
          ''')
          .or('buyer_id.eq.$_currentUserId,seller_id.eq.$_currentUserId')
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => ConversationModel.fromJson(json, _currentUserId))
          .toList();
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String sellerId,
    String? listingId,
  }) async {
    try {
      // Check if conversation exists
      final existing = await supabaseClient
          .from(ApiEndpoints.conversations)
          .select('''
            *,
            listings(id, title, video_thumbnail_url, price),
            buyer:users!buyer_id(id, full_name, avatar_url),
            seller_profiles(id, business_name, logo_url, is_verified)
          ''')
          .eq('buyer_id', _currentUserId)
          .eq('seller_id', sellerId)
          .maybeSingle();

      if (existing != null) {
        return ConversationModel.fromJson(existing, _currentUserId);
      }

      // Create new conversation
      final newConversation = await supabaseClient
          .from(ApiEndpoints.conversations)
          .insert({
            'buyer_id': _currentUserId,
            'seller_id': sellerId,
            'listing_id': listingId,
          })
          .select('''
            *,
            listings(id, title, video_thumbnail_url, price),
            buyer:users!buyer_id(id, full_name, avatar_url),
            seller_profiles(id, business_name, logo_url, is_verified)
          ''')
          .single();

      return ConversationModel.fromJson(newConversation, _currentUserId);
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      // Check if test mode
      if (TestConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        final messages = MockData.mockMessages[conversationId] ?? [];
        return messages.map((msg) => MessageModel.fromEntity(msg)).toList();
      }

      final response = await supabaseClient
          .from(ApiEndpoints.messages)
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await supabaseClient
          .from(ApiEndpoints.messages)
          .insert({
            'conversation_id': conversationId,
            'sender_id': _currentUserId,
            'content': content,
            'message_type': type.name,
            'metadata': metadata ?? {},
          })
          .select()
          .single();

      // Update conversation last message
      await supabaseClient.from(ApiEndpoints.conversations).update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);

      return MessageModel.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    try {
      await supabaseClient
          .from(ApiEndpoints.messages)
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('conversation_id', conversationId)
          .neq('sender_id', _currentUserId);
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<MessageModel> watchMessages(String conversationId) {
    return supabaseClient
        .from(ApiEndpoints.messages)
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((list) => list.isNotEmpty
            ? MessageModel.fromJson(list.last)
            : throw Exception('No messages'));
  }

  @override
  Stream<List<ConversationModel>> watchConversations() {
    return supabaseClient
        .from(ApiEndpoints.conversations)
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .map((list) => list
            .map((json) => ConversationModel.fromJson(json, _currentUserId))
            .toList());
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await supabaseClient
          .from(ApiEndpoints.messages)
          .select('id')
          .eq('is_read', false)
          .neq('sender_id', _currentUserId)
          .count(supabase.CountOption.exact);

      return response.count;
    } on supabase.PostgrestException catch (e) {
      ErrorHandler.throwFromPostgrest(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
