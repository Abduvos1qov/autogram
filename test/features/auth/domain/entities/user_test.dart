import 'package:autogram/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/user_fixtures.dart';

void main() {
  group('User', () {
    group('copyWith', () {
      test('should return a new User with updated fullName', () {
        final user = UserFixtures.buyer;
        final updated = user.copyWith(fullName: 'New Name');

        expect(updated.fullName, 'New Name');
        expect(updated.id, user.id);
        expect(updated.email, user.email);
      });

      test('should return a new User with updated role', () {
        final user = UserFixtures.buyer;
        final updated = user.copyWith(role: UserRole.seller);

        expect(updated.role, UserRole.seller);
        expect(updated.id, user.id);
      });

      test('should return a new User with updated username', () {
        final user = UserFixtures.buyer;
        final updated = user.copyWith(username: 'new_username');

        expect(updated.username, 'new_username');
      });

      test('should return identical User when no params provided', () {
        final user = UserFixtures.buyer;
        final updated = user.copyWith();

        expect(updated, user);
      });
    });

    group('isSeller', () {
      test('should return true for seller role', () {
        expect(UserFixtures.seller.isSeller, true);
      });

      test('should return false for buyer role', () {
        expect(UserFixtures.buyer.isSeller, false);
      });
    });

    group('isBuyer', () {
      test('should return true for buyer role', () {
        expect(UserFixtures.buyer.isBuyer, true);
      });

      test('should return false for seller role', () {
        expect(UserFixtures.seller.isBuyer, false);
      });
    });

    group('hasUsername', () {
      test('should return false when username is null', () {
        final user = UserFixtures.buyer.copyWith();
        // buyer fixture has no username set
        final noUsername = User(
          id: 'test',
          fullName: 'Test',
          role: UserRole.buyer,
          isVerified: true,
          isActive: true,
          language: 'uz',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );
        expect(noUsername.hasUsername, false);
      });

      test('should return false when username is empty', () {
        final user = UserFixtures.buyer.copyWith(username: '');
        expect(user.hasUsername, false);
      });

      test('should return true when username is set', () {
        final user = UserFixtures.buyer.copyWith(username: 'testuser');
        expect(user.hasUsername, true);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        final user1 = UserFixtures.buyer;
        final user2 = UserFixtures.buyer;
        expect(user1, user2);
      });

      test('should not be equal when properties differ', () {
        final user1 = UserFixtures.buyer;
        final user2 = UserFixtures.seller;
        expect(user1, isNot(user2));
      });
    });
  });

  group('UserRole', () {
    group('fromString', () {
      test('should return buyer for "buyer"', () {
        expect(UserRole.fromString('buyer'), UserRole.buyer);
      });

      test('should return seller for "seller"', () {
        expect(UserRole.fromString('seller'), UserRole.seller);
      });

      test('should return buyer for unknown value', () {
        expect(UserRole.fromString('unknown'), UserRole.buyer);
      });

      test('should be case insensitive', () {
        expect(UserRole.fromString('SELLER'), UserRole.seller);
        expect(UserRole.fromString('Buyer'), UserRole.buyer);
      });
    });

    group('value', () {
      test('should return "buyer" for buyer', () {
        expect(UserRole.buyer.value, 'buyer');
      });

      test('should return "seller" for seller', () {
        expect(UserRole.seller.value, 'seller');
      });
    });
  });
}
