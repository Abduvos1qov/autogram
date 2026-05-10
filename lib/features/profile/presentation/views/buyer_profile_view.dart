import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../navigation/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_stats_card.dart';

/// Buyer-side profile body. Extracted from the original `profile_screen.dart`
/// so [ProfileScreen] can dispatch to either this widget or the seller
/// storefront based on `profile.isSeller`.
class BuyerProfileView extends StatelessWidget {
  final UserProfile profile;

  const BuyerProfileView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Status bar over the dark green ProfileHeader needs light icons.
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ProfileHeader(profile: profile),
              const Positioned(
                left: 0,
                right: 0,
                bottom: -AppSpacing.xl,
                // Wired to 0 stats until the saved/views blocs surface counts
                // (tracked by buyer activity work — see profile architecture
                // notes).
                child: ProfileStatsCard(
                  activeListings: 0,
                  savedCount: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ACCOUNT
          ProfileMenuSection(
            title: 'profile.account_section'.tr(),
            tiles: [
              ProfileMenuTile(
                icon: Icons.person_outline,
                title: 'profile.edit'.tr(),
                onTap: () => context.push(RoutePaths.editProfile),
              ),
              ProfileMenuTile(
                icon: Icons.manage_accounts_outlined,
                title: 'profile.account_settings'.tr(),
                onTap: () => context.push(RoutePaths.accountSettings),
              ),
              ProfileMenuTile(
                icon: Icons.bookmark_outline,
                title: 'profile.saved'.tr(),
                onTap: () => context.push(RoutePaths.saved),
              ),
              ProfileMenuTile(
                icon: Icons.language,
                title: 'profile.language'.tr(),
                trailing: Text(
                  _languageCode(profile.language),
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
                onTap: () => _showLanguageDialog(context),
              ),
            ],
          ),

          // BUSINESS
          ProfileMenuSection(
            title: 'profile.business_section'.tr(),
            tiles: [
              ProfileMenuTile(
                icon: Icons.storefront_outlined,
                title: 'profile.become_seller'.tr(),
                subtitle: 'profile.become_seller_subtitle'.tr(),
                onTap: () => context.push(RoutePaths.upgrade),
              ),
            ],
          ),

          // ACTIVITY
          ProfileMenuSection(
            title: 'profile.activity_section'.tr(),
            tiles: [
              ProfileMenuTile(
                icon: Icons.history,
                title: 'profile.history'.tr(),
                onTap: () => context.push(RoutePaths.history),
              ),
              ProfileMenuTile(
                icon: Icons.favorite_outline,
                title: 'profile.liked'.tr(),
                onTap: () => context.push(RoutePaths.liked),
              ),
              ProfileMenuTile(
                icon: Icons.local_fire_department_outlined,
                title: 'profile.boost'.tr(),
                trailing: const _NewBadge(),
                onTap: () => context.push(RoutePaths.boost),
              ),
            ],
          ),

          // SUPPORT
          ProfileMenuSection(
            title: 'profile.support_section'.tr(),
            tiles: [
              ProfileMenuTile(
                icon: Icons.headset_mic_outlined,
                title: 'profile.help_center'.tr(),
                onTap: () => context.push(RoutePaths.help),
              ),
              ProfileMenuTile(
                icon: Icons.notifications_outlined,
                title: 'profile.notification_settings'.tr(),
                onTap: () => context.push(RoutePaths.notificationSettings),
              ),
              ProfileMenuTile(
                icon: Icons.shield_outlined,
                title: 'profile.terms'.tr(),
                onTap: () => context.push(RoutePaths.about),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Sign out — visually distinct (red) so it's never confused with a
          // routine menu item.
          Builder(
            builder: (context) {
              return ProfileMenuTile(
                icon: Icons.logout,
                title: 'profile.logout'.tr(),
                iconColor: AppColors.error,
                iconBackground: AppColors.errorSoft,
                titleColor: AppColors.error,
                showChevron: false,
                onTap: () => _showLogoutDialog(context),
              );
            },
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
          ],
        ),
      ),
    );
  }

  String _languageCode(String code) {
    switch (code) {
      case 'uz':
        return 'UZ';
      case 'ru':
        return 'RU';
      case 'en':
        return 'EN';
      default:
        return code.toUpperCase();
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('profile.language_dialog_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('profile.language_uz'.tr()),
                onTap: () {
                  context.read<ProfileBloc>().add(
                        const ProfileUpdateRequested(language: 'uz'),
                      );
                  context.setLocale(const Locale('uz'));
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: Text('profile.language_ru'.tr()),
                onTap: () {
                  context.read<ProfileBloc>().add(
                        const ProfileUpdateRequested(language: 'ru'),
                      );
                  context.setLocale(const Locale('ru'));
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: Text('profile.language_en'.tr()),
                onTap: () {
                  context.read<ProfileBloc>().add(
                        const ProfileUpdateRequested(language: 'en'),
                      );
                  context.setLocale(const Locale('en'));
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
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

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'profile.boost_new'.tr(),
        style: AppTypography.labelSmallStyle.copyWith(
          color: AppColors.successDark,
          fontWeight: AppTypography.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
