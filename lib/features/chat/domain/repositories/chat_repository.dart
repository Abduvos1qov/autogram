import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

/// Chat repository interface

abstract class ChatRepository {
  /// Get all conversations
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// Get or create conversation
  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String sellerId,
    String? listingId,
  });

  /// Get messages for a conversation
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);

  /// Send a message
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  });

  /// Mark messages as read
  Future<Either<Failure, void>> markAsRead(String conversationId);

  /// Stream of new messages
  Stream<Message> watchMessages(String conversationId);

  /// Stream of conversations
  Stream<List<Conversation>> watchConversations();

  /// Get total unread count
  Future<Either<Failure, int>> getUnreadCount();
}
