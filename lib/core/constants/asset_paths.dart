/// Paths to all app assets

class AssetPaths {
  AssetPaths._();

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _animationsPath = 'assets/animations';
  static const String _l10nPath = 'assets/l10n';

  // Images
  static const String logo = '$_imagesPath/logo.png';
  static const String logoWhite = '$_imagesPath/logo_white.png';
  static const String placeholder = '$_imagesPath/placeholder.png';
  static const String avatarPlaceholder = '$_imagesPath/avatar_placeholder.png';
  static const String carPlaceholder = '$_imagesPath/car_placeholder.png';

  // Onboarding
  static const String onboarding1 = '$_imagesPath/onboarding_1.png';
  static const String onboarding2 = '$_imagesPath/onboarding_2.png';
  static const String onboarding3 = '$_imagesPath/onboarding_3.png';

  // Icons (SVG)
  static const String homeIcon = '$_iconsPath/home.svg';
  static const String reelsIcon = '$_iconsPath/reels.svg';
  static const String searchIcon = '$_iconsPath/search.svg';
  static const String chatIcon = '$_iconsPath/chat.svg';
  static const String profileIcon = '$_iconsPath/profile.svg';
  static const String heartIcon = '$_iconsPath/heart.svg';
  static const String heartFilledIcon = '$_iconsPath/heart_filled.svg';
  static const String bookmarkIcon = '$_iconsPath/bookmark.svg';
  static const String bookmarkFilledIcon = '$_iconsPath/bookmark_filled.svg';
  static const String shareIcon = '$_iconsPath/share.svg';
  static const String commentIcon = '$_iconsPath/comment.svg';
  static const String verifiedIcon = '$_iconsPath/verified.svg';
  static const String locationIcon = '$_iconsPath/location.svg';
  static const String phoneIcon = '$_iconsPath/phone.svg';
  static const String messageIcon = '$_iconsPath/message.svg';

  // Animations (Lottie)
  static const String loadingAnimation = '$_animationsPath/loading.json';
  static const String successAnimation = '$_animationsPath/success.json';
  static const String errorAnimation = '$_animationsPath/error.json';
  static const String emptyAnimation = '$_animationsPath/empty.json';
  static const String noConnectionAnimation =
      '$_animationsPath/no_connection.json';

  // Localization
  static const String l10nPath = _l10nPath;
}
