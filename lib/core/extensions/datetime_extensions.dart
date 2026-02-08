import 'package:intl/intl.dart';

/// DateTime extensions for formatting and comparison

extension DateTimeExtensions on DateTime {
  // Formatting
  String get formatDate => DateFormat('dd.MM.yyyy').format(this);

  String get formatDateTime => DateFormat('dd.MM.yyyy HH:mm').format(this);

  String get formatTime => DateFormat('HH:mm').format(this);

  String get formatFull => DateFormat('dd MMMM yyyy, HH:mm').format(this);

  String get formatMonthYear => DateFormat('MMMM yyyy').format(this);

  String get formatDayMonth => DateFormat('dd MMMM').format(this);

  String get formatWeekday => DateFormat('EEEE').format(this);

  String get formatShortWeekday => DateFormat('EEE').format(this);

  String get formatIso8601 => toIso8601String();

  // Relative time
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

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

  String get relativeTimeShort {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'hozir';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}d';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}s';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}k';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}h';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}o';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }

  // Chat-style formatting
  String get chatTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisDay = DateTime(year, month, day);

    if (thisDay == today) {
      return formatTime;
    } else if (thisDay == yesterday) {
      return 'Kecha $formatTime';
    } else if (now.difference(this).inDays < 7) {
      return '$formatShortWeekday $formatTime';
    } else {
      return formatDate;
    }
  }

  // Comparisons
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isThisYear {
    return year == DateTime.now().year;
  }

  bool get isPast => isBefore(DateTime.now());

  bool get isFuture => isAfter(DateTime.now());

  // Date manipulation
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  DateTime get endOfWeek {
    return add(Duration(days: DateTime.daysPerWeek - weekday)).endOfDay;
  }

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth => DateTime(year, month + 1, 0).endOfDay;

  DateTime addDays(int days) => add(Duration(days: days));

  DateTime subtractDays(int days) => subtract(Duration(days: days));

  DateTime addMonths(int months) {
    var newMonth = month + months;
    var newYear = year;
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }
    return DateTime(newYear, newMonth, day, hour, minute, second);
  }

  // Age calculation
  int get age {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
}
