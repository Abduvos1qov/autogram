import 'package:autogram/features/profile/data/models/user_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileModel', () {
    final fullJson = {
      'id': 'user-1',
      'phone': '+998901112233',
      'email': 'user@example.com',
      'full_name': 'Test User',
      'avatar_url': 'https://cdn.example.com/avatar.jpg',
      'role': 'seller',
      'is_verified': true,
      'is_active': true,
      'language': 'ru',
      'seller_profile_id': 'seller-1',
      'created_at': '2024-01-01T12:00:00.000Z',
      'updated_at': '2024-06-01T12:00:00.000Z',
    };

    test('fromJson maps every field', () {
      final model = UserProfileModel.fromJson(fullJson);
      expect(model.id, 'user-1');
      expect(model.phone, '+998901112233');
      expect(model.email, 'user@example.com');
      expect(model.fullName, 'Test User');
      expect(model.avatarUrl, 'https://cdn.example.com/avatar.jpg');
      expect(model.role, 'seller');
      expect(model.isVerified, isTrue);
      expect(model.isActive, isTrue);
      expect(model.language, 'ru');
      expect(model.sellerProfileId, 'seller-1');
    });

    test('fromJson defaults role to "buyer" when missing', () {
      final json = Map<String, dynamic>.from(fullJson)..remove('role');
      final model = UserProfileModel.fromJson(json);
      expect(model.role, 'buyer');
      expect(model.isSeller, isFalse);
    });

    test('fromJson defaults language to "uz" when missing', () {
      final json = Map<String, dynamic>.from(fullJson)..remove('language');
      final model = UserProfileModel.fromJson(json);
      expect(model.language, 'uz');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'user-2',
        'phone': '+998900000000',
        'full_name': 'Bare User',
        'created_at': '2024-01-01T12:00:00.000Z',
        'updated_at': '2024-06-01T12:00:00.000Z',
      };
      final model = UserProfileModel.fromJson(json);
      expect(model.email, isNull);
      expect(model.avatarUrl, isNull);
      expect(model.isVerified, isFalse);
      expect(model.isActive, isTrue);
      expect(model.role, 'buyer');
    });

    test('toJson preserves identity-relevant keys', () {
      final model = UserProfileModel.fromJson(fullJson);
      final json = model.toJson();
      expect(json['id'], 'user-1');
      expect(json['phone'], '+998901112233');
      expect(json['email'], 'user@example.com');
      expect(json['full_name'], 'Test User');
      expect(json['role'], 'seller');
      expect(json['language'], 'ru');
      expect(json['avatar_url'], 'https://cdn.example.com/avatar.jpg');
    });
  });
}
