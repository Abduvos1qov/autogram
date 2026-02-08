import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/saved_item.dart';
import '../../domain/repositories/saved_repository.dart';

// Events
sealed class SavedEvent extends Equatable {
  const SavedEvent();
  @override
  List<Object?> get props => [];
}

class SavedLoadRequested extends SavedEvent {
  const SavedLoadRequested();
}

class SavedItemRemoved extends SavedEvent {
  final String listingId;
  const SavedItemRemoved(this.listingId);
  @override
  List<Object?> get props => [listingId];
}

class SavedCleared extends SavedEvent {
  const SavedCleared();
}

// State
enum SavedStatus { initial, loading, loaded, error }

class SavedState extends Equatable {
  final SavedStatus status;
  final List<SavedItem> items;
  final Failure? failure;

  const SavedState({
    this.status = SavedStatus.initial,
    this.items = const [],
    this.failure,
  });

  bool get isLoading => status == SavedStatus.loading;
  bool get hasError => status == SavedStatus.error;
  bool get isEmpty => items.isEmpty && status == SavedStatus.loaded;

  SavedState copyWith({
    SavedStatus? status,
    List<SavedItem>? items,
    Failure? failure,
  }) {
    return SavedState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, items, failure];
}

// BLoC
class SavedBloc extends Bloc<SavedEvent, SavedState> {
  final SavedRepository _repository;

  SavedBloc({required SavedRepository repository})
      : _repository = repository,
        super(const SavedState()) {
    on<SavedLoadRequested>(_onLoadRequested);
    on<SavedItemRemoved>(_onItemRemoved);
    on<SavedCleared>(_onCleared);
  }

  Future<void> _onLoadRequested(
    SavedLoadRequested event,
    Emitter<SavedState> emit,
  ) async {
    AppLogger.info('Loading saved items');
    emit(state.copyWith(status: SavedStatus.loading));

    final result = await _repository.getSavedItems();

    result.fold(
      (failure) {
        AppLogger.error('Failed to load saved: ${failure.message}');
        emit(state.copyWith(
          status: SavedStatus.error,
          failure: failure,
        ));
      },
      (items) {
        AppLogger.info('Loaded ${items.length} saved items');
        emit(state.copyWith(
          status: SavedStatus.loaded,
          items: items,
        ));
      },
    );
  }

  Future<void> _onItemRemoved(
    SavedItemRemoved event,
    Emitter<SavedState> emit,
  ) async {
    // Optimistic update
    final updatedItems = state.items
        .where((item) => item.listingId != event.listingId)
        .toList();
    emit(state.copyWith(items: updatedItems));

    final result = await _repository.removeFromSaved(event.listingId);

    result.fold(
      (failure) {
        AppLogger.error('Failed to remove: ${failure.message}');
        // Reload on error
        add(const SavedLoadRequested());
      },
      (_) {
        AppLogger.info('Removed from saved: ${event.listingId}');
      },
    );
  }

  Future<void> _onCleared(
    SavedCleared event,
    Emitter<SavedState> emit,
  ) async {
    emit(state.copyWith(items: []));

    final result = await _repository.clearAllSaved();

    result.fold(
      (failure) {
        AppLogger.error('Failed to clear: ${failure.message}');
        add(const SavedLoadRequested());
      },
      (_) {
        AppLogger.info('Cleared all saved items');
      },
    );
  }
}
