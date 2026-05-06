import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation.dart';

enum ConversationsStatus { initial, loading, loaded, error }

class ConversationsState extends Equatable {
  final ConversationsStatus status;
  final List<Conversation> conversations;
  final int unreadCount;
  final Failure? failure;

  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
    this.unreadCount = 0,
    this.failure,
  });

  bool get isLoading => status == ConversationsStatus.loading;
  bool get hasError => status == ConversationsStatus.error;
  bool get isEmpty =>
      conversations.isEmpty && status == ConversationsStatus.loaded;

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<Conversation>? conversations,
    int? unreadCount,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      unreadCount: unreadCount ?? this.unreadCount,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, conversations, unreadCount, failure];
}
