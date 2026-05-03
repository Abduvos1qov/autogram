import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../domain/entities/filter.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_result_card.dart';

/// Search screen

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(const SearchInitialized());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(const SearchLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        actions: [
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: state.hasActiveFilters,
                  label: Text('${state.filter.activeFilterCount}'),
                  child: const Icon(Icons.tune),
                ),
                onPressed: () => _openFilters(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.status == SearchStatus.initial) {
            return _buildInitialView(state);
          }

          if (state.isLoading && state.results.isEmpty) {
            return const Center(child: LoadingIndicator());
          }

          if (state.hasError && state.results.isEmpty) {
            return ErrorView(
              failure: state.failure,
              onRetry: () {
                context.read<SearchBloc>().add(const SearchSubmitted());
              },
            );
          }

          if (state.isEmpty) {
            return EmptyView(
              icon: Icons.search_off,
              title: 'Natija topilmadi',
              message: state.hasActiveFilters
                  ? 'Filtrlarni o\'zgartirib ko\'ring'
                  : 'Boshqa so\'z bilan qidirib ko\'ring',
            );
          }

          return _buildResultsView(state);
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Marka yoki model qidiring...',
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<SearchBloc>().add(const SearchQueryChanged(''));
                },
              )
            : null,
      ),
      onChanged: (value) {
        context.read<SearchBloc>().add(SearchQueryChanged(value));
      },
      onSubmitted: (value) {
        context.read<SearchBloc>().add(SearchSubmitted(query: value));
      },
    );
  }

  Widget _buildInitialView(SearchState state) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Suggestions
        if (state.suggestions.isNotEmpty) ...[
          _buildSectionTitle('Takliflar'),
          ...state.suggestions.map((s) => _buildSuggestionTile(s)),
          AppSpacing.gapVerticalLg,
        ],

        // Recent searches
        if (state.recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('So\'nggi qidiruvlar'),
              TextButton(
                onPressed: () {
                  context.read<SearchBloc>().add(const SearchRecentCleared());
                },
                child: const Text('Tozalash'),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: state.recentSearches
                .map((s) => _buildRecentChip(s))
                .toList(),
          ),
          AppSpacing.gapVerticalLg,
        ],

        // Popular searches
        if (state.popularSearches.isNotEmpty) ...[
          _buildSectionTitle('Mashhur qidiruvlar'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: state.popularSearches
                .map((s) => _buildPopularChip(s))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.titleMedium(context),
      ),
    );
  }

  Widget _buildSuggestionTile(String suggestion) {
    return ListTile(
      leading: const Icon(Icons.search),
      title: Text(suggestion),
      onTap: () {
        _searchController.text = suggestion;
        context.read<SearchBloc>().add(SearchSubmitted(query: suggestion));
      },
    );
  }

  Widget _buildRecentChip(String search) {
    return ActionChip(
      avatar: const Icon(Icons.history, size: 16),
      label: Text(search),
      onPressed: () {
        _searchController.text = search;
        context.read<SearchBloc>().add(SearchSubmitted(query: search));
      },
    );
  }

  Widget _buildPopularChip(String search) {
    return ActionChip(
      avatar: const Icon(Icons.trending_up, size: 16),
      label: Text(search),
      onPressed: () {
        _searchController.text = search;
        context.read<SearchBloc>().add(SearchSubmitted(query: search));
      },
    );
  }

  Widget _buildResultsView(SearchState state) {
    return Column(
      children: [
        // Results count and sort
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.results.length} ta natija',
                style: AppTypography.bodyMedium(context).copyWith(
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.sort, size: 18),
                label: Text(state.filter.sortBy.label),
                onPressed: () => _showSortOptions(context, state),
              ),
            ],
          ),
        ),

        // Results grid
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: state.results.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.results.length) {
                return const Center(child: LoadingIndicator(size: 24));
              }

              final result = state.results[index];
              return SearchResultCard(
                result: result,
                onTap: () => context.push('/listing/${result.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openFilters(BuildContext context) {
    context.push('/search/filter');
  }

  void _showSortOptions(BuildContext context, SearchState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Saralash',
                  style: AppTypography.titleMedium(context),
                ),
              ),
              ...SortOption.values.map((option) {
                return ListTile(
                  leading: Radio<SortOption>(
                    value: option,
                    groupValue: state.filter.sortBy,
                    onChanged: (value) {
                      Navigator.pop(context);
                      if (value != null) {
                        context.read<SearchBloc>().add(SearchSortChanged(value));
                      }
                    },
                  ),
                  title: Text(option.label),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<SearchBloc>().add(SearchSortChanged(option));
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
