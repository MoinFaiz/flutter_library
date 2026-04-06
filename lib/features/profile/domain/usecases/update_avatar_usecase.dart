import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';

/// Use case for updating user avatar
class UpdateAvatarUseCase {
  final ProfileRepository repository;

  UpdateAvatarUseCase({required this.repository});

  Future<Either<Failure, UserProfile>> call(String imagePath) async {
    if (imagePath.trim().isEmpty) {
      return const Left(ValidationFailure('Please select an image'));
    }

    // Validate file type
    final supportedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    final extension = imagePath.toLowerCase().split('.').last;
    if (!supportedExtensions.contains('.$extension')) {
      return const Left(ValidationFailure('Unsupported file type. Please use JPG, PNG, or GIF'));
    }

    return await repository.updateAvatar(imagePath);
  }
}
