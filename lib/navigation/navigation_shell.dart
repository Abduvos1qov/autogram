import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/presentation/bloc/conversations_bloc.dart';

/// Navigation shell with bottom navigation bar

class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => _onItemTapped(index),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Bosh sahifa',
        ),
        const NavigationDestination(
          icon: Icon(Icons.play_circle_outline),
          selectedIcon: Icon(Icons.play_circle),
          label: 'Reels',
        ),
        const NavigationDestination(
          icon: Icon(Icons.search),
          selectedIcon: Icon(Icons.search),
          label: 'Qidiruv',
        ),
        _buildChatDestination(context),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  NavigationDestination _buildChatDestination(BuildContext context) {
    return NavigationDestination(
      icon: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          if (state.unreadCount > 0) {
            return Badge(
              label: Text('${state.unreadCount}'),
              child: const Icon(Icons.chat_bubble_outline),
            );
          }
          return const Icon(Icons.chat_bubble_outline);
        },
      ),
      selectedIcon: const Icon(Icons.chat_bubble),
      label: 'Xabarlar',
    );
  }

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
