import 'package:autogram/features/seller/domain/entities/contact_phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactPhoneLabel.fromString', () {
    test('returns matching label for canned value', () {
      expect(
        ContactPhoneLabel.fromString('sales'),
        ContactPhoneLabel.sales,
      );
    });

    test('is case-insensitive', () {
      expect(
        ContactPhoneLabel.fromString('OFFICE'),
        ContactPhoneLabel.office,
      );
    });

    test('falls back to other for unknown / null', () {
      expect(
        ContactPhoneLabel.fromString(null),
        ContactPhoneLabel.other,
      );
      expect(
        ContactPhoneLabel.fromString('alien'),
        ContactPhoneLabel.other,
      );
    });
  });

  group('ContactPhone.fromAny', () {
    test('parses legacy plain string element with other label', () {
      final phone = ContactPhone.fromAny('+998901234567');
      expect(phone, isNotNull);
      expect(phone!.phone, '+998901234567');
      expect(phone.label, ContactPhoneLabel.other);
      expect(phone.customLabel, isNull);
    });

    test('parses new map shape', () {
      final phone = ContactPhone.fromAny({
        'phone': '+998901234567',
        'label': 'sales',
      });
      expect(phone, isNotNull);
      expect(phone!.label, ContactPhoneLabel.sales);
    });

    test('reads custom_label only when label is other', () {
      final other = ContactPhone.fromAny({
        'phone': '+998901234567',
        'label': 'other',
        'custom_label': 'Servis',
      });
      expect(other?.customLabel, 'Servis');

      final canned = ContactPhone.fromAny({
        'phone': '+998901234567',
        'label': 'sales',
        'custom_label': 'Servis',
      });
      // Canned label ignores custom_label so storefront chip stays consistent.
      expect(canned?.customLabel, isNull);
    });

    test('returns null for empty string and unknown shape', () {
      expect(ContactPhone.fromAny(''), isNull);
      expect(ContactPhone.fromAny(123), isNull);
      expect(ContactPhone.fromAny(null), isNull);
    });

    test('returns null when phone field is empty in map', () {
      expect(ContactPhone.fromAny({'phone': '', 'label': 'sales'}), isNull);
    });
  });

  group('ContactPhone serialization', () {
    test('toMap roundtrip with canned label drops custom_label', () {
      const phone = ContactPhone(
        phone: '+998901234567',
        label: ContactPhoneLabel.office,
      );
      final map = phone.toMap();
      expect(map, {'phone': '+998901234567', 'label': 'office'});
      expect(ContactPhone.fromMap(map), phone);
    });

    test('toMap roundtrip with other label keeps custom_label', () {
      const phone = ContactPhone(
        phone: '+998901234567',
        label: ContactPhoneLabel.other,
        customLabel: 'Servis',
      );
      final map = phone.toMap();
      expect(map['custom_label'], 'Servis');
      expect(ContactPhone.fromMap(map), phone);
    });
  });

  group('ContactPhone.copyWith', () {
    test('clearCustomLabel drops the field', () {
      const phone = ContactPhone(
        phone: '+998901234567',
        label: ContactPhoneLabel.other,
        customLabel: 'Servis',
      );
      final next = phone.copyWith(
        label: ContactPhoneLabel.sales,
        clearCustomLabel: true,
      );
      expect(next.customLabel, isNull);
      expect(next.label, ContactPhoneLabel.sales);
    });
  });
}
