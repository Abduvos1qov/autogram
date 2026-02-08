import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';

// Events
sealed class ConversationsEvent extends Equatable {
  const ConversationsEvent();
  @override
  List<Object?> get props => [];
}

class ConversationsLoadRequested extends ConversationsEvent {
  const ConversationsLoadRequested();
}

class ConversationsUpdated extends ConversationsEvent {
  final List<Conversation> conversations;
  const ConversationsUpdated(this.conversations);
  @override
  List<Object?> get props => [conversations];
}

// State
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
  bool get isEmpty => conversations.isEmpty && status == ConversationsStatus.loaded;

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<Conversation>? conversations,
    int? unreadCount,
    Failure? failure,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      unreadCount: unreadCount ?? this.unreadCount,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, conversations, unreadCount, failure];
}

// BLoC
class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final ChatRepository _repository;
  StreamSubscription? _conversationsSubscription;

  ConversationsBloc({required ChatRepository repository})
      : _repository = repository,
        super(const ConversationsState()) {
    on<ConversationsLoadRequested>(_onLoadRequested);
    on<ConversationsUpdated>(_onUpdated);
  }

  Future<void> _onLoadRequested(
    ConversationsLoadRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    AppLogger.info('Loading conversations');
    emit(state.copyWith(status: ConversationsStatus.loading));

    final result = await _repository.getConversations();

    await result.fold(
      (failure) async {
        AppLogger.error('Failed to load conversations: ${failure.message}');
        emit(state.copyWith(
          status: ConversationsStatus.error,
          failure: failure,
        ));
      },
      (conversations) async {
        AppLogger.info('Loaded ${conversations.length} conversations');

        // Get unread count
        final unreadResult = await _repository.getUnreadCount();
        final unreadCount = unreadResult.fold((_) => 0, (count) => count);

        emit(state.copyWith(
          status: ConversationsStatus.loaded,
          conversations: conversations,
          unreadCount: unreadCount,
        ));

        // Start watching for updates
        _conversationsSubscription?.cancel();
        _conversationsSubscription = _repository.watchConversations().listen(
          (conversations) {
            add(ConversationsUpdated(conversations));
          },
        );
      },
    );
  }

  void _onUpdated(
    ConversationsUpdated event,
    Emitter<ConversationsState> emit,
  ) {
    emit(state.copyWith(conversations: event.conversations));
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }
}
