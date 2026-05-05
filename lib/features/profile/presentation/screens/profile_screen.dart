import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_stats_card.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surfaceOf(context),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: LoadingIndicator());
            }

            if (state.hasError) {
              return ErrorView(
                failure: state.failure,
                onRetry: () {
                  context
                      .read<ProfileBloc>()
                      .add(const ProfileLoadRequested());
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
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: -AppSpacing.xl,
                          child: const ProfileStatsCard(
                            // TODO: wire to real stats from listings/saved blocs
                            activeListings: 0,
                            savedCount: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ACCOUNT
                    ProfileMenuSection(
                      title: 'HISOB',
                      tiles: [
                        ProfileMenuTile(
                          icon: Icons.person_outline,
                          title: 'Profilni tahrirlash',
                          onTap: () => context.push('/profile/edit'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.bookmark_outline,
                          title: 'Saqlanganlar',
                          onTap: () => context.push('/saved'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.language,
                          title: 'Til',
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

                    // ACTIVITY
                    ProfileMenuSection(
                      title: 'FAOLIYAT',
                      tiles: [
                        ProfileMenuTile(
                          icon: Icons.history,
                          title: 'Ko\'rishlar tarixi',
                          onTap: () => context.push('/history'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.favorite_outline,
                          title: 'Yoqtirilganlar',
                          onTap: () => context.push('/liked'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.local_fire_department_outlined,
                          title: 'Boost',
                          trailing: _NewBadge(),
                          onTap: () => context.push('/boost'),
                        ),
                      ],
                    ),

                    // SUPPORT
                    ProfileMenuSection(
                      title: 'YORDAM',
                      tiles: [
                        ProfileMenuTile(
                          icon: Icons.headset_mic_outlined,
                          title: 'Yordam markazi',
                          onTap: () => context.push('/help'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.notifications_outlined,
                          title: 'Bildirishnomalar',
                          onTap: () => context.push('/notifications/settings'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.shield_outlined,
                          title: 'Foydalanish shartlari',
                          onTap: () => context.push('/about'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Sign out
                    ProfileMenuTile(
                      icon: Icons.logout,
                      title: 'Chiqish',
                      iconColor: AppColors.error,
                      iconBackground: AppColors.errorSoft,
                      titleColor: AppColors.error,
                      showChevron: false,
                      onTap: () => _showLogoutDialog(context),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Footer
                    Center(
                      child: Text(
                        'Autogram · v1.0.0',
                        style: AppTypography.bodySmallStyle.copyWith(
                          color: AppColors.textTertiaryOf(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
    showDialog(
      context: context,
      builder: (dialogContext) {
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
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('Русский'),
                onTap: () {
                  context.read<ProfileBloc>().add(
                        const ProfileUpdateRequested(language: 'ru'),
                      );
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  context.read<ProfileBloc>().add(
                        const ProfileUpdateRequested(language: 'en'),
                      );
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chiqish'),
          content: const Text('Haqiqatan ham chiqmoqchimisiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
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

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'YANGI',
        style: AppTypography.labelSmallStyle.copyWith(
          color: AppColors.successDark,
          fontWeight: AppTypography.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
