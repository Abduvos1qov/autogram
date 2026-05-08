import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../di/injection.dart';

/// Onboarding screen - introduces app features

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Translations are resolved at build time so locale switches take effect
  // without rebuilding the controller.
  List<OnboardingPage> get _pages => [
        OnboardingPage(
          icon: Icons.video_library_outlined,
          title: 'auth.onboarding_screen.page1_title'.tr(),
          description: 'auth.onboarding_screen.page1_description'.tr(),
        ),
        OnboardingPage(
          icon: Icons.search,
          title: 'auth.onboarding_screen.page2_title'.tr(),
          description: 'auth.onboarding_screen.page2_description'.tr(),
        ),
        OnboardingPage(
          icon: Icons.chat_bubble_outline,
          title: 'auth.onboarding_screen.page3_title'.tr(),
          description: 'auth.onboarding_screen.page3_description'.tr(),
        ),
      ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await sl<StorageService>().setOnboardingComplete();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'auth.onboarding_screen.skip'.tr(),
                  style: AppTypography.labelLarge(context).copyWith(
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),

            AppSpacing.gapVerticalXl,

            // Next button
            Padding(
              padding: AppSpacing.screenPaddingHorizontal,
              child: PrimaryButton(
                text: _currentPage == _pages.length - 1
                    ? 'auth.onboarding_screen.start'.tr()
                    : 'auth.onboarding_screen.next'.tr(),
                onPressed: _nextPage,
              ),
            ),

            AppSpacing.gapVerticalLg,
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.gapVerticalXl,
          Text(
            page.title,
            style: AppTypography.headlineMedium(context),
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapVerticalMd,
          Text(
            page.description,
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.grey300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
