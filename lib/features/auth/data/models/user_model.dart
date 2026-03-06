import '../../domain/entities/user.dart';

/// User model - data layer representation with JSON serialization

class UserModel extends User {
  const UserModel({
    required super.id,
    super.phone,
    super.email,
    required super.fullName,
    super.username,
    super.avatarUrl,
    super.dateOfBirth,
    required super.role,
    required super.isVerified,
    required super.isActive,
    required super.language,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      fullName: json['full_name'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      role: UserRole.fromString(json['role'] as String? ?? 'buyer'),
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      language: json['language'] as String? ?? 'uz',
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
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'role': role.value,
      'is_verified': isVerified,
      'is_active': isActive,
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phone: user.phone,
      email: user.email,
      fullName: user.fullName,
      username: user.username,
      avatarUrl: user.avatarUrl,
      dateOfBirth: user.dateOfBirth,
      role: user.role,
      isVerified: user.isVerified,
      isActive: user.isActive,
      language: user.language,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
}
