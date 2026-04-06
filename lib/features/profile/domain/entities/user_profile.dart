import 'package:equatable/equatable.dart';

/// Entity representing user profile information
class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final ProfileAddress? address;
  final DateTime? birthDate;
  final String? bio;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.address,
    this.birthDate,
    this.bio,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get user's display name (first name or full name)
  String get displayName {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts.first : 'User';
  }

  /// Get user's initials for avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
           email.isNotEmpty &&
           phoneNumber != null &&
           phoneNumber!.isNotEmpty &&
           address != null &&
           address!.isComplete;
  }

  /// Get completion percentage
  double get completionPercentage {
    int completed = 0;
    int total = 6;

    if (name.isNotEmpty) completed++;
    if (email.isNotEmpty) completed++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) completed++;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) completed++;
    if (address != null && address!.isComplete) completed++;
    if (bio != null && bio!.isNotEmpty) completed++;

    return completed / total;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    avatarUrl,
    address,
    birthDate,
    bio,
    isEmailVerified,
    isPhoneVerified,
    createdAt,
    updatedAt,
  ];

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    ProfileAddress? address,
    DateTime? birthDate,
    String? bio,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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

/// Entity representing user's address information
class ProfileAddress extends Equatable {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final bool isDefault;

  const ProfileAddress({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.isDefault = true,
  });

  /// Check if address is complete
  bool get isComplete {
    return street != null &&
           street!.isNotEmpty &&
           city != null &&
           city!.isNotEmpty &&
           state != null &&
           state!.isNotEmpty &&
           zipCode != null &&
           zipCode!.isNotEmpty;
  }

  /// Get formatted address string
  String get formattedAddress {
    final parts = <String>[];
    
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
    street,
    city,
    state,
    zipCode,
    country,
    isDefault,
  ];

  ProfileAddress copyWith({
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return ProfileAddress(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
