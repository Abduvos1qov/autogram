import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../core/widgets/media/cached_image.dart';
import '../../domain/entities/saved_item.dart';
import '../bloc/saved_bloc.dart';

/// Saved/Wishlist screen

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavedBloc>().add(const SavedLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saqlanganlar'),
        actions: [
          BlocBuilder<SavedBloc, SavedState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearDialog(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SavedBloc, SavedState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state.hasError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () {
                context.read<SavedBloc>().add(const SavedLoadRequested());
              },
            );
          }

          if (state.isEmpty) {
            return const EmptyView(
              icon: Icons.bookmark_border,
              title: 'Saqlanganlar yo\'q',
              message: 'E\'lonlarni saqlang va ular shu yerda ko\'rinadi',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SavedBloc>().add(const SavedLoadRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _buildSavedCard(context, item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, SavedItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.error,
        child: const Icon(
          Icons.delete,
          color: AppColors.white,
        ),
      ),
      onDismissed: (_) {
        context.read<SavedBloc>().add(SavedItemRemoved(item.listingId));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: InkWell(
          onTap: () => context.push('/listing/${item.listingId}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: AppCachedImage(
                      imageUrl: item.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                AppSpacing.gapHorizontalMd,

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.gapVerticalXs,
                      Text(
                        Formatters.formatPrice(item.price, currency: item.currency),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpacing.gapVerticalXs,
                      if (item.autoDetails != null)
                        Text(
                          _buildSpecsText(item.autoDetails!),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      AppSpacing.gapVerticalXs,
                      Row(
                        children: [
                          Text(
                            item.sellerName,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (item.isSellerVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: AppColors.verifiedColor,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Remove button
                IconButton(
                  icon: const Icon(Icons.bookmark, color: AppColors.warning),
                  onPressed: () {
                    context.read<SavedBloc>().add(SavedItemRemoved(item.listingId));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSpecsText(SavedAutoDetails details) {
    final specs = <String>[];
    if (details.year != null) specs.add('${details.year}');
    if (details.mileage != null) specs.add(Formatters.formatMileage(details.mileage!));
    if (details.transmission != null) {
      specs.add(details.transmission == 'automatic' ? 'Avtomat' : 'Mexanik');
    }
    return specs.join(' • ');
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Barchasini o\'chirish'),
          content: const Text('Barcha saqlangan e\'lonlar o\'chiriladi'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SavedBloc>().add(const SavedCleared());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('O\'chirish'),
            ),
          ],
        );
      },
    );
  }
}
