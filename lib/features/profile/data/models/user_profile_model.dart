import '../../domain/entities/user_profile.dart';

/// User profile data model

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.phone,
    super.email,
    required super.fullName,
    super.username,
    super.avatarUrl,
    required super.role,
    required super.isVerified,
    required super.isActive,
    required super.language,
    super.sellerProfileId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'buyer',
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      language: json['language'] as String? ?? 'uz',
      sellerProfileId: json['seller_profile_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'role': role,
      'is_verified': isVerified,
      'is_active': isActive,
      'language': language,
    };
  }
}
