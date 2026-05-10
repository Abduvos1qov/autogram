import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../core/theme/app_colors.dart';
import '../features/chat/presentation/bloc/conversations_bloc.dart';
import '../features/chat/presentation/bloc/conversations_state.dart';

/// Navigation shell with a liquid-glass floating pill bottom navigation bar.
///
/// Branch indices in the router are preserved:
///   0 = Home, 1 = Reels, 2 = Search, 3 = Chat, 4 = Profile.
/// The pill displays branches [0, 1, 3, 4]; Search (branch 2) is rendered as
/// a separate circular CTA next to the pill.
///
/// Performance contract — three principles enforced everywhere here:
/// 1. Glass shapes never animate (size/position). Only their inner [Icon] is
///    animated via [ScaleTransition]. This avoids the package's documented
///    memory-spike pitfall (Flutter bug #138627).
/// 2. The pill background, the active-tab indicator, and the search button each
///    own their [LiquidGlassLayer] (3 layers total). Three layers are required
///    because each shape has a distinct [LiquidGlassSettings.glassColor]
///    (neutral / primary tint / stronger primary tint).
/// 3. A [RepaintBoundary] isolates the bar from the screen above (notably the
///    Reels video paint cycle) so glass repaints don't bubble up.
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
        child: RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _GlassPill(
                    currentIndex: currentIndex,
                    onTap: _goBranch,
                    buildChatBadge: _buildChatBadge,
                  ),
                ),
                const SizedBox(width: 12),
                _GlassSearchButton(
                  isActive: isSearchActive,
                  label: 'search.title'.tr(),
                  onTap: () => _goBranch(_searchBranchIndex),
                ),
              ],
            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Pill (4 tabs + active glass indicator)
// ─────────────────────────────────────────────────────────────────────────────

class _GlassPill extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget Function(Widget icon) buildChatBadge;

  const _GlassPill({
    required this.currentIndex,
    required this.onTap,
    required this.buildChatBadge,
  });

  static const double _height = 64;
  static const double _radius = 32;
  static const double _tabSize = 48;
  static const double _horizontalPadding = 6;

  // Maps a router branch index (0,1,3,4) to a pill slot index (0,1,2,3).
  // Search (branch 2) lives outside the pill, so it never appears here.
  static int _branchToSlot(int branch) => branch <= 1 ? branch : branch - 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillSettings = _pillSettings(isDark);
    final activeTabSettings = _activeTabSettings(context);

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final usable = constraints.maxWidth - 2 * _horizontalPadding;
          final slotWidth = usable / 4;
          final slot = _branchToSlot(currentIndex);
          // Search active → branch index is 2, slot is invalid; hide indicator.
          final indicatorVisible = currentIndex != 2;
          final indicatorLeft = _horizontalPadding +
              slotWidth * slot +
              (slotWidth - _tabSize) / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Drop shadow lives outside the glass layer so it isn't blurred
              // by the backdrop filter (which would smear it into the canvas).
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_radius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.45 : 0.10,
                          ),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.20 : 0.04,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Glass layer 1 — neutral pill background.
              Positioned.fill(
                child: LiquidGlass.withOwnLayer(
                  shape: const LiquidRoundedSuperellipse(
                    borderRadius: _radius,
                  ),
                  settings: pillSettings,
                  child: const SizedBox.expand(),
                ),
              ),

              // Glass layer 2 — primary-tinted active-tab indicator.
              // Position is computed from currentIndex; we deliberately do NOT
              // wrap in AnimatedPositioned (shape position animation triggers
              // per-frame re-render and memory spikes per package warning).
              if (indicatorVisible)
                Positioned(
                  left: indicatorLeft,
                  top: (_height - _tabSize) / 2,
                  width: _tabSize,
                  height: _tabSize,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: KeyedSubtree(
                      key: ValueKey<int>(currentIndex),
                      child: LiquidGlass.withOwnLayer(
                        shape: const LiquidOval(),
                        settings: activeTabSettings,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),

              // Tab icons sit on top of both glass layers.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
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
              ),
            ],
          );
        },
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
          child: SizedBox(
            width: _GlassPill._tabSize,
            height: _GlassPill._tabSize,
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

// ─────────────────────────────────────────────────────────────────────────────
// Search button — separate primary-tinted glass orb
// ─────────────────────────────────────────────────────────────────────────────

class _GlassSearchButton extends StatefulWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const _GlassSearchButton({
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  State<_GlassSearchButton> createState() => _GlassSearchButtonState();
}

class _GlassSearchButtonState extends State<_GlassSearchButton>
    with SingleTickerProviderStateMixin {
  static const double _size = 64;

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
    final settings = _searchButtonSettings(context, widget.isActive);

    return Semantics(
      button: true,
      selected: widget.isActive,
      label: widget.label,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // let drop shadow extend outside
              children: [
                // Drop shadow outside the glass layer (see _GlassPill rationale).
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(
                              alpha: isDark ? 0.5 : 0.32,
                            ),
                            blurRadius: widget.isActive ? 20 : 14,
                            offset: const Offset(0, 6),
                            spreadRadius: widget.isActive ? 1 : 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // The glass orb.
                LiquidGlass.withOwnLayer(
                  shape: const LiquidOval(),
                  settings: settings,
                  child: const SizedBox.expand(),
                ),
                // Icon on top of glass.
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  scale: widget.isActive ? 1.08 : 1.0,
                  child: const Icon(
                    Icons.search_rounded,
                    size: 26,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass settings — built once per build, never per-frame.
// Placed as top-level functions so they don't capture widget state and so the
// optimizer can inline them. lightAngle uses radians: pi/4 ≈ 45° (top-left
// highlight, matches Apple iOS 26 reference renderings).
// ─────────────────────────────────────────────────────────────────────────────

const double _lightAngleTopLeft = math.pi / 4;

LiquidGlassSettings _pillSettings(bool isDark) {
  return LiquidGlassSettings(
    thickness: 12,
    blur: 10,
    glassColor: isDark
        ? const Color(0x66272727) // 40% surfaceContainerHighDark
        : const Color(0x80FFFFFF), // 50% white
    lightAngle: _lightAngleTopLeft,
    lightIntensity: isDark ? 0.9 : 1.2,
    ambientStrength: isDark ? 0.2 : 0.3,
    refractiveIndex: 1.45,
    saturation: 1.1,
    chromaticAberration: 0,
  );
}

LiquidGlassSettings _activeTabSettings(BuildContext context) {
  final primary = AppColors.primaryOf(context);
  return LiquidGlassSettings(
    thickness: 14,
    blur: 8,
    glassColor: primary.withValues(alpha: 0.55),
    lightAngle: _lightAngleTopLeft,
    lightIntensity: 1.4,
    ambientStrength: 0.35,
    refractiveIndex: 1.45,
    saturation: 1.1,
    chromaticAberration: 0,
  );
}

LiquidGlassSettings _searchButtonSettings(BuildContext context, bool isActive) {
  final primary = AppColors.primaryOf(context);
  return LiquidGlassSettings(
    thickness: 16,
    blur: 8,
    glassColor: primary.withValues(alpha: isActive ? 0.85 : 0.70),
    lightAngle: _lightAngleTopLeft,
    lightIntensity: 1.5,
    ambientStrength: 0.4,
    refractiveIndex: 1.45,
    saturation: 1.1,
    chromaticAberration: 0,
  );
}
