import 'package:flutter/material.dart';

/// AUTOGRAM Design System - Color Palette
/// Modern, vibrant colors inspired by Instagram/TikTok aesthetics
/// Optimized for Uzbekistan market preferences

class AppColors {
  AppColors._();

  // ============================================================
  // BRAND COLORS
  // ============================================================

  // Primary - Vibrant Blue (Trust, Technology, Premium)
  static const Color primary = Color(0xFF0095F6);
  static const Color primaryLight = Color(0xFF47B5FF);
  static const Color primaryDark = Color(0xFF0077CC);
  static const Color primarySoft = Color(0xFFE8F4FD);

  // Secondary - Teal (Fresh, Modern, Growth)
  static const Color secondary = Color(0xFF00D4AA);
  static const Color secondaryLight = Color(0xFF5DFFC8);
  static const Color secondaryDark = Color(0xFF00A88A);
  static const Color secondarySoft = Color(0xFFE6FBF6);

  // Accent - Coral/Orange (Energy, Action, Urgency)
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8F66);
  static const Color accentDark = Color(0xFFE55A2B);
  static const Color accentSoft = Color(0xFFFFF0EB);

  // ============================================================
  // NEUTRAL COLORS
  // ============================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Light mode grays
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEFEFEF);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Dark mode specific
  static const Color dark50 = Color(0xFF2C2C2C);
  static const Color dark100 = Color(0xFF262626);
  static const Color dark200 = Color(0xFF1F1F1F);
  static const Color dark300 = Color(0xFF181818);
  static const Color dark400 = Color(0xFF121212);
  static const Color dark500 = Color(0xFF0A0A0A);

  // ============================================================
  // BACKGROUND & SURFACE COLORS
  // ============================================================

  // Light theme
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Dark theme
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariantDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Elevated surfaces (for cards, modals, etc.)
  static const Color elevatedLight = Color(0xFFFFFFFF);
  static const Color elevatedDark = Color(0xFF262626);

  // ============================================================
  // TEXT COLORS
  // ============================================================

  // Light theme text
  static const Color textPrimary = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color textTertiary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFFC7C7C7);
  static const Color textDisabled = Color(0xFFDDDDDD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF0095F6);

  // Dark theme text
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFA8A8A8);
  static const Color textTertiaryDark = Color(0xFF737373);
  static const Color textHintDark = Color(0xFF525252);
  static const Color textDisabledDark = Color(0xFF3D3D3D);

  // ============================================================
  // STATUS/SEMANTIC COLORS
  // ============================================================

  // Success - Green
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFB9F6CA);
  static const Color successSoft = Color(0xFFE8F5E9);
  static const Color successDark = Color(0xFF00A844);

  // Error - Red
  static const Color error = Color(0xFFED4956);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color errorSoft = Color(0xFFFFF0F1);
  static const Color errorDark = Color(0xFFD32F2F);

  // Warning - Amber
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningLight = Color(0xFFFFE082);
  static const Color warningSoft = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFFF8F00);

  // Info - Blue
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF90CAF9);
  static const Color infoSoft = Color(0xFFE3F2FD);
  static const Color infoDark = Color(0xFF1976D2);

  // ============================================================
  // FEATURE-SPECIFIC COLORS
  // ============================================================

  // Interaction colors
  static const Color likeColor = Color(0xFFED4956);
  static const Color likeColorInactive = Color(0xFFDBDBDB);
  static const Color saveColor = Color(0xFFFFD700);
  static const Color shareColor = Color(0xFF0095F6);

  // Verification & Trust
  static const Color verifiedColor = Color(0xFF0095F6);
  static const Color verifiedBadge = Color(0xFF00D4AA);
  static const Color premiumColor = Color(0xFFFFD700);
  static const Color premiumGold = Color(0xFFF5C518);

  // Price colors
  static const Color priceColor = Color(0xFF00C853);
  static const Color priceNegotiable = Color(0xFFFF9800);
  static const Color priceReduced = Color(0xFFED4956);

  // Online/Status indicators
  static const Color online = Color(0xFF44D62C);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color busy = Color(0xFFFFAB00);

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
    colors: [Color(0xFF0095F6), Color(0xFF00D4AA)],
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
    colors: [Color(0xFF0095F6), Color(0xFF00D4AA)],
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
      Color(0xFFEBEBEB),
      Color(0xFFF5F5F5),
      Color(0xFFEBEBEB),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient shimmerGradientDark = LinearGradient(
    colors: [
      Color(0xFF2A2A2A),
      Color(0xFF3A3A3A),
      Color(0xFF2A2A2A),
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

  static const Color borderLight = Color(0xFFDBDBDB);
  static const Color borderMedium = Color(0xFFC7C7C7);
  static const Color borderDark = Color(0xFF363636);
  static const Color borderFocus = Color(0xFF0095F6);
  static const Color borderError = Color(0xFFED4956);

  // ============================================================
  // DIVIDER COLORS
  // ============================================================

  static const Color dividerLight = Color(0xFFEFEFEF);
  static const Color dividerDark = Color(0xFF262626);

  // ============================================================
  // SHIMMER COLORS
  // ============================================================

  static const Color shimmerBase = Color(0xFFE8E8E8);
  static const Color shimmerHighlight = Color(0xFFF8F8F8);
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF3D3D3D);

  // ============================================================
  // CHIP/TAG COLORS
  // ============================================================

  static const Color chipBackground = Color(0xFFEFEFEF);
  static const Color chipBackgroundDark = Color(0xFF262626);
  static const Color chipSelected = Color(0xFF0095F6);
  static const Color chipSelectedBg = Color(0xFFE8F4FD);

  // Category chip colors
  static const Color categoryNew = Color(0xFF00C853);
  static const Color categoryHot = Color(0xFFFF6B35);
  static const Color categoryPremium = Color(0xFFFFD700);
  static const Color categoryUrgent = Color(0xFFED4956);

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
          return surfaceDark;
        case 1:
          return Color.lerp(surfaceDark, white, 0.05)!;
        case 2:
          return Color.lerp(surfaceDark, white, 0.08)!;
        case 3:
          return Color.lerp(surfaceDark, white, 0.11)!;
        case 4:
          return Color.lerp(surfaceDark, white, 0.12)!;
        default:
          return Color.lerp(surfaceDark, white, 0.14)!;
      }
    }
    return surfaceLight;
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
