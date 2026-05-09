import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/media/avatar.dart';
import '../../../../seller/domain/entities/seller_profile.dart';
import 'storefront_stats_row.dart';

/// IG-style identity block — avatar (left, xxl 96dp) with 4 inline stats
/// (right). Below the row: business name + verified icon, business type,
/// expandable bio, optional address line.
class StorefrontIdentityBlock extends StatelessWidget {
  final SellerProfile seller;
  final String? displayName;
  final int listingsCount;
  final int followersCount;
  final int soldCount;
  final double? rating;
  final String listingsLabel;
  final String followersLabel;
  final String soldLabel;
  final String ratingLabel;
  final VoidCallback? onListingsTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onSoldTap;
  final VoidCallback? onRatingTap;
  final String verifiedTooltip;

  const StorefrontIdentityBlock({
    super.key,
    required this.seller,
    required this.listingsCount,
    required this.followersCount,
    required this.soldCount,
    required this.rating,
    required this.listingsLabel,
    required this.followersLabel,
    required this.soldLabel,
    required this.ratingLabel,
    required this.verifiedTooltip,
    this.displayName,
    this.onListingsTap,
    this.onFollowersTap,
    this.onSoldTap,
    this.onRatingTap,
  });

  bool get _hasStoryRing => seller.subscriptionPlan != SubscriptionPlan.free;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarRing(
                hasGradientRing: _hasStoryRing,
                child: AppAvatar(
                  imageUrl: seller.logoUrl,
                  name: seller.businessName,
                  size: AvatarSize.xxl,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StorefrontStatsRow(
                  listingsCount: listingsCount,
                  followersCount: followersCount,
                  soldCount: soldCount,
                  rating: rating,
                  listingsLabel: listingsLabel,
                  followersLabel: followersLabel,
                  soldLabel: soldLabel,
                  ratingLabel: ratingLabel,
                  onListingsTap: onListingsTap,
                  onFollowersTap: onFollowersTap,
                  onSoldTap: onSoldTap,
                  onRatingTap: onRatingTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  seller.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge(context).copyWith(
                    fontWeight: AppTypography.bold,
                    height: 1.2,
                  ),
                ),
              ),
              if (seller.isVerified) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: verifiedTooltip,
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppColors.verifiedColor,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
          if (displayName != null && displayName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              displayName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            seller.businessType.labelKey.tr(),
            style: AppTypography.bodySmall(context).copyWith(
              color: AppColors.textSecondaryOf(context),
              fontWeight: AppTypography.medium,
            ),
          ),
          if (seller.description != null && seller.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ExpandableBio(text: seller.description!),
          ],
          if ((seller.city != null && seller.city!.isNotEmpty) ||
              (seller.address != null && seller.address!.isNotEmpty)) ...[
            const SizedBox(height: 8),
            _AddressLine(address: seller.address, city: seller.city),
          ],
        ],
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  final bool hasGradientRing;
  final Widget child;

  const _AvatarRing({required this.hasGradientRing, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!hasGradientRing) return child;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.storyGradient,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceOf(context),
        ),
        child: child,
      ),
    );
  }
}

class _ExpandableBio extends StatefulWidget {
  final String text;

  const _ExpandableBio({required this.text});

  @override
  State<_ExpandableBio> createState() => _ExpandableBioState();
}

class _ExpandableBioState extends State<_ExpandableBio> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _expanded = !_expanded),
        child: Text(
          widget.text,
          style: AppTypography.bodyMedium(context).copyWith(height: 1.4),
          maxLines: _expanded ? null : 3,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  final String? address;
  final String? city;

  const _AddressLine({required this.address, required this.city});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14,
          color: AppColors.textSecondaryOf(context),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            parts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(context),
          ),
        ),
      ],
    );
  }
}
