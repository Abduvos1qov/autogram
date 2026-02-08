import 'package:flutter_test/flutter_test.dart';

import 'package:autogram/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('formatPrice', () {
      test('should format USD price with dollar sign and 2 decimals', () {
        final result = Formatters.formatPrice(25000.00);
        expect(result, contains('\$'));
        expect(result, contains('25'));
      });

      test('should format UZS price with so\'m suffix and 0 decimals', () {
        final result = Formatters.formatPrice(25000000.00, currency: 'UZS');
        expect(result, contains('so\'m'));
        expect(result, contains('25'));
      });
    });

    group('formatPriceCompact', () {
      test('should format price in millions with M suffix', () {
        final result = Formatters.formatPriceCompact(1500000);
        expect(result, equals('\$1.5M'));
      });

      test('should format price in thousands with K suffix', () {
        final result = Formatters.formatPriceCompact(25000);
        expect(result, equals('\$25K'));
      });

      test('should format small price without suffix', () {
        final result = Formatters.formatPriceCompact(500);
        expect(result, equals('\$500'));
      });
    });

    group('formatNumber', () {
      test('should format number with thousand separators', () {
        final result = Formatters.formatNumber(1234567);
        expect(result, contains('1'));
        expect(result, contains('234'));
        expect(result, contains('567'));
      });

      test('should handle small numbers', () {
        final result = Formatters.formatNumber(123);
        expect(result, equals('123'));
      });
    });

    group('formatNumberCompact', () {
      test('should format number in millions with M suffix', () {
        final result = Formatters.formatNumberCompact(1500000);
        expect(result, equals('1.5M'));
      });

      test('should format number in thousands with K suffix', () {
        final result = Formatters.formatNumberCompact(2500);
        expect(result, equals('2.5K'));
      });

      test('should format small number without suffix', () {
        final result = Formatters.formatNumberCompact(500);
        expect(result, equals('500'));
      });
    });

    group('formatMileage', () {
      test('should format mileage with km suffix', () {
        final result = Formatters.formatMileage(50000);
        expect(result, contains('50'));
        expect(result, contains('km'));
      });

      test('should format zero mileage', () {
        final result = Formatters.formatMileage(0);
        expect(result, equals('0 km'));
      });
    });

    group('formatDate', () {
      test('should format date in dd.MM.yyyy format', () {
        final date = DateTime(2024, 1, 15);
        final result = Formatters.formatDate(date);
        expect(result, equals('15.01.2024'));
      });
    });

    group('formatDateTime', () {
      test('should format datetime in dd.MM.yyyy HH:mm format', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        final result = Formatters.formatDateTime(date);
        expect(result, equals('15.01.2024 14:30'));
      });
    });

    group('formatTime', () {
      test('should format time in HH:mm format', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        final result = Formatters.formatTime(date);
        expect(result, equals('14:30'));
      });

      test('should format time with leading zeros', () {
        final date = DateTime(2024, 1, 15, 9, 5);
        final result = Formatters.formatTime(date);
        expect(result, equals('09:05'));
      });
    });

    group('formatRelativeTime', () {
      test('should return "hozirgina" for time less than a minute ago', () {
        final date = DateTime.now().subtract(const Duration(seconds: 30));
        final result = Formatters.formatRelativeTime(date);
        expect(result, equals('hozirgina'));
      });

      test('should return minutes for time less than an hour ago', () {
        final date = DateTime.now().subtract(const Duration(minutes: 30));
        final result = Formatters.formatRelativeTime(date);
        expect(result, contains('30'));
        expect(result, contains('daqiqa'));
      });

      test('should return hours for time less than a day ago', () {
        final date = DateTime.now().subtract(const Duration(hours: 5));
        final result = Formatters.formatRelativeTime(date);
        expect(result, contains('5'));
        expect(result, contains('soat'));
      });

      test('should return days for time less than a week ago', () {
        final date = DateTime.now().subtract(const Duration(days: 3));
        final result = Formatters.formatRelativeTime(date);
        expect(result, contains('3'));
        expect(result, contains('kun'));
      });

      test('should return weeks for time less than a month ago', () {
        final date = DateTime.now().subtract(const Duration(days: 14));
        final result = Formatters.formatRelativeTime(date);
        expect(result, contains('2'));
        expect(result, contains('hafta'));
      });

      test('should return months for time less than a year ago', () {
        final date = DateTime.now().subtract(const Duration(days: 60));
        final result = Formatters.formatRelativeTime(date);
        expect(result, contains('2'));
        expect(result, contains('oy'));
      });

      test('should return years for time more than a year ago', () {
        final date = DateTime.now().subtract(const Duration(days: 400));
        final result = Formatters.formatRelativeTime(date);
        expect(result, contains('1'));
        expect(result, contains('yil'));
      });
    });

    group('formatPhone', () {
      test('should format valid Uzbek phone number', () {
        final result = Formatters.formatPhone('+998901234567');
        expect(result, equals('+998 90 123 45 67'));
      });

      test('should return original for invalid phone format', () {
        final result = Formatters.formatPhone('1234567');
        expect(result, equals('1234567'));
      });

      test('should return original for non-Uzbek phone', () {
        final result = Formatters.formatPhone('+1234567890');
        expect(result, equals('+1234567890'));
      });
    });

    group('formatPhoneForDisplay', () {
      test('should hide middle digits for display', () {
        final result = Formatters.formatPhoneForDisplay('+998901234567');
        expect(result, equals('+998 ** *** 45 67'));
      });

      test('should return original for invalid phone format', () {
        final result = Formatters.formatPhoneForDisplay('1234567');
        expect(result, equals('1234567'));
      });
    });

    group('formatDuration', () {
      test('should format seconds as MM:SS', () {
        final result = Formatters.formatDuration(125);
        expect(result, equals('02:05'));
      });

      test('should handle zero seconds', () {
        final result = Formatters.formatDuration(0);
        expect(result, equals('00:00'));
      });

      test('should format single digit seconds with leading zero', () {
        final result = Formatters.formatDuration(65);
        expect(result, equals('01:05'));
      });
    });

    group('formatYear', () {
      test('should return year as string', () {
        final result = Formatters.formatYear(2024);
        expect(result, equals('2024'));
      });
    });

    group('formatEngineVolume', () {
      test('should format engine volume with L suffix', () {
        final result = Formatters.formatEngineVolume(2.5);
        expect(result, equals('2.5L'));
      });

      test('should format whole number engine volume', () {
        final result = Formatters.formatEngineVolume(3.0);
        expect(result, equals('3.0L'));
      });
    });

    group('formatRating', () {
      test('should format rating with one decimal place', () {
        final result = Formatters.formatRating(4.567);
        expect(result, equals('4.6'));
      });

      test('should format perfect rating', () {
        final result = Formatters.formatRating(5.0);
        expect(result, equals('5.0'));
      });
    });

    group('formatFileSize', () {
      test('should format bytes', () {
        final result = Formatters.formatFileSize(512);
        expect(result, equals('512 bytes'));
      });

      test('should format kilobytes', () {
        final result = Formatters.formatFileSize(2048);
        expect(result, equals('2.00 KB'));
      });

      test('should format megabytes', () {
        final result = Formatters.formatFileSize(1048576 * 5);
        expect(result, equals('5.00 MB'));
      });

      test('should format gigabytes', () {
        final result = Formatters.formatFileSize(1073741824 * 2);
        expect(result, equals('2.00 GB'));
      });
    });
  });
}
