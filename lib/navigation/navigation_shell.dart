import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/chat/presentation/bloc/conversations_bloc.dart';
import '../features/chat/presentation/bloc/conversations_state.dart';

/// Navigation shell with floating pill bottom navigation bar.
///
/// Branch indices in the router are preserved:
///   0 = Home, 1 = Reels, 2 = Search, 3 = Chat, 4 = Profile.
/// The pill displays branches [0, 1, 3, 4]; Search (branch 2) is rendered as
/// a separate circular CTA next to the pill.
///
/// Design notes:
/// - Theme-aware: pill surface, borders, and shadow opacity adapt to light/
///   dark mode via [AppColors] context helpers.
/// - Animations: spring-bounce on tap, animated icon swap (outline ⇄ filled),
///   smooth indicator background and shadow transitions.
/// - Haptic light-impact feedback on every branch switch.
/// - Accessibility: each tap target is wrapped in [Semantics] with a localized
///   label and a selected-state hint for screen readers.
class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  static const int _searchBranchIndex = 2;

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final isSearchActive = currentIndex == _searchBranchIndex;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _Pill(
                  currentIndex: currentIndex,
                  onTap: _goBranch,
                  buildChatBadge: _buildChatBadge,
                ),
              ),
              const SizedBox(width: 12),
              _SearchButton(
                isActive: isSearchActive,
                label: 'search.title'.tr(),
                onTap: () => _goBranch(_searchBranchIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildChatBadge(Widget icon) {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
      buildWhen: (prev, curr) => prev.unreadCount != curr.unreadCount,
      builder: (context, state) {
        if (state.unreadCount > 0) {
          return Badge(
            label: Text('${state.unreadCount}'),
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
            child: icon,
          );
        }
        return icon;
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget Function(Widget icon) buildChatBadge;

  const _Pill({
    required this.currentIndex,
    required this.onTap,
    required this.buildChatBadge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pillColor = isDark
        ? AppColors.surfaceContainerHighDark
        : AppColors.surfaceLight;
    final borderColor = isDark
        ? AppColors.borderDarkSubtle
        : AppColors.grey200;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PillTab(
            outlineIcon: Icons.home_outlined,
            filledIcon: Icons.home_rounded,
            label: 'home.title'.tr(),
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _PillTab(
            outlineIcon: Icons.play_circle_outline_rounded,
            filledIcon: Icons.play_circle_rounded,
            label: 'reels.title'.tr(),
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _PillTab(
            outlineIcon: Icons.chat_bubble_outline_rounded,
            filledIcon: Icons.chat_bubble_rounded,
            label: 'chat.title'.tr(),
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
            wrapBadge: buildChatBadge,
          ),
          _PillTab(
            outlineIcon: Icons.person_outline_rounded,
            filledIcon: Icons.person_rounded,
            label: 'profile.title'.tr(),
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatefulWidget {
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Widget Function(Widget icon)? wrapBadge;

  const _PillTab({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.wrapBadge,
  });

  @override
  State<_PillTab> createState() => _PillTabState();
}

class _PillTabState extends State<_PillTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    // Spring bounce: 1.0 → 0.88 (compress) → 1.06 (overshoot) → 1.0 (settle).
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _bounceController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = AppColors.primaryOf(context);
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.grey500;

    final iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Icon(
        widget.isActive ? widget.filledIcon : widget.outlineIcon,
        key: ValueKey<bool>(widget.isActive),
        size: 24,
        color: widget.isActive ? AppColors.white : inactiveColor,
      ),
    );

    return Semantics(
      button: true,
      selected: widget.isActive,
      label: widget.label,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.isActive ? activeBg : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: activeBg.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.wrapBadge != null
                  ? widget.wrapBadge!(iconWidget)
                  : iconWidget,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatefulWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const _SearchButton({
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<_SearchButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _bounceController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primaryOf(context);
    final secondary = AppColors.secondaryOf(context);

    // Idle: vibrant brand gradient (CTA energy).
    // Active: solid primary, matching pill tab selection — visual consistency.
    // Both keep `gradient` non-null so AnimatedContainer can interpolate.
    final idleGradient = LinearGradient(
      colors: [primary, secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final activeGradient = LinearGradient(
      colors: [primary, primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Semantics(
      button: true,
      selected: widget.isActive,
      label: widget.label,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: widget.isActive ? activeGradient : idleGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: isDark ? 0.5 : 0.35),
                  blurRadius: widget.isActive ? 20 : 14,
                  offset: const Offset(0, 6),
                  spreadRadius: widget.isActive ? 1 : 0,
                ),
              ],
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              scale: widget.isActive ? 1.08 : 1.0,
              child: const Icon(
                Icons.search_rounded,
                size: 26,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
