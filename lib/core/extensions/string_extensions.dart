/// String extensions for common operations

extension StringExtensions on String {
  // Capitalization
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeEachWord {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  // Truncation
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  // Validation checks
  bool get isEmail {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(this);
  }

  bool get isPhoneNumber {
    return RegExp(r'^\+998[0-9]{9}$').hasMatch(replaceAll(RegExp(r'[^\d+]'), ''));
  }

  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  bool get isUrl {
    return RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    ).hasMatch(this);
  }

  // Phone number formatting
  String get formatPhone {
    final clean = replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.length == 13 && clean.startsWith('+998')) {
      return '${clean.substring(0, 4)} ${clean.substring(4, 6)} ${clean.substring(6, 9)} ${clean.substring(9, 11)} ${clean.substring(11, 13)}';
    }
    return this;
  }

  String get cleanPhone {
    return replaceAll(RegExp(r'[^\d+]'), '');
  }

  // Null/Empty checks
  bool get isNullOrEmpty => isEmpty;

  bool get isNotNullOrEmpty => isNotEmpty;

  String? get nullIfEmpty => isEmpty ? null : this;

  // Extract numbers
  String get digitsOnly => replaceAll(RegExp(r'[^\d]'), '');

  int? get toIntOrNull => int.tryParse(digitsOnly);

  double? get toDoubleOrNull => double.tryParse(replaceAll(',', ''));

  // Remove whitespace
  String get removeAllSpaces => replaceAll(' ', '');

  String get collapseSpaces => replaceAll(RegExp(r'\s+'), ' ').trim();

  // Username cleaning
  String get cleanUsername {
    return startsWith('@') ? substring(1) : this;
  }

  // HTML/Rich text
  String get stripHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Word count
  int get wordCount {
    if (isEmpty) return 0;
    return split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  // Character count (excluding spaces)
  int get characterCountWithoutSpaces {
    return replaceAll(' ', '').length;
  }

  // Reverse
  String get reversed {
    return split('').reversed.join();
  }

  // Slug generation
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  String orEmpty() => this ?? '';

  String orDefault(String defaultValue) => this ?? defaultValue;
}
