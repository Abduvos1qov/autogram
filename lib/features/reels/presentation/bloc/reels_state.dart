import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/reel.dart';

/// Reels BLoC states

enum ReelsStatus { initial, loading, loaded, loadingMore, error }

class ReelsState extends Equatable {
  final ReelsStatus status;
  final List<Reel> reels;
  final int currentIndex;
  final bool hasMore;
  final int currentPage;
  final Failure? failure;

  const ReelsState({
    this.status = ReelsStatus.initial,
    this.reels = const [],
    this.currentIndex = 0,
    this.hasMore = true,
    this.currentPage = 1,
    this.failure,
  });

  Reel? get currentReel =>
      reels.isNotEmpty && currentIndex < reels.length
          ? reels[currentIndex]
          : null;

  bool get isLoading => status == ReelsStatus.loading;
  bool get isLoadingMore => status == ReelsStatus.loadingMore;
  bool get hasError => status == ReelsStatus.error;
  bool get isEmpty => reels.isEmpty && status == ReelsStatus.loaded;

  bool get shouldLoadMore =>
      hasMore &&
      !isLoadingMore &&
      currentIndex >= reels.length - 2;

  ReelsState copyWith({
    ReelsStatus? status,
    List<Reel>? reels,
    int? currentIndex,
    bool? hasMore,
    int? currentPage,
    Failure? failure,
  }) {
    return ReelsState(
      status: status ?? this.status,
      reels: reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reels,
        currentIndex,
        hasMore,
        currentPage,
        failure,
      ];
}
