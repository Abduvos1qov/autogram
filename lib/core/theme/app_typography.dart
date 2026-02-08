import 'package:flutter/material.dart';

import 'app_colors.dart';

/// App typography styles

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Text styles - Light theme
  static TextStyle get displayLarge => const TextStyle(
        fontSize: 32,
        fontWeight: bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => const TextStyle(
        fontSize: 28,
        fontWeight: bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get displaySmall => const TextStyle(
        fontSize: 24,
        fontWeight: bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      );

  static TextStyle get headlineLarge => const TextStyle(
        fontSize: 22,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontSize: 20,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => const TextStyle(
        fontSize: 18,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => const TextStyle(
        fontSize: 18,
        fontWeight: medium,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontSize: 16,
        fontWeight: medium,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontSize: 14,
        fontWeight: medium,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 16,
        fontWeight: regular,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 14,
        fontWeight: regular,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontSize: 14,
        fontWeight: medium,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontSize: 12,
        fontWeight: medium,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontSize: 10,
        fontWeight: medium,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  // Special styles
  static TextStyle get button => const TextStyle(
        fontSize: 14,
        fontWeight: semiBold,
        letterSpacing: 0.5,
      );

  static TextStyle get price => const TextStyle(
        fontSize: 20,
        fontWeight: bold,
        color: AppColors.primary,
      );

  static TextStyle get priceSmall => const TextStyle(
        fontSize: 16,
        fontWeight: semiBold,
        color: AppColors.primary,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 12,
        fontWeight: regular,
        color: AppColors.textSecondary,
      );

  static TextStyle get overline => const TextStyle(
        fontSize: 10,
        fontWeight: medium,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      );

  // Text theme for Material
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  // Dark theme text theme
  static TextTheme get textThemeDark => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryDark),
        displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge:
            headlineLarge.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium:
            headlineMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryDark),
        titleSmall: titleSmall.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: bodySmall.copyWith(color: AppColors.textSecondaryDark),
        labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryDark),
        labelSmall: labelSmall.copyWith(color: AppColors.textSecondaryDark),
      );
}
