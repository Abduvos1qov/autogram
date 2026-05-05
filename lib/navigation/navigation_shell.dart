import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/chat/presentation/bloc/conversations_bloc.dart';

/// Navigation shell with floating pill bottom navigation bar.
///
/// Branch indices in the router are preserved:
///   0 = Home, 1 = Reels, 2 = Search, 3 = Chat, 4 = Profile.
/// The pill displays branches [0, 1, 3, 4]; Search (branch 2) is rendered as
/// a separate circular button next to the pill.

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
        minimum: const EdgeInsets.only(bottom: 0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: _Pill(
                  currentIndex: currentIndex,
                  onTap: _goBranch,
                  buildChatBadge: _buildChatBadge,
                ),
              ),
              const SizedBox(width: 8),
              _SearchButton(
                isActive: isSearchActive,
                onTap: () => _goBranch(_searchBranchIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildChatBadge(Widget icon) {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
      builder: (context, state) {
        if (state.unreadCount > 0) {
          return Badge(
            label: Text('${state.unreadCount}'),
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
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PillTab(
            icon: Icons.home_outlined,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _PillTab(
            icon: Icons.menu_book_outlined,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _PillTab(
            icon: Icons.chat_bubble_outline,
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
            wrapBadge: buildChatBadge,
          ),
          _PillTab(
            icon: Icons.menu,
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Widget Function(Widget icon)? wrapBadge;

  const _PillTab({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.wrapBadge,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 22,
      color: isActive ? AppColors.secondary : Colors.white,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: wrapBadge != null ? wrapBadge!(iconWidget) : iconWidget,
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _SearchButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.search,
          size: 26,
          color: isActive ? AppColors.secondary : Colors.white,
        ),
      ),
    );
  }
}
