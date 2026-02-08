import 'package:equatable/equatable.dart';

/// Reels BLoC events

abstract class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial reels
class ReelsLoadRequested extends ReelsEvent {
  const ReelsLoadRequested();
}

/// Load more reels
class ReelsLoadMoreRequested extends ReelsEvent {
  const ReelsLoadMoreRequested();
}

/// Current reel changed (swiped)
class ReelsCurrentChanged extends ReelsEvent {
  final int index;

  const ReelsCurrentChanged(this.index);

  @override
  List<Object?> get props => [index];
}

/// Like a reel
class ReelsLikeToggled extends ReelsEvent {
  final String reelId;

  const ReelsLikeToggled(this.reelId);

  @override
  List<Object?> get props => [reelId];
}

/// Save a reel
class ReelsSaveToggled extends ReelsEvent {
  final String reelId;

  const ReelsSaveToggled(this.reelId);

  @override
  List<Object?> get props => [reelId];
}

/// Share reel
class ReelsShareRequested extends ReelsEvent {
  final String reelId;

  const ReelsShareRequested(this.reelId);

  @override
  List<Object?> get props => [reelId];
}

/// Record view duration
class ReelsViewRecorded extends ReelsEvent {
  final String reelId;
  final int duration;

  const ReelsViewRecorded({
    required this.reelId,
    required this.duration,
  });

  @override
  List<Object?> get props => [reelId, duration];
}

/// Follow seller
class ReelsFollowToggled extends ReelsEvent {
  final String sellerId;

  const ReelsFollowToggled(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}
