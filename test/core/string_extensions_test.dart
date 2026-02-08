import 'package:flutter_test/flutter_test.dart';

import 'package:autogram/core/extensions/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    group('capitalize', () {
      test('should capitalize first letter', () {
        expect('hello'.capitalize, equals('Hello'));
      });

      test('should return empty string for empty input', () {
        expect(''.capitalize, equals(''));
      });

      test('should handle single character', () {
        expect('a'.capitalize, equals('A'));
      });

      test('should not change already capitalized string', () {
        expect('Hello'.capitalize, equals('Hello'));
      });
    });

    group('capitalizeEachWord', () {
      test('should capitalize each word', () {
        expect('hello world'.capitalizeEachWord, equals('Hello World'));
      });

      test('should handle single word', () {
        expect('hello'.capitalizeEachWord, equals('Hello'));
      });

      test('should handle multiple spaces', () {
        expect('hello  world'.capitalizeEachWord, equals('Hello  World'));
      });

      test('should return empty string for empty input', () {
        expect(''.capitalizeEachWord, equals(''));
      });
    });

    group('truncate', () {
      test('should truncate string longer than maxLength', () {
        final result = 'Hello World'.truncate(8);
        expect(result, equals('Hello...'));
        expect(result.length, equals(8));
      });

      test('should not truncate string shorter than maxLength', () {
        expect('Hello'.truncate(10), equals('Hello'));
      });

      test('should use custom suffix', () {
        expect('Hello World'.truncate(8, suffix: '>>'), equals('Hello >>'));
      });
    });

    group('isEmail', () {
      test('should return true for valid email', () {
        expect('test@example.com'.isEmail, isTrue);
      });

      test('should return false for invalid email', () {
        expect('invalid-email'.isEmail, isFalse);
      });

      test('should return false for email without domain', () {
        expect('test@'.isEmail, isFalse);
      });
    });

    group('isPhoneNumber', () {
      test('should return true for valid Uzbek phone', () {
        expect('+998901234567'.isPhoneNumber, isTrue);
      });

      test('should return true for phone with spaces', () {
        expect('+998 90 123 45 67'.isPhoneNumber, isTrue);
      });

      test('should return false for non-Uzbek phone', () {
        expect('+1234567890'.isPhoneNumber, isFalse);
      });

      test('should return false for short phone', () {
        expect('+99890123'.isPhoneNumber, isFalse);
      });
    });

    group('isNumeric', () {
      test('should return true for numeric string', () {
        expect('12345'.isNumeric, isTrue);
      });

      test('should return false for string with letters', () {
        expect('123abc'.isNumeric, isFalse);
      });

      test('should return false for empty string', () {
        expect(''.isNumeric, isFalse);
      });
    });

    group('isAlphanumeric', () {
      test('should return true for alphanumeric string', () {
        expect('abc123'.isAlphanumeric, isTrue);
      });

      test('should return false for string with special chars', () {
        expect('abc@123'.isAlphanumeric, isFalse);
      });
    });

    group('isUrl', () {
      test('should return true for valid http URL', () {
        expect('http://example.com'.isUrl, isTrue);
      });

      test('should return true for valid https URL', () {
        expect('https://example.com/path'.isUrl, isTrue);
      });

      test('should return false for invalid URL', () {
        expect('not-a-url'.isUrl, isFalse);
      });
    });

    group('formatPhone', () {
      test('should format valid Uzbek phone', () {
        expect('+998901234567'.formatPhone, equals('+998 90 123 45 67'));
      });

      test('should format phone with existing spaces', () {
        expect('+998 90 123 45 67'.formatPhone, equals('+998 90 123 45 67'));
      });

      test('should return original for invalid format', () {
        expect('1234'.formatPhone, equals('1234'));
      });
    });

    group('cleanPhone', () {
      test('should remove spaces from phone', () {
        expect('+998 90 123 45 67'.cleanPhone, equals('+998901234567'));
      });

      test('should remove dashes from phone', () {
        expect('+998-90-123-45-67'.cleanPhone, equals('+998901234567'));
      });
    });

    group('isNullOrEmpty', () {
      test('should return true for empty string', () {
        expect(''.isNullOrEmpty, isTrue);
      });

      test('should return false for non-empty string', () {
        expect('hello'.isNullOrEmpty, isFalse);
      });
    });

    group('isNotNullOrEmpty', () {
      test('should return true for non-empty string', () {
        expect('hello'.isNotNullOrEmpty, isTrue);
      });

      test('should return false for empty string', () {
        expect(''.isNotNullOrEmpty, isFalse);
      });
    });

    group('nullIfEmpty', () {
      test('should return null for empty string', () {
        expect(''.nullIfEmpty, isNull);
      });

      test('should return string for non-empty', () {
        expect('hello'.nullIfEmpty, equals('hello'));
      });
    });

    group('digitsOnly', () {
      test('should extract only digits', () {
        expect('+998 (90) 123-45-67'.digitsOnly, equals('998901234567'));
      });

      test('should return empty for string without digits', () {
        expect('hello'.digitsOnly, equals(''));
      });
    });

    group('toIntOrNull', () {
      test('should parse numeric string', () {
        expect('12345'.toIntOrNull, equals(12345));
      });

      test('should extract digits and parse', () {
        expect('abc123def'.toIntOrNull, equals(123));
      });

      test('should return null for non-numeric string', () {
        expect('hello'.toIntOrNull, isNull);
      });
    });

    group('toDoubleOrNull', () {
      test('should parse decimal string', () {
        expect('123.45'.toDoubleOrNull, equals(123.45));
      });

      test('should handle comma separators', () {
        expect('1,234.56'.toDoubleOrNull, equals(1234.56));
      });

      test('should return null for invalid string', () {
        expect('hello'.toDoubleOrNull, isNull);
      });
    });

    group('removeAllSpaces', () {
      test('should remove all spaces', () {
        expect('hello world test'.removeAllSpaces, equals('helloworldtest'));
      });
    });

    group('collapseSpaces', () {
      test('should collapse multiple spaces to single', () {
        expect('hello   world'.collapseSpaces, equals('hello world'));
      });

      test('should trim leading and trailing spaces', () {
        expect('  hello  world  '.collapseSpaces, equals('hello world'));
      });
    });

    group('cleanUsername', () {
      test('should remove @ prefix', () {
        expect('@username'.cleanUsername, equals('username'));
      });

      test('should return as-is without @', () {
        expect('username'.cleanUsername, equals('username'));
      });
    });

    group('stripHtml', () {
      test('should remove HTML tags', () {
        expect('<p>Hello <b>World</b></p>'.stripHtml, equals('Hello World'));
      });

      test('should handle text without HTML', () {
        expect('Hello World'.stripHtml, equals('Hello World'));
      });
    });

    group('wordCount', () {
      test('should count words', () {
        expect('Hello World Test'.wordCount, equals(3));
      });

      test('should return 0 for empty string', () {
        expect(''.wordCount, equals(0));
      });

      test('should handle multiple spaces', () {
        expect('Hello   World'.wordCount, equals(2));
      });
    });

    group('characterCountWithoutSpaces', () {
      test('should count characters without spaces', () {
        expect('Hello World'.characterCountWithoutSpaces, equals(10));
      });
    });

    group('reversed', () {
      test('should reverse string', () {
        expect('hello'.reversed, equals('olleh'));
      });

      test('should handle empty string', () {
        expect(''.reversed, equals(''));
      });
    });

    group('toSlug', () {
      test('should convert to slug format', () {
        expect('Hello World Test'.toSlug, equals('hello-world-test'));
      });

      test('should remove special characters', () {
        expect('Hello, World! Test?'.toSlug, equals('hello-world-test'));
      });

      test('should collapse multiple dashes', () {
        expect('Hello - - World'.toSlug, equals('hello-world'));
      });
    });
  });

  group('NullableStringExtensions', () {
    group('isNullOrEmpty', () {
      test('should return true for null', () {
        const String? nullStr = null;
        expect(nullStr.isNullOrEmpty, isTrue);
      });

      test('should return true for empty string', () {
        const String? emptyStr = '';
        expect(emptyStr.isNullOrEmpty, isTrue);
      });

      test('should return false for non-empty string', () {
        const String? str = 'hello';
        expect(str.isNullOrEmpty, isFalse);
      });
    });

    group('isNotNullOrEmpty', () {
      test('should return false for null', () {
        const String? nullStr = null;
        expect(nullStr.isNotNullOrEmpty, isFalse);
      });

      test('should return true for non-empty string', () {
        const String? str = 'hello';
        expect(str.isNotNullOrEmpty, isTrue);
      });
    });

    group('orEmpty', () {
      test('should return empty for null', () {
        const String? nullStr = null;
        expect(nullStr.orEmpty(), equals(''));
      });

      test('should return string for non-null', () {
        const String? str = 'hello';
        expect(str.orEmpty(), equals('hello'));
      });
    });

    group('orDefault', () {
      test('should return default for null', () {
        const String? nullStr = null;
        expect(nullStr.orDefault('default'), equals('default'));
      });

      test('should return string for non-null', () {
        const String? str = 'hello';
        expect(str.orDefault('default'), equals('hello'));
      });
    });
  });
}
