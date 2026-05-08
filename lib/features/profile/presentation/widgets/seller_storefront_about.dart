import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../seller/domain/entities/seller_profile.dart';

/// "About" tab content. Pure-presentation; data is read straight from the
/// SellerProfile passed in. Tappable rows use [onPhoneTap], [onTelegramTap],
/// etc.; pass `null` to render the row as static text.
class SellerStorefrontAbout extends StatelessWidget {
  final SellerProfile seller;
  final ValueChanged<String>? onPhoneTap;
  final ValueChanged<String>? onTelegramTap;
  final ValueChanged<String>? onInstagramTap;
  final ValueChanged<String>? onWebsiteTap;
  final ValueChanged<({double lat, double lng})>? onMapTap;

  const SellerStorefrontAbout({
    super.key,
    required this.seller,
    this.onPhoneTap,
    this.onTelegramTap,
    this.onInstagramTap,
    this.onWebsiteTap,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (seller.description != null && seller.description!.isNotEmpty)
          _Section(
            title: 'seller.storefront.about.description'.tr(),
            child: Text(
              seller.description!,
              style: AppTypography.bodyMedium(context).copyWith(height: 1.5),
            ),
          ),

        _Section(
          title: 'seller.storefront.about.business_type'.tr(),
          child: Row(
            children: [
              _businessTypeChip(context, seller.businessType),
              const SizedBox(width: 6),
              Text(
                'seller.storefront.about.member_since'.tr(
                  namedArgs: {'date': _formatYear(seller.createdAt)},
                ),
                style: AppTypography.bodySmall(context),
              ),
            ],
          ),
        ),

        _Section(
          title: 'seller.storefront.about.address'.tr(),
          child: _AddressBlock(
            address: seller.address,
            city: seller.city,
            district: seller.district,
            latitude: seller.latitude,
            longitude: seller.longitude,
            onMapTap: onMapTap,
          ),
        ),

        if (seller.contactPhones.isNotEmpty ||
            seller.telegram != null ||
            seller.instagram != null ||
            seller.website != null)
          _Section(
            title: 'seller.storefront.about.contact_phone'.tr(),
            child: Column(
              children: [
                for (final phone in seller.contactPhones)
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    label: phone,
                    color: AppColors.success,
                    onTap: onPhoneTap == null ? null : () => onPhoneTap!(phone),
                  ),
                if (seller.telegram != null && seller.telegram!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.send_rounded,
                    label: seller.telegram!,
                    color: AppColors.telegram,
                    onTap: onTelegramTap == null
                        ? null
                        : () => onTelegramTap!(seller.telegram!),
                  ),
                if (seller.instagram != null && seller.instagram!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.camera_alt_outlined,
                    label: seller.instagram!,
                    color: AppColors.instagram,
                    onTap: onInstagramTap == null
                        ? null
                        : () => onInstagramTap!(seller.instagram!),
                  ),
                if (seller.website != null && seller.website!.isNotEmpty)
                  _ContactRow(
                    icon: Icons.language_rounded,
                    label: seller.website!,
                    color: AppColors.info,
                    onTap: onWebsiteTap == null
                        ? null
                        : () => onWebsiteTap!(seller.website!),
                  ),
              ],
            ),
          ),

        if (seller.workingHours.isNotEmpty)
          _Section(
            title: 'seller.storefront.about.working_hours'.tr(),
            child: _WorkingHoursTable(hours: seller.workingHours),
          ),

        _Section(
          title: 'seller.storefront.about.subscription_label'.tr(),
          child: _SubscriptionRow(
            plan: seller.subscriptionPlan,
            expiresAt: seller.subscriptionExpiresAt,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _businessTypeChip(BuildContext context, BusinessType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Text(
        type.labelKey.tr(),
        style: AppTypography.labelMediumStyle.copyWith(
          color: AppColors.primaryDark,
          fontWeight: AppTypography.semiBold,
        ),
      ),
    );
  }

  String _formatYear(DateTime date) => date.year.toString();
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.labelSmallStyle.copyWith(
              color: AppColors.textTertiaryOf(context),
              letterSpacing: 1.2,
              fontWeight: AppTypography.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final String? address;
  final String? city;
  final String? district;
  final double? latitude;
  final double? longitude;
  final ValueChanged<({double lat, double lng})>? onMapTap;

  const _AddressBlock({
    required this.address,
    required this.city,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.onMapTap,
  });

  String? _line1() {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String? _line2() {
    final parts = <String>[];
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final line1 = _line1();
    final line2 = _line2();
    final hasAny = line1 != null || line2 != null;

    if (!hasAny) {
      return Text(
        'seller.storefront.about.no_address'.tr(),
        style: AppTypography.bodyMedium(context).copyWith(
          color: AppColors.textTertiaryOf(context),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final hasMap = latitude != null && longitude != null && onMapTap != null;
    return Material(
      color: AppColors.surfaceContainerOf(context),
      borderRadius: AppSpacing.borderRadiusMd,
      child: InkWell(
        onTap: hasMap
            ? () => onMapTap!((lat: latitude!, lng: longitude!))
            : null,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (line1 != null)
                      Text(
                        line1,
                        style: AppTypography.bodyLarge(context).copyWith(
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                    if (line2 != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        line2,
                        style: AppTypography.bodySmall(context),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasMap)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiaryOf(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium(context).copyWith(
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textTertiaryOf(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkingHoursTable extends StatelessWidget {
  final Map<String, WorkingHours> hours;

  const _WorkingHoursTable({required this.hours});

  static const _orderedDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const Map<String, String> _dayLabels = {
    'monday': 'Du',
    'tuesday': 'Se',
    'wednesday': 'Ch',
    'thursday': 'Pa',
    'friday': 'Ju',
    'saturday': 'Sh',
    'sunday': 'Ya',
  };

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final day in _orderedDays) {
      final h = hours[day];
      if (h == null) continue;
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  _dayLabels[day] ?? day,
                  style: AppTypography.bodyMedium(context).copyWith(
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                h.isClosed
                    ? 'seller.storefront.about.closed'.tr()
                    : '${h.open} – ${h.close}',
                style: AppTypography.bodyMedium(context).copyWith(
                  color: h.isClosed
                      ? AppColors.error
                      : AppColors.textPrimaryOf(context),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  final SubscriptionPlan plan;
  final DateTime? expiresAt;

  const _SubscriptionRow({
    required this.plan,
    required this.expiresAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primarySoft, AppColors.secondarySoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.7),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              size: 20,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan.labelKey.tr(),
                  style: AppTypography.titleMediumStyle.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                if (expiresAt != null && plan != SubscriptionPlan.free)
                  Text(
                    'seller.storefront.about.expires_at'.tr(
                      namedArgs: {'date': _formatDate(expiresAt!)},
                    ),
                    style: AppTypography.bodySmallStyle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }
}
