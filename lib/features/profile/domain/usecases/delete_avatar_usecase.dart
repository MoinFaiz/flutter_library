import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';

/// Use case for deleting user avatar
class DeleteAvatarUseCase {
  final ProfileRepository repository;

  DeleteAvatarUseCase({required this.repository});

  Future<Either<Failure, UserProfile>> call() async {
    return await repository.deleteAvatar();
  }
}
