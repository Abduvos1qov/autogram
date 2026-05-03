import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../core/widgets/media/cached_image.dart';
import '../../domain/entities/listing.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';
import '../widgets/listing_gallery.dart';
import '../widgets/listing_specs.dart';
import '../widgets/seller_card.dart';

/// Listing detail screen

class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ListingBloc>().add(ListingLoadRequested(widget.listingId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(state),
          bottomNavigationBar: state.isLoaded ? _buildBottomBar(state) : null,
        );
      },
    );
  }

  Widget _buildBody(ListingState state) {
    if (state.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (state.hasError) {
      return ErrorView(
        failure: state.failure,
        onRetry: () {
          context.read<ListingBloc>().add(ListingLoadRequested(widget.listingId));
        },
      );
    }

    if (!state.isLoaded || state.listing == null) {
      return const SizedBox.shrink();
    }

    final listing = state.listing!;

    return CustomScrollView(
      slivers: [
        // App bar with gallery
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.45,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(
                listing.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: listing.isSaved ? AppColors.warning : null,
              ),
              onPressed: () {
                context.read<ListingBloc>().add(const ListingSaveToggled());
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                context.read<ListingBloc>().add(const ListingShareRequested());
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  _showReportDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Text('Shikoyat qilish'),
                ),
              ],
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: ListingGallery(
              videoUrl: listing.videoUrl,
              videoThumbnailUrl: listing.videoThumbnailUrl,
              images: listing.images,
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  listing.title,
                  style: AppTypography.headlineSmall(context),
                ),
                AppSpacing.gapVerticalSm,

                // Price
                Row(
                  children: [
                    Text(
                      Formatters.formatPrice(listing.price, currency: listing.currency),
                      style: AppTypography.headlineMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (listing.isNegotiable) ...[
                      AppSpacing.gapHorizontalSm,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Kelishiladi',
                          style: AppTypography.labelSmall(context).copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                AppSpacing.gapVerticalMd,

                // Stats
                Row(
                  children: [
                    _buildStat(Icons.visibility_outlined, Formatters.formatNumber(listing.viewsCount)),
                    AppSpacing.gapHorizontalMd,
                    _buildStat(Icons.favorite_outline, Formatters.formatNumber(listing.likesCount)),
                    AppSpacing.gapHorizontalMd,
                    if (listing.city != null)
                      _buildStat(Icons.location_on_outlined, listing.city!),
                  ],
                ),
                AppSpacing.gapVerticalLg,

                // Specs
                if (listing.autoDetails != null) ...[
                  Text('Xususiyatlar', style: AppTypography.titleMedium(context)),
                  AppSpacing.gapVerticalSm,
                  ListingSpecs(autoDetails: listing.autoDetails!),
                  AppSpacing.gapVerticalLg,
                ],

                // Description
                if (listing.description != null && listing.description!.isNotEmpty) ...[
                  Text('Tavsif', style: AppTypography.titleMedium(context)),
                  AppSpacing.gapVerticalSm,
                  Text(
                    listing.description!,
                    style: AppTypography.bodyMedium(context),
                  ),
                  AppSpacing.gapVerticalLg,
                ],

                // Seller
                Text('Sotuvchi', style: AppTypography.titleMedium(context)),
                AppSpacing.gapVerticalSm,
                SellerCard(
                  seller: listing.seller,
                  onTap: () => context.push('/seller/${listing.seller.id}'),
                  onFollow: () {
                    context.read<ListingBloc>().add(const ListingSellerFollowToggled());
                  },
                ),
                AppSpacing.gapVerticalLg,

                // Similar listings
                if (state.similarListings.isNotEmpty) ...[
                  Text('O\'xshash e\'lonlar', style: AppTypography.titleMedium(context)),
                  AppSpacing.gapVerticalSm,
                ],
              ],
            ),
          ),
        ),

        // Similar listings grid
        if (state.similarListings.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final similar = state.similarListings[index];
                  return _buildSimilarCard(similar);
                },
                childCount: state.similarListings.length,
              ),
            ),
          ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryOf(context)),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.bodySmall(context).copyWith(
            color: AppColors.textSecondaryOf(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarCard(Listing listing) {
    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppCachedImage(
                imageUrl: listing.videoThumbnailUrl ?? listing.images.firstOrNull,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatPrice(listing.price, currency: listing.currency),
                      style: AppTypography.titleSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.title,
                      style: AppTypography.bodySmall(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ListingState state) {
    final listing = state.listing!;
    final seller = listing.seller;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Like button
            IconButton(
              onPressed: () {
                context.read<ListingBloc>().add(const ListingLikeToggled());
              },
              icon: Icon(
                listing.isLiked ? Icons.favorite : Icons.favorite_border,
                color: listing.isLiked ? AppColors.error : null,
              ),
            ),
            AppSpacing.gapHorizontalSm,

            // Call button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: seller.contactPhones.isNotEmpty
                    ? () => _makeCall(seller.contactPhones.first)
                    : null,
                icon: const Icon(Icons.phone),
                label: const Text('Qo\'ng\'iroq'),
              ),
            ),
            AppSpacing.gapHorizontalSm,

            // Message button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/chat/new?listing=${listing.id}&seller=${seller.id}');
                },
                icon: const Icon(Icons.chat),
                label: const Text('Xabar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedReason;
        final controller = TextEditingController();

        return AlertDialog(
          title: const Text('Shikoyat qilish'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                hint: const Text('Sababni tanlang'),
                items: const [
                  DropdownMenuItem(value: 'spam', child: Text('Spam')),
                  DropdownMenuItem(value: 'fake', child: Text('Soxta e\'lon')),
                  DropdownMenuItem(value: 'inappropriate', child: Text('Noto\'g\'ri kontent')),
                  DropdownMenuItem(value: 'sold', child: Text('Allaqachon sotilgan')),
                  DropdownMenuItem(value: 'other', child: Text('Boshqa')),
                ],
                onChanged: (value) => selectedReason = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Qo\'shimcha izoh (ixtiyoriy)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedReason != null) {
                  context.read<ListingBloc>().add(ListingReportRequested(
                    reason: selectedReason!,
                    description: controller.text.isNotEmpty ? controller.text : null,
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shikoyatingiz qabul qilindi')),
                  );
                }
              },
              child: const Text('Yuborish'),
            ),
          ],
        );
      },
    );
  }
}
