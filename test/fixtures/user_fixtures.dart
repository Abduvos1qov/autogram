import 'package:autogram/features/auth/domain/entities/user.dart';

/// Test fixtures for User entity
class UserFixtures {
  UserFixtures._();

  static final DateTime testCreatedAt = DateTime(2024, 1, 1, 12, 0, 0);
  static final DateTime testUpdatedAt = DateTime(2024, 1, 15, 12, 0, 0);

  /// Basic buyer user
  static User get buyer => User(
        id: 'user-123',
        phone: '+998901234567',
        email: 'test@example.com',
        fullName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        role: UserRole.buyer,
        isVerified: true,
        isActive: true,
        language: 'uz',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

  /// Seller user
  static User get seller => User(
        id: 'seller-456',
        phone: '+998901234568',
        email: 'seller@example.com',
        fullName: 'Test Seller',
        avatarUrl: 'https://example.com/seller.jpg',
        role: UserRole.seller,
        isVerified: true,
        isActive: true,
        language: 'uz',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

  /// Unverified user
  static User get unverified => User(
        id: 'unverified-789',
        phone: '+998901234569',
        fullName: 'Unverified User',
        role: UserRole.buyer,
        isVerified: false,
        isActive: true,
        language: 'uz',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

  /// Inactive user
  static User get inactive => User(
        id: 'inactive-000',
        phone: '+998901234560',
        fullName: 'Inactive User',
        role: UserRole.buyer,
        isVerified: true,
        isActive: false,
        language: 'uz',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

  /// User without email
  static User get withoutEmail => User(
        id: 'user-no-email',
        phone: '+998901234561',
        fullName: 'No Email User',
        role: UserRole.buyer,
        isVerified: true,
        isActive: true,
        language: 'uz',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

  /// User with Russian language preference
  static User get russianLanguage => User(
        id: 'user-russian',
        phone: '+998901234562',
        email: 'russian@example.com',
        fullName: 'Russian User',
        role: UserRole.buyer,
        isVerified: true,
        isActive: true,
        language: 'ru',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
      );

  /// List of users for pagination testing
  static List<User> get userList => [
        buyer,
        seller,
        unverified,
      ];
}
