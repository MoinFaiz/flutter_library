import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

/// Repository interface for user profile operations
abstract class ProfileRepository {
  /// Get current user's profile
  Future<Either<Failure, UserProfile>> getProfile();

  /// Update user's profile information
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);

  /// Update user's avatar/profile picture
  Future<Either<Failure, UserProfile>> updateAvatar(String imagePath);

  /// Delete user's avatar
  Future<Either<Failure, UserProfile>> deleteAvatar();

  /// Check if email is available
  Future<Either<Failure, bool>> isEmailAvailable(String email);

  /// Send email verification
  Future<Either<Failure, void>> sendEmailVerification();

  /// Send phone verification code
  Future<Either<Failure, void>> sendPhoneVerification(String phoneNumber);

  /// Verify phone number with code
  Future<Either<Failure, void>> verifyPhoneNumber(String phoneNumber, String verificationCode);
}
