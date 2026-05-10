import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../navigation/route_names.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/presentation/widgets/profile_menu_section.dart';
import '../../../profile/presentation/widgets/profile_menu_tile.dart';

/// Hub for editing the user's auth credentials. Pure router page — every
/// concrete change happens on its own sub-screen so each one can run its own
/// step machine without bleeding state across flows.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(context),
        title: Text(
          'account_settings.title'.tr(),
          style: AppTypography.titleMedium(context).copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (a, b) => a.profile != b.profile,
          builder: (context, state) {
            final profile = state.profile;
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                _CurrentValuesHeader(
                  email: profile?.email,
                  phone: profile?.phone,
                ),
                const SizedBox(height: AppSpacing.sm),
                ProfileMenuSection(
                  title: 'account_settings.section_credentials'.tr(),
                  tiles: [
                    ProfileMenuTile(
                      icon: Icons.alternate_email,
                      title: 'account_settings.change_email'.tr(),
                      onTap: () => context.push(RoutePaths.changeEmail),
                    ),
                    ProfileMenuTile(
                      icon: Icons.lock_outline,
                      title: 'account_settings.change_password'.tr(),
                      onTap: () => context.push(RoutePaths.changePassword),
                    ),
                    ProfileMenuTile(
                      icon: Icons.phone_iphone,
                      title: 'account_settings.change_phone'.tr(),
                      onTap: () => context.push(RoutePaths.changePhone),
                    ),
                  ],
                ),
                ProfileMenuSection(
                  title: 'account_settings.section_danger'.tr(),
                  tiles: [
                    ProfileMenuTile(
                      icon: Icons.delete_outline,
                      title: 'account_settings.delete_account'.tr(),
                      iconColor: AppColors.error,
                      iconBackground: AppColors.errorSoft,
                      titleColor: AppColors.error,
                      onTap: () => _showDeleteDialog(context),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('account_settings.delete_account'.tr()),
          content: Text('account_settings.delete_account_warning'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('common.cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context
                    .read<ProfileBloc>()
                    .add(const ProfileDeleteRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: Text('account_settings.delete_account_confirm'.tr()),
            ),
          ],
        );
      },
    );
  }
}

class _CurrentValuesHeader extends StatelessWidget {
  final String? email;
  final String? phone;

  const _CurrentValuesHeader({required this.email, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerOf(context),
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(
              icon: Icons.alternate_email,
              label: 'account_settings.current_email'.tr(),
              value: email ?? 'account_settings.not_set'.tr(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Divider(height: 1, color: AppColors.dividerOf(context)),
            const SizedBox(height: AppSpacing.sm),
            _Row(
              icon: Icons.phone_iphone,
              label: 'account_settings.current_phone'.tr(),
              value: phone ?? 'account_settings.not_set'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiaryOf(context)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.textTertiaryOf(context),
                ),
              ),
              Text(
                value,
                style: AppTypography.bodyMedium(context).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
