import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/feedback/error_screen.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/username_screen.dart';
import '../features/auth/presentation/screens/verification_screen.dart';
import '../features/boost/presentation/screens/boost_overview_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/screens/conversations_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/listing/presentation/screens/listing_detail_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/about_seller_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/history_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/storefront_menu_screen.dart';
import '../features/profile/domain/entities/user_profile.dart';
import '../features/seller/domain/entities/seller_profile.dart';
import '../features/reels/presentation/screens/reels_screen.dart';
import '../features/saved/presentation/screens/liked_screen.dart';
import '../features/saved/presentation/screens/saved_screen.dart';
import '../features/search/presentation/screens/filter_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/seller/presentation/screens/upgrade_screen.dart';
import '../features/seller/presentation/screens/business_info_screen.dart';
import '../features/seller/presentation/screens/upgrade_success_screen.dart';
import '../features/seller/presentation/screens/team_members_screen.dart';
import '../features/seller/presentation/screens/add_member_screen.dart';
import '../features/seller/presentation/screens/member_detail_screen.dart';
import '../features/seller/presentation/screens/activity_log_screen.dart';
import '../features/seller/domain/entities/activity_log.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/help_screen.dart';
import '../features/payment/payment.dart';
import 'navigation_shell.dart';
import 'route_names.dart';

/// App router configuration using GoRouter

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthRoute =
          state.matchedLocation == RoutePaths.splash ||
          state.matchedLocation == RoutePaths.onboarding ||
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register ||
          state.matchedLocation == RoutePaths.verification ||
          state.matchedLocation == RoutePaths.username ||
          state.matchedLocation == RoutePaths.forgotPassword;

      // If initial check, stay on splash
      if (authState is AuthInitial) {
        return RoutePaths.splash;
      }

      // During auth flow (loading, sign up success, password reset, etc.)
      // don't redirect — let BlocConsumer in screens handle navigation
      if (authState is AuthLoading ||
          authState is AuthSignUpSuccess ||
          authState is AuthPasswordResetSent ||
          authState is AuthForgotPasswordOtpSent ||
          authState is AuthForgotPasswordOtpVerified ||
          authState is AuthPasswordResetSuccess ||
          authState is AuthError) {
        return null;
      }

      // If needs username, go to username screen
      if (authState is AuthNeedsUsername) {
        if (state.matchedLocation != RoutePaths.username) {
          return RoutePaths.username;
        }
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
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.verification,
        name: RouteNames.verification,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: RoutePaths.username,
        name: RouteNames.username,
        builder: (context, state) => const UsernameScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.reels,
                name: RouteNames.reels,
                builder: (context, state) => const ReelsScreen(),
              ),
            ],
          ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.chat,
                name: RouteNames.chat,
                builder: (context, state) => const ConversationsScreen(),
              ),
            ],
          ),
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
      GoRoute(
        path: RoutePaths.notificationSettings,
        name: RouteNames.notificationSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.history,
        name: RouteNames.history,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.liked,
        name: RouteNames.liked,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LikedScreen(),
      ),
      GoRoute(
        path: RoutePaths.boost,
        name: RouteNames.boost,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BoostOverviewScreen(),
      ),
      GoRoute(
        path: RoutePaths.help,
        name: RouteNames.help,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: RouteNames.about,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RoutePaths.aboutSeller,
        name: RouteNames.aboutSeller,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutSellerScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileFollowers,
        name: RouteNames.profileFollowers,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const _FollowersStubScreen(),
      ),
      GoRoute(
        path: RoutePaths.storefrontMenu,
        name: RouteNames.storefrontMenu,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          // The storefront passes both the user and seller via `extra` so the
          // menu can render the header without re-fetching from the bloc.
          final extra = state.extra as Map<String, Object?>;
          return StorefrontMenuScreen(
            profile: extra['profile']! as UserProfile,
            seller: extra['seller']! as SellerProfile,
          );
        },
      ),
      GoRoute(
        // Plan-management entry point. Until a dedicated SubscriptionScreen
        // ships, route through to the existing upgrade flow so the drawer
        // tile doesn't dead-end.
        path: RoutePaths.subscription,
        name: RouteNames.subscription,
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) => RoutePaths.upgrade,
      ),

      // Seller upgrade routes
      GoRoute(
        path: RoutePaths.upgrade,
        name: RouteNames.upgrade,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UpgradeScreen(),
      ),
      GoRoute(
        path: RoutePaths.upgradeBusinessInfo,
        name: RouteNames.upgradeBusinessInfo,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BusinessInfoScreen(),
      ),
      GoRoute(
        path: RoutePaths.upgradeSuccess,
        name: RouteNames.upgradeSuccess,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UpgradeSuccessScreen(),
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

      // Payment routes
      GoRoute(
        path: RoutePaths.payment,
        name: RouteNames.payment,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final request = state.extra as PaymentRequest;
          return PaymentScreen(request: request);
        },
      ),
      GoRoute(
        path: RoutePaths.paymentWebView,
        name: RouteNames.paymentWebView,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as PaymentWebViewReady;
          return PaymentWebViewScreen(state: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.seatManagement,
        name: RouteNames.seatManagement,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SeatManagementScreen(),
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

/// Placeholder for the followers list. The followers feature is queued for
/// a follow-up phase — until then the route resolves to a friendly empty
/// state instead of dead-ending the stat tap.
class _FollowersStubScreen extends StatelessWidget {
  const _FollowersStubScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Followers — coming soon',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
