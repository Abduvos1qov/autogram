import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/screens/conversations_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/listing/presentation/screens/listing_detail_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/reels/presentation/screens/reels_screen.dart';
import '../features/saved/presentation/screens/saved_screen.dart';
import '../features/search/presentation/screens/filter_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/seller/presentation/screens/team_members_screen.dart';
import '../features/seller/presentation/screens/add_member_screen.dart';
import '../features/seller/presentation/screens/member_detail_screen.dart';
import '../features/seller/presentation/screens/activity_log_screen.dart';
import '../features/seller/domain/entities/activity_log.dart';
import 'navigation_shell.dart';
import 'route_names.dart';

/// App router configuration using GoRouter

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthRoute = state.matchedLocation == RoutePaths.splash ||
          state.matchedLocation == RoutePaths.onboarding ||
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.otp ||
          state.matchedLocation == RoutePaths.register;

      // If initial check, stay on splash
      if (authState is AuthInitial) {
        return RoutePaths.splash;
      }

      // During auth flow (loading, OTP sent, needs registration, etc.)
      // don't redirect — let BlocConsumer in screens handle navigation
      if (authState is AuthLoading ||
          authState is AuthOtpSent ||
          authState is AuthOtpResent ||
          authState is AuthNeedsRegistration ||
          authState is AuthError) {
        return null;
      }

      // If not authenticated, go to login
      if (authState is AuthUnauthenticated) {
        if (!isAuthRoute) {
          return RoutePaths.login;
        }
        return null;
      }

      // If authenticated, redirect away from auth routes
      if (authState is AuthAuthenticated) {
        if (isAuthRoute) {
          return RoutePaths.home;
        }
        return null;
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.otp,
        name: RouteNames.otp,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return RegisterScreen(email: email);
        },
      ),

      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Home branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Reels branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.reels,
                name: RouteNames.reels,
                builder: (context, state) => const ReelsScreen(),
              ),
            ],
          ),

          // Search branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.search,
                name: RouteNames.search,
                builder: (context, state) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'filter',
                    name: RouteNames.filter,
                    builder: (context, state) => const FilterScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Chat branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.chat,
                name: RouteNames.chat,
                builder: (context, state) => const ConversationsScreen(),
              ),
            ],
          ),

          // Profile branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Detail routes (outside shell)
      GoRoute(
        path: '/listing/:id',
        name: RouteNames.listing,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final listingId = state.pathParameters['id']!;
          return ListingDetailScreen(listingId: listingId);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        name: RouteNames.chatDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          return ChatScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: RoutePaths.saved,
        name: RouteNames.saved,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SavedScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Team management routes
      GoRoute(
        path: '/team',
        name: RouteNames.teamMembers,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final sellerProfileId = state.extra as String;
          return TeamMembersScreen(sellerProfileId: sellerProfileId);
        },
      ),
      GoRoute(
        path: '/team/add',
        name: RouteNames.addMember,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final sellerProfileId = state.extra as String;
          return AddMemberScreen(sellerProfileId: sellerProfileId);
        },
      ),
      GoRoute(
        path: '/team/member/:id',
        name: RouteNames.memberDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final memberId = state.pathParameters['id']!;
          return MemberDetailScreen(memberId: memberId);
        },
      ),
      GoRoute(
        path: '/team/activity',
        name: RouteNames.activityLog,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final sellerProfileId = extra['sellerProfileId'] as String;
          final activities =
              extra['activities'] as List<ActivityLog>? ?? const [];
          return ActivityLogScreen(
            sellerProfileId: sellerProfileId,
            activities: activities,
          );
        },
      ),
    ],
  );
}

/// Refresh notifier for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
