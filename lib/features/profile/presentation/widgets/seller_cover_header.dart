import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../seller/domain/entities/seller_profile.dart';

/// Cover banner + business identity block. Designed to live inside a
/// `SliverAppBar.flexibleSpace`, so it tolerates being clipped/scrolled with
/// the parent. The avatar overlaps the cover image bottom edge by half its
/// diameter — the parent screen reserves vertical space for the overlap.
///
/// [coverHeight] is the height of the cover image (excluding the avatar
/// overlap). [avatarOverlap] controls how far the avatar sits below the
/// cover; defaults to half the avatar diameter.
class SellerCoverHeader extends StatelessWidget {
  final SellerProfile seller;

  /// Height of the cover image (does NOT include the avatar's overlap below).
  final double coverHeight;

  /// Diameter of the circular avatar.
  final double avatarSize;

  const SellerCoverHeader({
    super.key,
    required this.seller,
    this.coverHeight = 200,
    this.avatarSize = 96,
  });

  @override
  Widget build(BuildContext context) {
    final tierBadge = _planBadge(seller.subscriptionPlan);

    return SizedBox(
      height: coverHeight + (avatarSize / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover image.
          Positioned.fill(
            bottom: avatarSize / 2,
            child: _CoverImage(url: seller.coverUrl),
          ),

          // Tier badge — top-right of cover.
          if (tierBadge != null)
            Positioned(
              top: 8 + MediaQuery.of(context).padding.top,
              right: AppSpacing.md,
              child: _TierBadge(label: tierBadge),
            ),

          // Avatar overlapping cover bottom.
          Positioned(
            left: AppSpacing.lg,
            bottom: 0,
            child: _Avatar(
              logoUrl: seller.logoUrl,
              businessName: seller.businessName,
              size: avatarSize,
              isVerified: seller.isVerified,
            ),
          ),
        ],
      ),
    );
  }

  String? _planBadge(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return null;
      case SubscriptionPlan.pro:
        return 'seller.storefront.tier_badge.pro'.tr();
      case SubscriptionPlan.premium:
        return 'seller.storefront.tier_badge.premium'.tr();
      case SubscriptionPlan.enterprise:
        return 'seller.storefront.tier_badge.enterprise'.tr();
    }
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;

  const _CoverImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            color: AppColors.shimmerBaseOf(context),
          ),
          errorWidget: (_, _, _) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
        ),
        // Bottom darken overlay so any text on the cover stays legible.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, AppColors.overlayDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? logoUrl;
  final String businessName;
  final double size;
  final bool isVerified;

  const _Avatar({
    required this.logoUrl,
    required this.businessName,
    required this.size,
    required this.isVerified,
  });

  String get _initials {
    final parts = businessName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = AppColors.surfaceOf(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ringColor,
            border: Border.all(color: ringColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: (logoUrl != null && logoUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: logoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _initialsCircle(context),
                    errorWidget: (_, _, _) => _initialsCircle(context),
                  )
                : _initialsCircle(context),
          ),
        ),
        if (isVerified)
          Positioned(
            right: 0,
            bottom: 4,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.verifiedBadge,
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2.5),
              ),
              child: Icon(
                Icons.check,
                size: size * 0.18,
                color: AppColors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _initialsCircle(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.white,
          fontSize: size * 0.34,
          fontWeight: AppTypography.bold,
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String label;

  const _TierBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.premiumGold,
        borderRadius: AppSpacing.borderRadiusSm,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: AppColors.black,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmallStyle.copyWith(
              color: AppColors.black,
              fontWeight: AppTypography.bold,
              letterSpacing: 1.2,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
