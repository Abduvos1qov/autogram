import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/repositories/saved_repository.dart';
import 'saved_event.dart';
import 'saved_state.dart';

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
    emit(state.copyWith(status: SavedStatus.loading, clearFailure: true));

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
    final updatedItems = state.items
        .where((item) => item.listingId != event.listingId)
        .toList();
    emit(state.copyWith(items: updatedItems));

    final result = await _repository.removeFromSaved(event.listingId);

    result.fold(
      (failure) {
        AppLogger.error('Failed to remove: ${failure.message}');
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
