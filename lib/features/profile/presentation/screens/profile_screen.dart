import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../core/widgets/media/avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';

/// Profile screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state.hasError) {
            return ErrorView(
              failure: state.failure,
              onRetry: () {
                context.read<ProfileBloc>().add(const ProfileLoadRequested());
              },
            );
          }

          if (state.profile == null) {
            return const SizedBox.shrink();
          }

          final profile = state.profile!;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const ProfileLoadRequested());
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      AppAvatar(
                        imageUrl: profile.avatarUrl,
                        name: profile.fullName,
                        size: AvatarSize.xl,
                        isVerified: profile.isVerified,
                      ),
                      AppSpacing.gapVerticalMd,
                      Text(
                        profile.fullName,
                        style: AppTypography.headlineSmall,
                      ),
                      AppSpacing.gapVerticalXs,
                      Text(
                        profile.phone,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (profile.isSeller) ...[
                        AppSpacing.gapVerticalXs,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Sotuvchi',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapVerticalXl,

                // Menu items
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Profilni tahrirlash',
                  onTap: () => context.push('/profile/edit'),
                ),
                _buildMenuItem(
                  icon: Icons.bookmark_border,
                  title: 'Saqlanganlar',
                  onTap: () => context.push('/saved'),
                ),
                _buildMenuItem(
                  icon: Icons.favorite_border,
                  title: 'Yoqtirilganlar',
                  onTap: () => context.push('/liked'),
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'Ko\'rishlar tarixi',
                  onTap: () => context.push('/history'),
                ),

                if (!profile.isSeller) ...[
                  const Divider(height: 32),
                  _buildMenuItem(
                    icon: Icons.storefront,
                    title: 'Sotuvchi bo\'lish',
                    subtitle: 'E\'lon joylash imkoniyati',
                    onTap: () => context.push('/upgrade'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Yangi',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],

                const Divider(height: 32),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Bildirishnomalar',
                  onTap: () => context.push('/notifications/settings'),
                ),
                _buildMenuItem(
                  icon: Icons.language,
                  title: 'Til',
                  subtitle: _getLanguageName(profile.language),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Yordam',
                  onTap: () => context.push('/help'),
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'Ilova haqida',
                  onTap: () => context.push('/about'),
                ),

                const Divider(height: 32),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Chiqish',
                  textColor: AppColors.error,
                  onTap: () => _showLogoutDialog(context),
                ),

                AppSpacing.gapVerticalXl,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'uz':
        return 'O\'zbekcha';
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tilni tanlang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('O\'zbekcha'),
                onTap: () {
                  context.read<ProfileBloc>().add(
                        const ProfileUpdateRequested(language: 'uz'),
                      );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Русский'),
                onTap: () {
                  context.read<ProfileBloc>().add(
                        const ProfileUpdateRequested(language: 'ru'),
                      );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  context.read<ProfileBloc>().add(
                        const ProfileUpdateRequested(language: 'en'),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chiqish'),
          content: const Text('Haqiqatan ham chiqmoqchimisiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Chiqish'),
            ),
          ],
        );
      },
    );
  }
}
