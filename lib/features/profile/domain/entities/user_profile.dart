import 'package:equatable/equatable.dart';

/// User profile entity

class UserProfile extends Equatable {
  final String id;
  final String phone;
  final String? email;
  final String fullName;

  /// Public @handle. Lowercase alphanumeric + underscore, 3–30 chars. Unique.
  /// Backend column TODO — may be null until migration lands.
  final String? username;
  final String? avatarUrl;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String language;
  final String? sellerProfileId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    this.username,
    this.avatarUrl,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.language,
    this.sellerProfileId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSeller => role == 'seller' && sellerProfileId != null;
  bool get isBuyer => role == 'buyer';

  UserProfile copyWith({
    String? id,
    String? phone,
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? role,
    bool? isVerified,
    bool? isActive,
    String? language,
    String? sellerProfileId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      language: language ?? this.language,
      sellerProfileId: sellerProfileId ?? this.sellerProfileId,
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
        role,
        isVerified,
        isActive,
        language,
        sellerProfileId,
        createdAt,
        updatedAt,
      ];
}
