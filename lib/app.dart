import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/chat/presentation/bloc/conversations_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/listing/presentation/bloc/listing_bloc.dart';
import 'features/reels/presentation/bloc/reels_bloc.dart';
import 'features/saved/presentation/bloc/saved_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/seller/presentation/bloc/seller_bloc.dart';
import 'features/seller/presentation/bloc/team/team_bloc.dart';
import 'navigation/app_router.dart';

/// Main App widget

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
        BlocProvider<ReelsBloc>(create: (_) => sl<ReelsBloc>()),
        BlocProvider<SearchBloc>(create: (_) => sl<SearchBloc>()),
        BlocProvider<ListingBloc>(create: (_) => sl<ListingBloc>()),
        BlocProvider<SavedBloc>(create: (_) => sl<SavedBloc>()),
        BlocProvider<ConversationsBloc>(create: (_) => sl<ConversationsBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<SellerBloc>(create: (_) => sl<SellerBloc>()),
        BlocProvider<TeamBloc>(create: (_) => sl<TeamBloc>()),
      ],
      child: _buildMaterialApp(),
    );
  }

  Widget _buildMaterialApp() {
    final router = createRouter(_authBloc);

    return MaterialApp.router(
      title: 'Autogram',
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router
      routerConfig: router,
    );
  }
}
