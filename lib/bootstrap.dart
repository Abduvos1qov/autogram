import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'core/database/database_helper.dart';
import 'core/utils/logger.dart';
import 'di/injection.dart';

/// Bootstrap - initializes all app dependencies

Future<void> bootstrap() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase
  await _initSupabase();

  // Initialize local database
  await _initDatabase();

  // Initialize dependency injection
  await initDependencies();

  AppLogger.info('App bootstrap completed');
}

Future<void> _initSupabase() async {
  try {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: EnvConfig.isDevelopment,
    );
    AppLogger.info('Supabase initialized');
  } catch (e) {
    AppLogger.error('Failed to initialize Supabase: $e');
    rethrow;
  }
}

Future<void> _initDatabase() async {
  try {
    await DatabaseHelper.instance.database;
    AppLogger.info('Database initialized');
  } catch (e) {
    AppLogger.error('Failed to initialize database: $e');
    // Don't rethrow - database is optional for basic functionality
  }
}
