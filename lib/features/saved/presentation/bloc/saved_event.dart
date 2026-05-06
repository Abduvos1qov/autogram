import 'package:equatable/equatable.dart';

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
