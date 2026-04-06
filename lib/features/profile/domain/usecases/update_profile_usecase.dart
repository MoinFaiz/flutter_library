import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Either<Failure, UserProfile>> call(UserProfile profile) async {
    // Validate profile data
    if (profile.name.trim().isEmpty) {
      return const Left(ValidationFailure('Name cannot be empty'));
    }

    if (profile.email.trim().isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(profile.email)) {
      return const Left(ValidationFailure('Please enter a valid email address'));
    }

    // Validate phone number if provided
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
      if (!phoneRegex.hasMatch(profile.phoneNumber!.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
        return const Left(ValidationFailure('Please enter a valid phone number'));
      }
    }

    return await repository.updateProfile(profile);
  }
}
