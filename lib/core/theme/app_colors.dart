import 'package:flutter/material.dart';

/// AUTOGRAM Design System - Color Palette
/// Professional palette for car marketplace, optimized for both Light and Dark themes.
/// Follows Material Design 3 elevation tokens and modern accessibility best practices.

class AppColors {
  AppColors._();

  // ============================================================
  // BRAND COLORS
  // ============================================================

  // Primary - Deep Auto Blue (Trust, Premium, Automotive)
  static const Color primary = Color(0xFF1E5FFF);
  static const Color primaryLight = Color(0xFF5C8DFF);
  static const Color primaryDark = Color(0xFF1747CC);
  static const Color primarySoft = Color(0xFFEBF1FF);
  static const Color primarySoftDark = Color(0xFF1A2440);

  // Secondary - Emerald (Modern, Trust, Verified)
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondarySoft = Color(0xFFD1FAE5);
  static const Color secondarySoftDark = Color(0xFF0F2920);

  // Accent - Coral (Energy, Action, Boost)
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8F66);
  static const Color accentDark = Color(0xFFE55A2B);
  static const Color accentSoft = Color(0xFFFFF0EB);
  static const Color accentSoftDark = Color(0xFF3D1F12);

  // ============================================================
  // NEUTRAL COLORS
  // ============================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Light mode grays (Tailwind-inspired, cooler tones)
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F7);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Dark mode-specific surface steps (Material 3 tonal elevation)
  static const Color dark50 = Color(0xFF2D2D2D);
  static const Color dark100 = Color(0xFF272727);
  static const Color dark200 = Color(0xFF212121);
  static const Color dark300 = Color(0xFF1C1C1C);
  static const Color dark400 = Color(0xFF121212);
  static const Color dark500 = Color(0xFF0A0A0A);

  // ============================================================
  // BACKGROUND & SURFACE COLORS (Material 3 tonal elevation)
  // ============================================================

  // Light theme — 4-level elevation
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F7);
  static const Color surfaceContainerLight = Color(0xFFF5F5F7);
  static const Color surfaceContainerHighLight = Color(0xFFEBEBED);
  static const Color surfaceContainerHighestLight = Color(0xFFE1E1E3);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Dark theme — 4-level elevation
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1C1C1C);
  static const Color surfaceVariantDark = Color(0xFF212121);
  static const Color surfaceContainerDark = Color(0xFF212121);
  static const Color surfaceContainerHighDark = Color(0xFF272727);
  static const Color surfaceContainerHighestDark = Color(0xFF2D2D2D);
  static const Color cardDark = Color(0xFF212121);

  // Elevated surfaces (legacy compatibility)
  static const Color elevatedLight = Color(0xFFFFFFFF);
  static const Color elevatedDark = Color(0xFF272727);

  // ============================================================
  // TEXT COLORS
  // ============================================================

  // Light theme text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFC7C7CC);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF1E5FFF);

  // Dark theme text (off-white, eye-strain reduced)
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFA3A3A3);
  static const Color textTertiaryDark = Color(0xFF737373);
  static const Color textHintDark = Color(0xFF525252);
  static const Color textDisabledDark = Color(0xFF3F3F46);

  // ============================================================
  // STATUS/SEMANTIC COLORS
  // ============================================================

  // Success - Emerald
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);
  static const Color successDarkMode = Color(0xFF34D399);

  // Error - Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorDarkMode = Color(0xFFF87171);

  // Warning - Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningDarkMode = Color(0xFFFBBF24);

  // Info - Blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoSoft = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoDarkMode = Color(0xFF60A5FA);

  // ============================================================
  // FEATURE-SPECIFIC COLORS
  // ============================================================

  // Interaction colors
  static const Color likeColor = Color(0xFFEF4444);
  static const Color likeColorInactive = Color(0xFFD1D5DB);
  static const Color saveColor = Color(0xFFF59E0B);
  static const Color shareColor = Color(0xFF1E5FFF);

  // Verification & Trust
  static const Color verifiedColor = Color(0xFF1E5FFF);
  static const Color verifiedBadge = Color(0xFF10B981);
  static const Color premiumColor = Color(0xFFF5C518);
  static const Color premiumGold = Color(0xFFF5C518);

  // Price colors
  static const Color priceColor = Color(0xFF10B981);
  static const Color priceNegotiable = Color(0xFFF59E0B);
  static const Color priceReduced = Color(0xFFEF4444);

  // Online/Status indicators
  static const Color online = Color(0xFF22C55E);
  static const Color offline = Color(0xFF9CA3AF);
  static const Color busy = Color(0xFFF59E0B);

  // ============================================================
  // SOCIAL BRAND COLORS
  // ============================================================

  static const Color telegram = Color(0xFF0088CC);
  static const Color instagram = Color(0xFFE4405F);
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFF4285F4);
  static const Color apple = Color(0xFF000000);
  static const Color whatsapp = Color(0xFF25D366);

  // ============================================================
  // GRADIENTS
  // ============================================================

  // Primary brand gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E5FFF), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Instagram-style story gradient
  static const LinearGradient storyGradient = LinearGradient(
    colors: [
      Color(0xFFF58529),
      Color(0xFFDD2A7B),
      Color(0xFF8134AF),
      Color(0xFF515BD4),
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // Sunset gradient (for premium features)
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF3366)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ocean gradient
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF1E5FFF), Color(0xFF10B981)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dark overlay gradient (for video overlays)
  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Card shimmer gradient
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFEBEBED),
      Color(0xFFF5F5F7),
      Color(0xFFEBEBED),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient shimmerGradientDark = LinearGradient(
    colors: [
      Color(0xFF272727),
      Color(0xFF323232),
      Color(0xFF272727),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  // ============================================================
  // OVERLAY COLORS
  // ============================================================

  static const Color overlayLight = Color(0x0D000000); // 5%
  static const Color overlayMedium = Color(0x33000000); // 20%
  static const Color overlayDark = Color(0x80000000); // 50%
  static const Color overlayHeavy = Color(0xB3000000); // 70%
  static const Color overlayBlack = Color(0xE6000000); // 90%

  // Glass morphism
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassDark = Color(0x40000000);

  // ============================================================
  // BORDER COLORS
  // ============================================================

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);
  static const Color borderFocus = Color(0xFF1E5FFF);
  static const Color borderError = Color(0xFFEF4444);

  // Dark theme borders
  static const Color borderDarkSubtle = Color(0xFF2E2E2E);
  static const Color borderDarkMedium = Color(0xFF3F3F46);
  static const Color borderDarkStrong = Color(0xFF525252);

  // ============================================================
  // DIVIDER COLORS
  // ============================================================

  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF272727);

  // ============================================================
  // SHIMMER COLORS
  // ============================================================

  static const Color shimmerBase = Color(0xFFEBEBED);
  static const Color shimmerHighlight = Color(0xFFF5F5F7);
  static const Color shimmerBaseDark = Color(0xFF272727);
  static const Color shimmerHighlightDark = Color(0xFF323232);

  // ============================================================
  // CHIP/TAG COLORS
  // ============================================================

  static const Color chipBackground = Color(0xFFF5F5F7);
  static const Color chipBackgroundDark = Color(0xFF272727);
  static const Color chipSelected = Color(0xFF1E5FFF);
  static const Color chipSelectedBg = Color(0xFFEBF1FF);

  // Category chip colors
  static const Color categoryNew = Color(0xFF10B981);
  static const Color categoryHot = Color(0xFFFF6B35);
  static const Color categoryPremium = Color(0xFFF5C518);
  static const Color categoryUrgent = Color(0xFFEF4444);

  // ============================================================
  // CONTEXT-AWARE COLOR HELPERS
  // Auto-switch between light and dark variants based on Theme.brightness
  // ============================================================

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Text colors
  static Color textPrimaryOf(BuildContext context) =>
      _isDark(context) ? textPrimaryDark : textPrimary;
  static Color textSecondaryOf(BuildContext context) =>
      _isDark(context) ? textSecondaryDark : textSecondary;
  static Color textTertiaryOf(BuildContext context) =>
      _isDark(context) ? textTertiaryDark : textTertiary;
  static Color textHintOf(BuildContext context) =>
      _isDark(context) ? textHintDark : textHint;
  static Color textDisabledOf(BuildContext context) =>
      _isDark(context) ? textDisabledDark : textDisabled;

  // Surfaces
  static Color backgroundOf(BuildContext context) =>
      _isDark(context) ? backgroundDark : backgroundLight;
  static Color surfaceOf(BuildContext context) =>
      _isDark(context) ? surfaceDark : surfaceLight;
  static Color surfaceContainerOf(BuildContext context) =>
      _isDark(context) ? surfaceContainerDark : surfaceContainerLight;
  static Color surfaceContainerHighOf(BuildContext context) =>
      _isDark(context) ? surfaceContainerHighDark : surfaceContainerHighLight;
  static Color cardOf(BuildContext context) =>
      _isDark(context) ? cardDark : cardLight;

  // Borders & dividers
  static Color borderOf(BuildContext context) =>
      _isDark(context) ? borderDarkSubtle : borderLight;
  static Color dividerOf(BuildContext context) =>
      _isDark(context) ? dividerDark : dividerLight;

  // Brand (desaturated in dark mode for contrast)
  static Color primaryOf(BuildContext context) =>
      _isDark(context) ? primaryLight : primary;
  static Color secondaryOf(BuildContext context) =>
      _isDark(context) ? secondaryLight : secondary;
  static Color accentOf(BuildContext context) =>
      _isDark(context) ? accentLight : accent;

  // Semantics (lighter variants in dark mode)
  static Color successOf(BuildContext context) =>
      _isDark(context) ? successDarkMode : success;
  static Color errorOf(BuildContext context) =>
      _isDark(context) ? errorDarkMode : error;
  static Color warningOf(BuildContext context) =>
      _isDark(context) ? warningDarkMode : warning;
  static Color infoOf(BuildContext context) =>
      _isDark(context) ? infoDarkMode : info;

  // Chips
  static Color chipBackgroundOf(BuildContext context) =>
      _isDark(context) ? chipBackgroundDark : chipBackground;

  // Shimmer
  static Color shimmerBaseOf(BuildContext context) =>
      _isDark(context) ? shimmerBaseDark : shimmerBase;
  static Color shimmerHighlightOf(BuildContext context) =>
      _isDark(context) ? shimmerHighlightDark : shimmerHighlight;

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get appropriate text color for a background
  static Color getTextColorOn(Color background) {
    return background.computeLuminance() > 0.5 ? textPrimary : white;
  }

  /// Get surface color based on elevation (Material 3 style)
  static Color getSurfaceElevation(int elevation, {bool isDark = false}) {
    if (isDark) {
      switch (elevation) {
        case 0:
          return backgroundDark;
        case 1:
          return surfaceDark;
        case 2:
          return surfaceContainerDark;
        case 3:
          return surfaceContainerHighDark;
        default:
          return surfaceContainerHighestDark;
      }
    }
    switch (elevation) {
      case 0:
        return backgroundLight;
      case 1:
        return surfaceLight;
      case 2:
        return surfaceContainerLight;
      case 3:
        return surfaceContainerHighLight;
      default:
        return surfaceContainerHighestLight;
    }
  }
}

/// Extension for color manipulation
extension ColorExtension on Color {
  /// Lighten a color by [percent] (0-100)
  Color lighten([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final p = percent / 100;
    return Color.fromARGB(
      a.toInt(),
      (r + ((255 - r) * p)).round().toInt(),
      (g + ((255 - g) * p)).round().toInt(),
      (b + ((255 - b) * p)).round().toInt(),
    );
  }

  /// Darken a color by [percent] (0-100)
  Color darken([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final p = 1 - (percent / 100);
    return Color.fromARGB(
      a.toInt(),
      (r * p).round().toInt(),
      (g * p).round().toInt(),
      (b * p).round().toInt(),
    );
  }

  /// Create color with opacity
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity);
  }
}
