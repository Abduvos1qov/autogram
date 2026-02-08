import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'core/utils/logger.dart';

void main() {
  runZonedGuarded(
    () async {
      // Initialize app
      await bootstrap();

      // Run app with localization
      runApp(
        EasyLocalization(
          supportedLocales: const [
            Locale('uz'),
            Locale('ru'),
            Locale('en'),
          ],
          path: 'assets/l10n',
          fallbackLocale: const Locale('uz'),
          startLocale: const Locale('uz'),
          child: const App(),
        ),
      );
    },
    (error, stack) {
      AppLogger.error('Uncaught error: $error');
      AppLogger.error('Stack trace: $stack');
    },
  );
}
