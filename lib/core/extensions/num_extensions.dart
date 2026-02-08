import 'package:intl/intl.dart';

/// Number extensions for formatting

extension IntExtensions on int {
  // Formatting
  String get formatted => NumberFormat.decimalPattern().format(this);

  String get compactFormatted {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  // Currency
  String formatCurrency({String symbol = '\$', int decimals = 0}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    ).format(this);
  }

  // Duration
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);
  Duration get milliseconds => Duration(milliseconds: this);

  // Time formatting
  String get formatDuration {
    final minutes = this ~/ 60;
    final seconds = this % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formatDurationLong {
    if (this < 60) {
      return '$this soniya';
    } else if (this < 3600) {
      final mins = this ~/ 60;
      final secs = this % 60;
      return '$mins daqiqa${secs > 0 ? ' $secs soniya' : ''}';
    } else {
      final hours = this ~/ 3600;
      final mins = (this % 3600) ~/ 60;
      return '$hours soat${mins > 0 ? ' $mins daqiqa' : ''}';
    }
  }

  // File size
  String get formatFileSize {
    if (this >= 1073741824) {
      return '${(this / 1073741824).toStringAsFixed(2)} GB';
    } else if (this >= 1048576) {
      return '${(this / 1048576).toStringAsFixed(2)} MB';
    } else if (this >= 1024) {
      return '${(this / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$this bytes';
    }
  }

  // Ordinal (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  // Percentage
  String percentage(int total) {
    if (total == 0) return '0%';
    return '${((this / total) * 100).toStringAsFixed(1)}%';
  }

  // Clamp
  int clampTo(int min, int max) => this < min ? min : (this > max ? max : this);

  // Boolean
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;
  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;
}

extension DoubleExtensions on double {
  // Formatting
  String get formatted => NumberFormat.decimalPattern().format(this);

  String get compactFormatted {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toStringAsFixed(1);
  }

  // Currency
  String formatCurrency({String symbol = '\$', int decimals = 2}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    ).format(this);
  }

  String get formatPrice {
    if (this >= 1000000) {
      return '\$${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '\$${(this / 1000).toStringAsFixed(0)}K';
    }
    return '\$${toStringAsFixed(0)}';
  }

  // Percentage
  String get percentage => '${toStringAsFixed(1)}%';

  // Rating
  String get formatRating => toStringAsFixed(1);

  // Clamp
  double clampTo(double min, double max) =>
      this < min ? min : (this > max ? max : this);

  // Precision
  double toPrecision(int fractionDigits) {
    final mod = 10.0 * fractionDigits;
    return ((this * mod).round().toDouble() / mod);
  }

  // Boolean
  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;
}
