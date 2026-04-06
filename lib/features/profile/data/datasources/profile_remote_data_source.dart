import 'package:flutter_library/features/profile/data/models/user_profile_model.dart';
import 'package:dio/dio.dart';

/// Abstract interface for profile remote data source
abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<UserProfileModel> updateAvatar(String imagePath);
  Future<UserProfileModel> deleteAvatar();
  Future<void> sendEmailVerification();
  Future<void> sendPhoneVerification(String phoneNumber);
  Future<void> verifyPhoneCode(String phoneNumber, String code);
  Future<bool> isEmailAvailable(String email);
  Future<bool> isPhoneAvailable(String phoneNumber);
}

/// Mock implementation of profile remote data source
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  // Mock current user profile data
  static final UserProfileModel _mockProfile = UserProfileModel(
    id: 'user_001',
    name: 'John Doe',
    email: 'john.doe@example.com',
    phoneNumber: '+1 (555) 123-4567',
    avatarUrl: null,
    address: const ProfileAddressModel(
      street: '123 Main Street, Apt 4B',
      city: 'New York',
      state: 'NY',
      zipCode: '10001',
      country: 'United States',
      isDefault: true,
    ),
    birthDate: DateTime(1990, 5, 15),
    bio: 'Book lover and avid reader. Always looking for new stories to explore.',
    isEmailVerified: true,
    isPhoneVerified: false,
    createdAt: DateTime(2023, 1, 15),
    updatedAt: DateTime.now(),
  );

  static UserProfileModel _currentProfile = _mockProfile;

  /// Get current user's profile
  @override
  Future<UserProfileModel> getProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _currentProfile;
  }

  /// Update user's profile information
  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Update the current profile with new information
    _currentProfile = profile.copyWith(
      updatedAt: DateTime.now(),
    );
    
    return _currentProfile;
  }

  /// Update user's avatar/profile picture
  @override
  Future<UserProfileModel> updateAvatar(String imagePath) async {
    // Simulate network delay for image upload
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Mock image URL after upload
    const mockAvatarUrl = 'https://example.com/avatars/user_001.jpg';
    
    // Update current profile with new avatar URL
    _currentProfile = _currentProfile.copyWith(
      avatarUrl: mockAvatarUrl,
      updatedAt: DateTime.now(),
    );
    
    return _currentProfile;
  }

  /// Delete user's avatar
  @override
  Future<UserProfileModel> deleteAvatar() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Remove avatar URL from current profile
    _currentProfile = _currentProfile.copyWith(
      avatarUrl: null,
      updatedAt: DateTime.now(),
    );
    
    return _currentProfile;
  }

  /// Check if email is available
  @override
  Future<bool> isEmailAvailable(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Mock logic: email is available if it's not the current user's email
    // and not one of the "taken" emails
    final takenEmails = [
      'admin@example.com',
      'test@example.com',
      'user@example.com',
    ];
    
    return !takenEmails.contains(email.toLowerCase()) && 
           email.toLowerCase() != _currentProfile.email.toLowerCase();
  }

  /// Send email verification
  @override
  Future<void> sendEmailVerification() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // In real implementation, this would send an email
    // For mock, we'll just simulate success
  }

  /// Send phone verification code
  @override
  Future<void> sendPhoneVerification(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // In real implementation, this would send SMS
    // For mock, we'll just simulate success
  }

  /// Verify phone number with code
  @override
  Future<void> verifyPhoneCode(String phoneNumber, String code) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Mock verification: accept code "123456"
    if (code != '123456') {
      throw Exception('Invalid verification code');
    }
    
    // Mark phone as verified
    _currentProfile = _currentProfile.copyWith(
      phoneNumber: phoneNumber,
      isPhoneVerified: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if phone number is available
  @override
  Future<bool> isPhoneAvailable(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Mock logic: phone is available if it's not the current user's phone
    // and not one of the "taken" phone numbers
    final takenPhones = [
      '+1 (555) 000-0000',
      '+1 (555) 111-1111',
      '+1 (555) 999-9999',
    ];
    
    return !takenPhones.contains(phoneNumber) && 
           phoneNumber != _currentProfile.phoneNumber;
  }
}
