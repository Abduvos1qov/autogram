import 'package:flutter_test/flutter_test.dart';

import 'package:autogram/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validatePhone', () {
      test('should return null when phone is null (optional)', () {
        final result = Validators.validatePhone(null);
        expect(result, isNull);
      });

      test('should return null when phone is empty (optional)', () {
        final result = Validators.validatePhone('');
        expect(result, isNull);
      });

      test('should return error for invalid phone format', () {
        final result = Validators.validatePhone('+1234567890');
        expect(result, isNotNull);
        expect(result, contains('Noto\'g\'ri'));
      });

      test('should return error for phone without country code', () {
        final result = Validators.validatePhone('901234567');
        expect(result, isNotNull);
      });

      test('should return null for valid Uzbek phone number', () {
        final result = Validators.validatePhone('+998901234567');
        expect(result, isNull);
      });

      test('should return null for valid phone with spaces', () {
        final result = Validators.validatePhone('+998 90 123 45 67');
        expect(result, isNull);
      });

      test('should return null for valid phone with dashes', () {
        final result = Validators.validatePhone('+998-90-123-45-67');
        expect(result, isNull);
      });
    });

    group('validateOtp', () {
      test('should return error when OTP is null', () {
        final result = Validators.validateOtp(null);
        expect(result, isNotNull);
        expect(result, contains('Tasdiqlash'));
      });

      test('should return error when OTP is empty', () {
        final result = Validators.validateOtp('');
        expect(result, isNotNull);
      });

      test('should return error when OTP has wrong length', () {
        final result = Validators.validateOtp('1234');
        expect(result, isNotNull);
        expect(result, contains('6'));
      });

      test('should return error when OTP contains non-digits', () {
        final result = Validators.validateOtp('12345a');
        expect(result, isNotNull);
        expect(result, contains('raqam'));
      });

      test('should return null for valid 6-digit OTP', () {
        final result = Validators.validateOtp('123456');
        expect(result, isNull);
      });

      test('should support custom OTP length', () {
        final result = Validators.validateOtp('1234', length: 4);
        expect(result, isNull);
      });
    });

    group('validateEmail', () {
      test('should return null when email is null (optional)', () {
        final result = Validators.validateEmail(null);
        expect(result, isNull);
      });

      test('should return null when email is empty (optional)', () {
        final result = Validators.validateEmail('');
        expect(result, isNull);
      });

      test('should return error for invalid email format', () {
        final result = Validators.validateEmail('invalid-email');
        expect(result, isNotNull);
        expect(result, contains('email'));
      });

      test('should return error for email without domain', () {
        final result = Validators.validateEmail('test@');
        expect(result, isNotNull);
      });

      test('should return null for valid email', () {
        final result = Validators.validateEmail('test@example.com');
        expect(result, isNull);
      });

      test('should return null for email with subdomain', () {
        final result = Validators.validateEmail('test@mail.example.com');
        expect(result, isNull);
      });
    });

    group('validateRequired', () {
      test('should return error when value is null', () {
        final result = Validators.validateRequired(null);
        expect(result, isNotNull);
        expect(result, contains('shart'));
      });

      test('should return error when value is empty', () {
        final result = Validators.validateRequired('');
        expect(result, isNotNull);
      });

      test('should return error when value is only whitespace', () {
        final result = Validators.validateRequired('   ');
        expect(result, isNotNull);
      });

      test('should return error with field name when provided', () {
        final result = Validators.validateRequired(null, fieldName: 'Ism');
        expect(result, isNotNull);
        expect(result, contains('Ism'));
      });

      test('should return null for valid value', () {
        final result = Validators.validateRequired('Test value');
        expect(result, isNull);
      });
    });

    group('validateName', () {
      test('should return error when name is null', () {
        final result = Validators.validateName(null);
        expect(result, isNotNull);
        expect(result, contains('Ism'));
      });

      test('should return error when name is empty', () {
        final result = Validators.validateName('');
        expect(result, isNotNull);
      });

      test('should return error when name is too short', () {
        final result = Validators.validateName('A');
        expect(result, isNotNull);
        expect(result, contains('2'));
      });

      test('should return error when name is too long', () {
        final result = Validators.validateName('A' * 101);
        expect(result, isNotNull);
        expect(result, contains('100'));
      });

      test('should return null for valid name', () {
        final result = Validators.validateName('John Doe');
        expect(result, isNull);
      });

      test('should return null for name with 2 characters', () {
        final result = Validators.validateName('Jo');
        expect(result, isNull);
      });
    });

    group('validatePrice', () {
      test('should return error when price is null', () {
        final result = Validators.validatePrice(null);
        expect(result, isNotNull);
        expect(result, contains('Narx'));
      });

      test('should return error when price is empty', () {
        final result = Validators.validatePrice('');
        expect(result, isNotNull);
      });

      test('should return error for invalid price format', () {
        final result = Validators.validatePrice('abc');
        expect(result, isNotNull);
        expect(result, contains('format'));
      });

      test('should return error when price is zero', () {
        final result = Validators.validatePrice('0');
        expect(result, isNotNull);
        expect(result, contains('0'));
      });

      test('should return error when price is negative', () {
        final result = Validators.validatePrice('-100');
        expect(result, isNotNull);
      });

      test('should return error when price is too high', () {
        final result = Validators.validatePrice('20000000');
        expect(result, isNotNull);
        expect(result, contains('katta'));
      });

      test('should return null for valid price', () {
        final result = Validators.validatePrice('25000');
        expect(result, isNull);
      });

      test('should handle price with comma separators', () {
        final result = Validators.validatePrice('25,000');
        expect(result, isNull);
      });
    });

    group('validateYear', () {
      test('should return error when year is null', () {
        final result = Validators.validateYear(null);
        expect(result, isNotNull);
        expect(result, contains('Yil'));
      });

      test('should return error when year is empty', () {
        final result = Validators.validateYear('');
        expect(result, isNotNull);
      });

      test('should return error for invalid year format', () {
        final result = Validators.validateYear('abc');
        expect(result, isNotNull);
        expect(result, contains('format'));
      });

      test('should return error when year is too old', () {
        final result = Validators.validateYear('1800');
        expect(result, isNotNull);
        expect(result, contains('1900'));
      });

      test('should return error when year is in far future', () {
        final futureYear = DateTime.now().year + 5;
        final result = Validators.validateYear(futureYear.toString());
        expect(result, isNotNull);
      });

      test('should return null for valid current year', () {
        final result = Validators.validateYear('2024');
        expect(result, isNull);
      });

      test('should return null for valid old year', () {
        final result = Validators.validateYear('1990');
        expect(result, isNull);
      });

      test('should return null for next year', () {
        final nextYear = DateTime.now().year + 1;
        final result = Validators.validateYear(nextYear.toString());
        expect(result, isNull);
      });
    });

    group('validateMileage', () {
      test('should return error when mileage is null', () {
        final result = Validators.validateMileage(null);
        expect(result, isNotNull);
        expect(result, contains('masofa'));
      });

      test('should return error when mileage is empty', () {
        final result = Validators.validateMileage('');
        expect(result, isNotNull);
      });

      test('should return error for invalid mileage format', () {
        final result = Validators.validateMileage('abc');
        expect(result, isNotNull);
        expect(result, contains('format'));
      });

      test('should return error when mileage is negative', () {
        final result = Validators.validateMileage('-100');
        expect(result, isNotNull);
        expect(result, contains('manfiy'));
      });

      test('should return error when mileage is too high', () {
        final result = Validators.validateMileage('2000000');
        expect(result, isNotNull);
        expect(result, contains('katta'));
      });

      test('should return null for valid mileage', () {
        final result = Validators.validateMileage('50000');
        expect(result, isNull);
      });

      test('should handle mileage with comma separators', () {
        final result = Validators.validateMileage('50,000');
        expect(result, isNull);
      });
    });

    group('validateDescription', () {
      test('should return null when description is null (optional)', () {
        final result = Validators.validateDescription(null);
        expect(result, isNull);
      });

      test('should return null when description is empty (optional)', () {
        final result = Validators.validateDescription('');
        expect(result, isNull);
      });

      test('should return error when description is too short', () {
        final result = Validators.validateDescription('Short');
        expect(result, isNotNull);
        expect(result, contains('10'));
      });

      test('should return error when description is too long', () {
        final result = Validators.validateDescription('A' * 2001);
        expect(result, isNotNull);
        expect(result, contains('2000'));
      });

      test('should return null for valid description', () {
        final result = Validators.validateDescription(
            'This is a valid description with enough characters.');
        expect(result, isNull);
      });
    });

    group('validateTitle', () {
      test('should return error when title is null', () {
        final result = Validators.validateTitle(null);
        expect(result, isNotNull);
        expect(result, contains('Sarlavha'));
      });

      test('should return error when title is empty', () {
        final result = Validators.validateTitle('');
        expect(result, isNotNull);
      });

      test('should return error when title is too short', () {
        final result = Validators.validateTitle('Hi');
        expect(result, isNotNull);
        expect(result, contains('5'));
      });

      test('should return error when title is too long', () {
        final result = Validators.validateTitle('A' * 201);
        expect(result, isNotNull);
        expect(result, contains('200'));
      });

      test('should return null for valid title', () {
        final result = Validators.validateTitle('Chevrolet Malibu 2020');
        expect(result, isNull);
      });
    });

    group('validateUrl', () {
      test('should return null when URL is null (optional)', () {
        final result = Validators.validateUrl(null);
        expect(result, isNull);
      });

      test('should return null when URL is empty (optional)', () {
        final result = Validators.validateUrl('');
        expect(result, isNull);
      });

      test('should return error for invalid URL', () {
        final result = Validators.validateUrl('not-a-url');
        expect(result, isNotNull);
        expect(result, contains('URL'));
      });

      test('should return null for valid http URL', () {
        final result = Validators.validateUrl('http://example.com');
        expect(result, isNull);
      });

      test('should return null for valid https URL', () {
        final result = Validators.validateUrl('https://example.com/path');
        expect(result, isNull);
      });
    });

    group('validateUsername', () {
      test('should return null when username is null (optional)', () {
        final result = Validators.validateUsername(null);
        expect(result, isNull);
      });

      test('should return null when username is empty (optional)', () {
        final result = Validators.validateUsername('');
        expect(result, isNull);
      });

      test('should return error when username is too short', () {
        final result = Validators.validateUsername('ab');
        expect(result, isNotNull);
        expect(result, contains('3'));
      });

      test('should return error when username is too long', () {
        final result = Validators.validateUsername('a' * 33);
        expect(result, isNotNull);
        expect(result, contains('32'));
      });

      test('should return error for invalid characters', () {
        final result = Validators.validateUsername('user@name');
        expect(result, isNotNull);
      });

      test('should return null for valid username', () {
        final result = Validators.validateUsername('valid_user123');
        expect(result, isNull);
      });

      test('should handle username with @ prefix', () {
        final result = Validators.validateUsername('@username');
        expect(result, isNull);
      });
    });
  });
}
