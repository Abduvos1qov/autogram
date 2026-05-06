import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl with RepositoryMixin implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getConversations();
    });
  }

  @override
  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String sellerId,
    String? listingId,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getOrCreateConversation(
        sellerId: sellerId,
        listingId: listingId,
      );
    });
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String conversationId) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getMessages(conversationId);
    });
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        metadata: metadata,
      );
    });
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.markAsRead(conversationId);
    });
  }

  @override
  Stream<Message> watchMessages(String conversationId) {
    return _remoteDataSource.watchMessages(conversationId);
  }

  @override
  Stream<List<Conversation>> watchConversations() {
    return _remoteDataSource.watchConversations();
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getUnreadCount();
    });
  }
}
