import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/media/avatar.dart';
import '../../../../navigation/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_menu_tile.dart';

/// Full-screen menu page for the seller storefront. Replaces the previous
/// end-drawer pattern: pushed as a route via `context.push` so it covers the
/// bottom navigation, leaving a back button as the only way out.
///
/// Plan-gated business items (Team / Activity / Seats / Subscription) are
/// hidden for Free-tier sellers.
class StorefrontMenuScreen extends StatelessWidget {
  final UserProfile profile;
  final SellerProfile seller;

  const StorefrontMenuScreen({
    super.key,
    required this.profile,
    required this.seller,
  });

  bool get _isFreeTier => seller.subscriptionPlan == SubscriptionPlan.free;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(context),
        surfaceTintColor: AppColors.surfaceOf(context),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          'profile.storefront.menu_screen.title'.tr(),
          style: AppTypography.titleLarge(context).copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            _MenuHeader(profile: profile, seller: seller),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, thickness: 0.5),
            ProfileMenuSection(
              title:
                  'profile.storefront.drawer.section_marketplace'.tr(),
              tiles: [
                ProfileMenuTile(
                  icon: Icons.bookmark_outline,
                  title: 'profile.saved'.tr(),
                  onTap: () => context.push(RoutePaths.saved),
                ),
                ProfileMenuTile(
                  icon: Icons.favorite_outline,
                  title: 'profile.liked'.tr(),
                  onTap: () => context.push(RoutePaths.liked),
                ),
                ProfileMenuTile(
                  icon: Icons.local_fire_department_outlined,
                  title: 'profile.boost'.tr(),
                  onTap: () => context.push(RoutePaths.boost),
                ),
              ],
            ),
            if (!_isFreeTier)
              ProfileMenuSection(
                title:
                    'profile.storefront.drawer.section_business'.tr(),
                tiles: [
                  ProfileMenuTile(
                    icon: Icons.groups_outlined,
                    title: 'profile.team_management'.tr(),
                    onTap: () => context.push(
                      RoutePaths.teamMembers,
                      extra: seller.id,
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.history_rounded,
                    title: 'profile.activity_log'.tr(),
                    onTap: () => context.push(
                      RoutePaths.activityLog,
                      extra: {
                        'sellerProfileId': seller.id,
                        'activities': const [],
                      },
                    ),
                  ),
                  ProfileMenuTile(
                    icon: Icons.event_seat_outlined,
                    title: 'profile.seat_management'.tr(),
                    onTap: () => context.push(RoutePaths.seatManagement),
                  ),
                  ProfileMenuTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'profile.subscription'.tr(),
                    trailing: _PlanBadge(plan: seller.subscriptionPlan),
                    onTap: () => context.push(RoutePaths.subscription),
                  ),
                ],
              ),
            ProfileMenuSection(
              title: 'profile.storefront.drawer.section_account'.tr(),
              tiles: [
                ProfileMenuTile(
                  icon: Icons.person_outline,
                  title: 'profile.edit'.tr(),
                  onTap: () => context.push(RoutePaths.editProfile),
                ),
                ProfileMenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'profile.notification_settings'.tr(),
                  onTap: () =>
                      context.push(RoutePaths.notificationSettings),
                ),
                ProfileMenuTile(
                  icon: Icons.settings_outlined,
                  title: 'profile.settings'.tr(),
                  onTap: () => context.push(RoutePaths.settings),
                ),
              ],
            ),
            ProfileMenuSection(
              title: 'profile.storefront.drawer.section_help'.tr(),
              tiles: [
                ProfileMenuTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'profile.help_center'.tr(),
                  onTap: () => context.push(RoutePaths.help),
                ),
                ProfileMenuTile(
                  icon: Icons.shield_outlined,
                  title: 'profile.about'.tr(),
                  onTap: () => context.push(RoutePaths.about),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ProfileMenuTile(
              icon: Icons.logout,
              title: 'profile.logout'.tr(),
              iconColor: AppColors.error,
              iconBackground: AppColors.errorSoft,
              titleColor: AppColors.error,
              showChevron: false,
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'profile.app_version'.tr(),
                style: AppTypography.bodySmallStyle.copyWith(
                  color: AppColors.textTertiaryOf(context),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('profile.logout'.tr()),
          content: Text('auth.logout_confirm'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('common.cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Pop the menu page itself before firing logout — the router
                // redirect will pull us to /login as soon as AuthBloc
                // transitions to AuthUnauthenticated.
                if (context.canPop()) context.pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: Text('profile.logout'.tr()),
            ),
          ],
        );
      },
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final UserProfile profile;
  final SellerProfile seller;

  const _MenuHeader({required this.profile, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: seller.logoUrl ?? profile.avatarUrl,
            name: seller.businessName,
            size: AvatarSize.lg,
          ),
          AppSpacing.gapHorizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        seller.businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium(context).copyWith(
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                    ),
                    if (seller.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.verifiedColor,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email ?? profile.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(context).copyWith(
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final SubscriptionPlan plan;

  const _PlanBadge({required this.plan});

  Color _bg(BuildContext context) {
    switch (plan) {
      case SubscriptionPlan.free:
        return AppColors.dividerOf(context);
      case SubscriptionPlan.pro:
        return AppColors.primaryOf(context).withValues(alpha: 0.16);
      case SubscriptionPlan.premium:
        return AppColors.premiumGold.withValues(alpha: 0.18);
      case SubscriptionPlan.enterprise:
        return AppColors.accent.withValues(alpha: 0.18);
    }
  }

  Color _fg(BuildContext context) {
    switch (plan) {
      case SubscriptionPlan.free:
        return AppColors.textSecondaryOf(context);
      case SubscriptionPlan.pro:
        return AppColors.primaryOf(context);
      case SubscriptionPlan.premium:
        return AppColors.premiumGold;
      case SubscriptionPlan.enterprise:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        plan.labelKey.tr(),
        style: AppTypography.labelSmallStyle.copyWith(
          color: _fg(context),
          fontWeight: AppTypography.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
