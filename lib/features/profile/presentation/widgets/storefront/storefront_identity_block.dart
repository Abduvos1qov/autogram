import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/media/avatar.dart';
import '../../../../seller/domain/entities/seller_profile.dart';
import 'storefront_stats_row.dart';

/// IG-style identity block — compact avatar (left) with 3 inline stats
/// (right). Below the row: the user's display name (large), business type,
/// expandable bio, optional address line.
///
/// The seller's `businessName` is intentionally NOT shown here — it already
/// owns the centered title in the top app bar, so repeating it would just
/// add visual weight without information.
class StorefrontIdentityBlock extends StatelessWidget {
  final SellerProfile seller;
  final String? displayName;
  final int listingsCount;
  final int followersCount;
  final double? rating;
  final String listingsLabel;
  final String followersLabel;
  final String ratingLabel;
  final VoidCallback? onListingsTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onRatingTap;
  final String verifiedTooltip;

  const StorefrontIdentityBlock({
    super.key,
    required this.seller,
    required this.listingsCount,
    required this.followersCount,
    required this.rating,
    required this.listingsLabel,
    required this.followersLabel,
    required this.ratingLabel,
    required this.verifiedTooltip,
    this.displayName,
    this.onListingsTap,
    this.onFollowersTap,
    this.onRatingTap,
  });

  bool get _hasStoryRing => seller.subscriptionPlan != SubscriptionPlan.free;

  @override
  Widget build(BuildContext context) {
    final hasDisplayName = displayName != null && displayName!.isNotEmpty;
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
                  size: AvatarSize.xl,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: StorefrontStatsRow(
                  listingsCount: listingsCount,
                  followersCount: followersCount,
                  rating: rating,
                  listingsLabel: listingsLabel,
                  followersLabel: followersLabel,
                  ratingLabel: ratingLabel,
                  onListingsTap: onListingsTap,
                  onFollowersTap: onFollowersTap,
                  onRatingTap: onRatingTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasDisplayName) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    displayName!,
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
            const SizedBox(height: 4),
          ],
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
        padding: const EdgeInsets.all(2.5),
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
