import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_library/features/profile/data/models/user_profile_model.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final profileModel = profile is UserProfileModel 
          ? profile 
          : UserProfileModel.fromEntity(profile);
      final updatedProfile = await remoteDataSource.updateProfile(profileModel);
      return Right(updatedProfile);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateAvatar(String imagePath) async {
    try {
      final updatedProfile = await remoteDataSource.updateAvatar(imagePath);
      return Right(updatedProfile);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update avatar: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> deleteAvatar() async {
    try {
      final updatedProfile = await remoteDataSource.deleteAvatar();
      return Right(updatedProfile);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete avatar: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailAvailable(String email) async {
    try {
      final isAvailable = await remoteDataSource.isEmailAvailable(email);
      return Right(isAvailable);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check email availability: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await remoteDataSource.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send email verification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPhoneVerification(String phoneNumber) async {
    try {
      await remoteDataSource.sendPhoneVerification(phoneNumber);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send phone verification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPhoneNumber(String phoneNumber, String verificationCode) async {
    try {
      await remoteDataSource.verifyPhoneCode(phoneNumber, verificationCode);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to verify phone number: ${e.toString()}'));
    }
  }
}
