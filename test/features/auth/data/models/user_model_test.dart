import 'package:autogram/features/auth/data/models/user_model.dart';
import 'package:autogram/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/user_fixtures.dart';

void main() {
  final tCreatedAt = DateTime(2024, 1, 1, 12, 0, 0);
  final tUpdatedAt = DateTime(2024, 1, 15, 12, 0, 0);

  final tFullJson = <String, dynamic>{
    'id': 'user-123',
    'phone': '+998901234567',
    'email': 'test@example.com',
    'full_name': 'Test User',
    'username': 'testuser',
    'avatar_url': 'https://example.com/avatar.jpg',
    'date_of_birth': '2000-01-15T00:00:00.000',
    'role': 'buyer',
    'is_verified': true,
    'is_active': true,
    'language': 'uz',
    'created_at': tCreatedAt.toIso8601String(),
    'updated_at': tUpdatedAt.toIso8601String(),
  };

  final tMinimalJson = <String, dynamic>{
    'id': 'user-min',
    'full_name': 'Minimal User',
    'created_at': tCreatedAt.toIso8601String(),
    'updated_at': tUpdatedAt.toIso8601String(),
  };

  group('UserModel', () {
    group('fromJson', () {
      test('should create UserModel from full JSON', () {
        final model = UserModel.fromJson(tFullJson);

        expect(model.id, 'user-123');
        expect(model.phone, '+998901234567');
        expect(model.email, 'test@example.com');
        expect(model.fullName, 'Test User');
        expect(model.username, 'testuser');
        expect(model.avatarUrl, 'https://example.com/avatar.jpg');
        expect(model.dateOfBirth, DateTime(2000, 1, 15));
        expect(model.role, UserRole.buyer);
        expect(model.isVerified, true);
        expect(model.isActive, true);
        expect(model.language, 'uz');
      });

      test('should create UserModel from minimal JSON with defaults', () {
        final model = UserModel.fromJson(tMinimalJson);

        expect(model.id, 'user-min');
        expect(model.fullName, 'Minimal User');
        expect(model.phone, isNull);
        expect(model.email, isNull);
        expect(model.username, isNull);
        expect(model.avatarUrl, isNull);
        expect(model.dateOfBirth, isNull);
        expect(model.role, UserRole.buyer);
        expect(model.isVerified, false);
        expect(model.isActive, true);
        expect(model.language, 'uz');
      });

      test('should parse seller role from JSON', () {
        final json = Map<String, dynamic>.from(tFullJson)..['role'] = 'seller';
        final model = UserModel.fromJson(json);

        expect(model.role, UserRole.seller);
      });
    });

    group('toJson', () {
      test('should convert UserModel to JSON with snake_case keys', () {
        final model = UserModel.fromJson(tFullJson);
        final json = model.toJson();

        expect(json['id'], 'user-123');
        expect(json['full_name'], 'Test User');
        expect(json['avatar_url'], 'https://example.com/avatar.jpg');
        expect(json['is_verified'], true);
        expect(json['is_active'], true);
        expect(json['role'], 'buyer');
        expect(json.containsKey('fullName'), false);
        expect(json.containsKey('avatarUrl'), false);
      });

      test('should include null values for optional fields', () {
        final model = UserModel.fromJson(tMinimalJson);
        final json = model.toJson();

        expect(json['phone'], isNull);
        expect(json['email'], isNull);
        expect(json['username'], isNull);
        expect(json['avatar_url'], isNull);
        expect(json['date_of_birth'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create UserModel from User entity', () {
        final user = UserFixtures.buyer;
        final model = UserModel.fromEntity(user);

        expect(model.id, user.id);
        expect(model.fullName, user.fullName);
        expect(model.email, user.email);
        expect(model.phone, user.phone);
        expect(model.role, user.role);
        expect(model.isVerified, user.isVerified);
        expect(model, isA<UserModel>());
        expect(model, isA<User>());
      });
    });

    group('copyWith', () {
      test('should return a new UserModel with updated fields', () {
        final model = UserModel.fromJson(tFullJson);
        final updated = model.copyWith(fullName: 'Updated Name');

        expect(updated.fullName, 'Updated Name');
        expect(updated.id, model.id);
        expect(updated, isA<UserModel>());
      });

      test('should return identical UserModel when no params provided', () {
        final model = UserModel.fromJson(tFullJson);
        final copy = model.copyWith();

        expect(copy, model);
      });
    });
  });
}
