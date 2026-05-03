import 'package:flutter/material.dart';

import 'app_colors.dart';

/// App typography styles — fully theme-aware via BuildContext.
///
/// Usage in widgets:
///   `Text('Hi', style: AppTypography.bodyMedium(context))`
///
/// All getters take a [BuildContext] so colors automatically switch between
/// light and dark themes. Color-less base styles (e.g. [bodyMediumStyle]) are
/// exposed for TextTheme builders that don't have a context available.

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============================================================
  // BASE STYLES (color-less) — used by TextTheme builders
  // ============================================================

  static const TextStyle displayLargeStyle = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMediumStyle = TextStyle(
    fontSize: 28,
    fontWeight: bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmallStyle = TextStyle(
    fontSize: 24,
    fontWeight: bold,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineLargeStyle = TextStyle(
    fontSize: 22,
    fontWeight: semiBold,
  );

  static const TextStyle headlineMediumStyle = TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
  );

  static const TextStyle headlineSmallStyle = TextStyle(
    fontSize: 18,
    fontWeight: semiBold,
  );

  static const TextStyle titleLargeStyle = TextStyle(
    fontSize: 18,
    fontWeight: medium,
  );

  static const TextStyle titleMediumStyle = TextStyle(
    fontSize: 16,
    fontWeight: medium,
  );

  static const TextStyle titleSmallStyle = TextStyle(
    fontSize: 14,
    fontWeight: medium,
  );

  static const TextStyle bodyLargeStyle = TextStyle(
    fontSize: 16,
    fontWeight: regular,
  );

  static const TextStyle bodyMediumStyle = TextStyle(
    fontSize: 14,
    fontWeight: regular,
  );

  static const TextStyle bodySmallStyle = TextStyle(
    fontSize: 12,
    fontWeight: regular,
  );

  static const TextStyle labelLargeStyle = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMediumStyle = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmallStyle = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    letterSpacing: 0.5,
  );

  static const TextStyle priceStyle = TextStyle(
    fontSize: 20,
    fontWeight: bold,
  );

  static const TextStyle priceSmallStyle = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: regular,
  );

  static const TextStyle overlineStyle = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 1.5,
  );

  // ============================================================
  // CONTEXT-AWARE PUBLIC API
  // Auto-switches color between light/dark themes
  // ============================================================

  // Primary text styles — use textPrimary
  static TextStyle displayLarge(BuildContext context) =>
      displayLargeStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle displayMedium(BuildContext context) =>
      displayMediumStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle displaySmall(BuildContext context) =>
      displaySmallStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle headlineLarge(BuildContext context) =>
      headlineLargeStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle headlineMedium(BuildContext context) =>
      headlineMediumStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle headlineSmall(BuildContext context) =>
      headlineSmallStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle titleLarge(BuildContext context) =>
      titleLargeStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle titleMedium(BuildContext context) =>
      titleMediumStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle titleSmall(BuildContext context) =>
      titleSmallStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle bodyLarge(BuildContext context) =>
      bodyLargeStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle bodyMedium(BuildContext context) =>
      bodyMediumStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle labelLarge(BuildContext context) =>
      labelLargeStyle.copyWith(color: AppColors.textPrimaryOf(context));

  // Secondary text styles — use textSecondary
  static TextStyle bodySmall(BuildContext context) =>
      bodySmallStyle.copyWith(color: AppColors.textSecondaryOf(context));
  static TextStyle labelMedium(BuildContext context) =>
      labelMediumStyle.copyWith(color: AppColors.textSecondaryOf(context));
  static TextStyle labelSmall(BuildContext context) =>
      labelSmallStyle.copyWith(color: AppColors.textSecondaryOf(context));
  static TextStyle caption(BuildContext context) =>
      captionStyle.copyWith(color: AppColors.textSecondaryOf(context));
  static TextStyle overline(BuildContext context) =>
      overlineStyle.copyWith(color: AppColors.textSecondaryOf(context));

  // Special — semantic colors
  static TextStyle button(BuildContext context) =>
      buttonStyle.copyWith(color: AppColors.textPrimaryOf(context));
  static TextStyle price(BuildContext context) =>
      priceStyle.copyWith(color: AppColors.primaryOf(context));
  static TextStyle priceSmall(BuildContext context) =>
      priceSmallStyle.copyWith(color: AppColors.primaryOf(context));

  // ============================================================
  // TEXT THEMES (used by ThemeData)
  // ============================================================

  // Light theme
  static TextTheme get textTheme => TextTheme(
        displayLarge:
            displayLargeStyle.copyWith(color: AppColors.textPrimary),
        displayMedium:
            displayMediumStyle.copyWith(color: AppColors.textPrimary),
        displaySmall:
            displaySmallStyle.copyWith(color: AppColors.textPrimary),
        headlineLarge:
            headlineLargeStyle.copyWith(color: AppColors.textPrimary),
        headlineMedium:
            headlineMediumStyle.copyWith(color: AppColors.textPrimary),
        headlineSmall:
            headlineSmallStyle.copyWith(color: AppColors.textPrimary),
        titleLarge: titleLargeStyle.copyWith(color: AppColors.textPrimary),
        titleMedium: titleMediumStyle.copyWith(color: AppColors.textPrimary),
        titleSmall: titleSmallStyle.copyWith(color: AppColors.textPrimary),
        bodyLarge: bodyLargeStyle.copyWith(color: AppColors.textPrimary),
        bodyMedium: bodyMediumStyle.copyWith(color: AppColors.textPrimary),
        bodySmall: bodySmallStyle.copyWith(color: AppColors.textSecondary),
        labelLarge: labelLargeStyle.copyWith(color: AppColors.textPrimary),
        labelMedium:
            labelMediumStyle.copyWith(color: AppColors.textSecondary),
        labelSmall:
            labelSmallStyle.copyWith(color: AppColors.textSecondary),
      );

  // Dark theme
  static TextTheme get textThemeDark => TextTheme(
        displayLarge:
            displayLargeStyle.copyWith(color: AppColors.textPrimaryDark),
        displayMedium:
            displayMediumStyle.copyWith(color: AppColors.textPrimaryDark),
        displaySmall:
            displaySmallStyle.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge:
            headlineLargeStyle.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium:
            headlineMediumStyle.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall:
            headlineSmallStyle.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: titleLargeStyle.copyWith(color: AppColors.textPrimaryDark),
        titleMedium:
            titleMediumStyle.copyWith(color: AppColors.textPrimaryDark),
        titleSmall: titleSmallStyle.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: bodyLargeStyle.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium:
            bodyMediumStyle.copyWith(color: AppColors.textPrimaryDark),
        bodySmall:
            bodySmallStyle.copyWith(color: AppColors.textSecondaryDark),
        labelLarge:
            labelLargeStyle.copyWith(color: AppColors.textPrimaryDark),
        labelMedium:
            labelMediumStyle.copyWith(color: AppColors.textSecondaryDark),
        labelSmall:
            labelSmallStyle.copyWith(color: AppColors.textSecondaryDark),
      );
}
