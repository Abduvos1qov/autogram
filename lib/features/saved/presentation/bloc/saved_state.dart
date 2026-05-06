import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/saved_item.dart';

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
    bool clearFailure = false,
  }) {
    return SavedState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, items, failure];
}
