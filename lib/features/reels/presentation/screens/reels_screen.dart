import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../bloc/reels_bloc.dart';
import '../bloc/reels_event.dart';
import '../bloc/reels_state.dart';
import '../widgets/reel_player.dart';

/// Reels screen - TikTok-style full-screen video feed

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<ReelsBloc>().add(const ReelsLoadRequested());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    context.read<ReelsBloc>().add(ReelsCurrentChanged(index));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.black,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<ReelsBloc, ReelsState>(
          builder: (context, state) {
            if (state.isLoading && state.reels.isEmpty) {
              return const Center(
                child: LoadingIndicator(color: AppColors.white),
              );
            }

            if (state.hasError && state.reels.isEmpty) {
              return ErrorView(
                failure: state.failure,
                onRetry: () {
                  context.read<ReelsBloc>().add(const ReelsLoadRequested());
                },
              );
            }

            if (state.isEmpty) {
              return const EmptyView(
                icon: Icons.video_library_outlined,
                title: 'Videolar yo\'q',
                message: 'Hozircha videolar mavjud emas',
              );
            }

            return Stack(
              children: [
                // Reels PageView
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: state.reels.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final reel = state.reels[index];
                    final isActive = index == state.currentIndex;

                    return ReelPlayer(
                      key: ValueKey(reel.id),
                      reel: reel,
                      isActive: isActive,
                      onLike: () {
                        context.read<ReelsBloc>().add(
                              ReelsLikeToggled(reel.id),
                            );
                      },
                      onSave: () {
                        context.read<ReelsBloc>().add(
                              ReelsSaveToggled(reel.id),
                            );
                      },
                      onShare: () {
                        context.read<ReelsBloc>().add(
                              ReelsShareRequested(reel.id),
                            );
                      },
                      onViewDuration: (duration) {
                        context.read<ReelsBloc>().add(
                              ReelsViewRecorded(
                                reelId: reel.id,
                                duration: duration,
                              ),
                            );
                      },
                    );
                  },
                ),

                // Loading more indicator
                if (state.isLoadingMore)
                  const Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: LoadingIndicator(
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
