import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// User avatar with various sizes

enum AvatarSize { xs, sm, md, lg, xl, xxl }

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final AvatarSize size;
  final bool isVerified;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showBorder;
  final Color borderColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AvatarSize.md,
    this.isVerified = false,
    this.onTap,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor = AppColors.primary,
  });

  double get _size {
    switch (size) {
      case AvatarSize.xs:
        return AppSpacing.avatarXs;
      case AvatarSize.sm:
        return AppSpacing.avatarSm;
      case AvatarSize.md:
        return AppSpacing.avatarMd;
      case AvatarSize.lg:
        return AppSpacing.avatarLg;
      case AvatarSize.xl:
        return AppSpacing.avatarXl;
      case AvatarSize.xxl:
        return AppSpacing.avatarXxl;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.xs:
        return 10;
      case AvatarSize.sm:
        return 12;
      case AvatarSize.md:
        return 14;
      case AvatarSize.lg:
        return 20;
      case AvatarSize.xl:
        return 28;
      case AvatarSize.xxl:
        return 36;
    }
  }

  double get _verifiedSize {
    switch (size) {
      case AvatarSize.xs:
        return 10;
      case AvatarSize.sm:
        return 12;
      case AvatarSize.md:
        return 14;
      case AvatarSize.lg:
        return 18;
      case AvatarSize.xl:
        return 22;
      case AvatarSize.xxl:
        return 28;
    }
  }

  String get _initials {
    if (name == null || name!.isEmpty) return '?';

    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(color: borderColor, width: 2)
                  : null,
            ),
            child: ClipOval(
              child: _buildContent(),
            ),
          ),
          if (isVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: _verifiedSize,
                height: _verifiedSize,
                decoration: BoxDecoration(
                  color: AppColors.verifiedColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: _verifiedSize * 0.6,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: backgroundColor ?? _getBackgroundColor(),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: AppColors.white,
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (name == null || name!.isEmpty) return AppColors.grey400;

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.info,
      AppColors.warning,
      AppColors.primaryLight,
      AppColors.secondaryDark,
      AppColors.accentDark,
    ];

    final hash = name!.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return colors[hash % colors.length];
  }
}

/// Seller logo avatar with business styling

class SellerLogo extends StatelessWidget {
  final String? logoUrl;
  final String? businessName;
  final AvatarSize size;
  final bool isVerified;
  final VoidCallback? onTap;

  const SellerLogo({
    super.key,
    this.logoUrl,
    this.businessName,
    this.size = AvatarSize.md,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      imageUrl: logoUrl,
      name: businessName,
      size: size,
      isVerified: isVerified,
      onTap: onTap,
      backgroundColor: AppColors.grey100,
    );
  }
}

/// Story-style avatar with gradient border

class StoryAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final bool hasUnseenStory;
  final VoidCallback? onTap;
  final double size;

  const StoryAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.hasUnseenStory = false,
    this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasUnseenStory ? AppColors.storyGradient : null,
              border: hasUnseenStory
                  ? null
                  : Border.all(color: AppColors.grey300, width: 1),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: AppAvatar(
                imageUrl: imageUrl,
                name: name,
                size: AvatarSize.lg,
              ),
            ),
          ),
          if (name != null) ...[
            AppSpacing.gapVerticalXs,
            SizedBox(
              width: size,
              child: Text(
                name!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
