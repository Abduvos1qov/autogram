import 'package:intl/intl.dart';

/// Utility class for formatting various data types

class Formatters {
  Formatters._();

  // Price formatting
  static String formatPrice(double price, {String currency = 'USD'}) {
    final formatter = NumberFormat.currency(
      symbol: currency == 'USD' ? '\$' : '',
      decimalDigits: currency == 'UZS' ? 0 : 2,
    );

    if (currency == 'UZS') {
      return '${formatter.format(price)} so\'m';
    }

    return formatter.format(price);
  }

  static String formatPriceCompact(double price) {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(0)}K';
    }
    return '\$${price.toStringAsFixed(0)}';
  }

  // Number formatting
  static String formatNumber(int number) {
    return NumberFormat.decimalPattern().format(number);
  }

  static String formatNumberCompact(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Mileage formatting
  static String formatMileage(int km) {
    return '${formatNumber(km)} km';
  }

  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'hozirgina';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kun oldin';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} hafta oldin';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} oy oldin';
    } else {
      return '${(difference.inDays / 365).floor()} yil oldin';
    }
  }

  // Phone formatting
  static String formatPhone(String phone) {
    // +998 XX XXX XX XX
    if (phone.length == 13 && phone.startsWith('+998')) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9, 11)} ${phone.substring(11, 13)}';
    }
    return phone;
  }

  static String formatPhoneForDisplay(String phone) {
    // Hide middle digits: +998 ** *** XX XX
    if (phone.length == 13 && phone.startsWith('+998')) {
      return '${phone.substring(0, 4)} ** *** ${phone.substring(9, 11)} ${phone.substring(11, 13)}';
    }
    return phone;
  }

  // Duration formatting
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Year formatting for cars
  static String formatYear(int year) {
    return year.toString();
  }

  // Engine volume formatting
  static String formatEngineVolume(double volume) {
    return '${volume.toStringAsFixed(1)}L';
  }

  // Rating formatting
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$bytes bytes';
    }
  }
}
