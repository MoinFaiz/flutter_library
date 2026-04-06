import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

/// Data model for user profile
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    super.avatarUrl,
    super.address,
    super.birthDate,
    super.bio,
    super.isEmailVerified = false,
    super.isPhoneVerified = false,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      address: json['address'] != null
          ? ProfileAddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      bio: json['bio'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'address': address != null ? ProfileAddressModel.fromEntity(address!).toJson() : null,
      'birthDate': birthDate?.toIso8601String(),
      'bio': bio,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create model from entity
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      avatarUrl: profile.avatarUrl,
      address: profile.address,
      birthDate: profile.birthDate,
      bio: profile.bio,
      isEmailVerified: profile.isEmailVerified,
      isPhoneVerified: profile.isPhoneVerified,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  /// Create a copy with updated fields
  @override
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    Object? avatarUrl = _undefined,
    ProfileAddress? address,
    DateTime? birthDate,
    String? bio,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl == _undefined ? this.avatarUrl : avatarUrl as String?,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      bio: bio ?? this.bio,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Sentinel value for optional parameters
const Object _undefined = Object();

/// Data model for profile address
class ProfileAddressModel extends ProfileAddress {
  const ProfileAddressModel({
    super.street,
    super.city,
    super.state,
    super.zipCode,
    super.country,
    super.isDefault = true,
  });

  /// Create model from JSON
  factory ProfileAddressModel.fromJson(Map<String, dynamic> json) {
    return ProfileAddressModel(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
      isDefault: json['isDefault'] as bool? ?? true,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  /// Create model from entity
  factory ProfileAddressModel.fromEntity(ProfileAddress address) {
    return ProfileAddressModel(
      street: address.street,
      city: address.city,
      state: address.state,
      zipCode: address.zipCode,
      country: address.country,
      isDefault: address.isDefault,
    );
  }

  /// Create a copy with updated fields
  @override
  ProfileAddressModel copyWith({
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return ProfileAddressModel(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
