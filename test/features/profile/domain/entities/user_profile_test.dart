import 'package:autogram/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/profile_fixtures.dart';

void main() {
  group('UserProfile', () {
    test('isBuyer is true for role=buyer', () {
      expect(ProfileFixtures.buyer.isBuyer, isTrue);
      expect(ProfileFixtures.buyer.isSeller, isFalse);
    });

    test('isSeller requires both role=seller AND sellerProfileId', () {
      expect(ProfileFixtures.sellerUser.isSeller, isTrue);
      expect(ProfileFixtures.sellerUserWithoutId.isSeller, isFalse,
          reason: 'role alone is not enough');
    });

    test('copyWith preserves untouched fields', () {
      final updated =
          ProfileFixtures.buyer.copyWith(fullName: 'New Name');
      expect(updated.fullName, 'New Name');
      expect(updated.id, ProfileFixtures.buyer.id);
      expect(updated.email, ProfileFixtures.buyer.email);
      expect(updated.role, ProfileFixtures.buyer.role);
    });

    test('copyWith allows promoting buyer to seller', () {
      final promoted = ProfileFixtures.buyer.copyWith(
        role: 'seller',
        sellerProfileId: 'seller-001',
      );
      expect(promoted.isSeller, isTrue);
    });

    test('Equatable equality works', () {
      final a = ProfileFixtures.buyer;
      final b = ProfileFixtures.buyer;
      expect(a, equals(b));
    });

    test('Equatable inequality on different fullName', () {
      final a = ProfileFixtures.buyer;
      final b = ProfileFixtures.buyer.copyWith(fullName: 'Different');
      expect(a, isNot(equals(b)));
    });

    test('UserProfile constructs with required fields', () {
      final profile = UserProfile(
        id: 'x',
        phone: '+998900000000',
        fullName: 'X Y',
        role: 'buyer',
        isVerified: false,
        isActive: true,
        language: 'uz',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      expect(profile.id, 'x');
      expect(profile.email, isNull);
      expect(profile.avatarUrl, isNull);
      expect(profile.sellerProfileId, isNull);
      expect(profile.isBuyer, isTrue);
    });
  });
}
