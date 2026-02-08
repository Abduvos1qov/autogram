import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../core/widgets/feedback/shimmer_loading.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/feed_card.dart';
import '../widgets/stories_bar.dart';

/// Home screen - Instagram-style feed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<HomeBloc>().add(const HomeLoadRequested());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<HomeBloc>().add(const HomeLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll - 200;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(const HomeRefreshRequested());
    // Wait for state to update
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return _buildLoading();
          }

          if (state.hasError && state.items.isEmpty) {
            return ErrorView(
              failure: state.failure,
              onRetry: () {
                context.read<HomeBloc>().add(const HomeLoadRequested());
              },
            );
          }

          if (state.isEmpty) {
            return const EmptyView(
              icon: Icons.video_library_outlined,
              title: 'E\'lonlar yo\'q',
              message: 'Hozircha e\'lonlar mavjud emas',
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Stories bar
                const SliverToBoxAdapter(
                  child: StoriesBar(),
                ),

                // Feed items
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= state.items.length) {
                        return state.hasMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: LoadingIndicator(size: 24),
                              )
                            : null;
                      }

                      final item = state.items[index];
                      return FeedCard(
                        item: item,
                        onTap: () => context.push('/listing/${item.id}'),
                        onLike: () {
                          context.read<HomeBloc>().add(
                                HomeLikeToggled(item.id),
                              );
                        },
                        onSave: () {
                          context.read<HomeBloc>().add(
                                HomeSaveToggled(item.id),
                              );
                        },
                        onSellerTap: () {
                          context.push('/seller/${item.sellerId}');
                        },
                      );
                    },
                    childCount: state.items.length + (state.hasMore ? 1 : 0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'AUTOGRAM',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () => context.push('/conversations'),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => const ShimmerFeedCard(),
    );
  }
}
