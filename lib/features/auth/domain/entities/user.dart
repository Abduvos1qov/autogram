import 'package:equatable/equatable.dart';

/// User entity - core domain object

class User extends Equatable {
  final String id;
  final String? phone;
  final String? email;
  final String fullName;
  final String? username;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final UserRole role;
  final bool isVerified;
  final bool isActive;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    this.phone,
    this.email,
    required this.fullName,
    this.username,
    this.avatarUrl,
    this.dateOfBirth,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSeller => role == UserRole.seller;
  bool get isBuyer => role == UserRole.buyer;
  bool get hasUsername => username != null && username!.isNotEmpty;

  User copyWith({
    String? id,
    String? phone,
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    DateTime? dateOfBirth,
    UserRole? role,
    bool? isVerified,
    bool? isActive,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        email,
        fullName,
        username,
        avatarUrl,
        dateOfBirth,
        role,
        isVerified,
        isActive,
        language,
        createdAt,
        updatedAt,
      ];
}

enum UserRole {
  buyer,
  seller;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'seller':
        return UserRole.seller;
      case 'buyer':
      default:
        return UserRole.buyer;
    }
  }

  String get value {
    switch (this) {
      case UserRole.seller:
        return 'seller';
      case UserRole.buyer:
        return 'buyer';
    }
  }
}
