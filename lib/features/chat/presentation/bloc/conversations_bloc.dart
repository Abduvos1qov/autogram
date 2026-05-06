import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/repositories/chat_repository.dart';
import 'conversations_event.dart';
import 'conversations_state.dart';

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
    emit(state.copyWith(status: ConversationsStatus.loading, clearFailure: true));

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

        final unreadResult = await _repository.getUnreadCount();
        final unreadCount = unreadResult.fold((_) => 0, (count) => count);

        emit(state.copyWith(
          status: ConversationsStatus.loaded,
          conversations: conversations,
          unreadCount: unreadCount,
        ));

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
