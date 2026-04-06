import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:flutter_library/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_library/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_library/features/profile/data/models/user_profile_model.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockProfileRemoteDataSource extends Mock implements ProfileRemoteDataSource {}

void main() {
  group('ProfileRepositoryImpl Tests', () {
    late ProfileRepositoryImpl repository;
    late MockProfileRemoteDataSource mockRemoteDataSource;

    setUpAll(() {
      registerFallbackValue(UserProfileModel(
        id: 'test',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    });

    setUp(() {
      mockRemoteDataSource = MockProfileRemoteDataSource();
      repository = ProfileRepositoryImpl(remoteDataSource: mockRemoteDataSource);
    });

    final mockProfileModel = UserProfileModel(
      id: 'user_1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      avatarUrl: 'https://example.com/avatar.jpg',
      bio: 'Software developer',
      isEmailVerified: true,
      isPhoneVerified: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 6, 1),
    );

    final mockUserProfile = UserProfile(
      id: 'user_1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      avatarUrl: 'https://example.com/avatar.jpg',
      bio: 'Software developer',
      isEmailVerified: true,
      isPhoneVerified: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 6, 1),
    );

    group('getProfile', () {
      test('should return UserProfile when remote data source succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.getProfile())
            .thenAnswer((_) async => mockProfileModel);

        // Act
        final result = await repository.getProfile();

        // Assert
        expect(result, isA<Right<Failure, UserProfile>>());
        expect(result.fold((l) => null, (r) => r), mockProfileModel);
        verify(() => mockRemoteDataSource.getProfile()).called(1);
      });

      test('should return ServerFailure when remote data source throws exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.getProfile())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getProfile();

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        expect(result.fold((l) => l.message, (r) => null), contains('Failed to get profile'));
        verify(() => mockRemoteDataSource.getProfile()).called(1);
      });

      test('should handle different types of exceptions', () async {
        // Arrange
        when(() => mockRemoteDataSource.getProfile())
            .thenThrow(const FormatException('Invalid data format'));

        // Act
        final result = await repository.getProfile();

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Invalid data format'));
      });
    });

    group('updateProfile', () {
      test('should return updated UserProfile when update succeeds with UserProfile entity', () async {
        // Arrange
        final updatedProfileModel = mockProfileModel.copyWith(name: 'Jane Smith');
        when(() => mockRemoteDataSource.updateProfile(any()))
            .thenAnswer((_) async => updatedProfileModel);

        // Act
        final result = await repository.updateProfile(mockUserProfile);

        // Assert
        expect(result, isA<Right<Failure, UserProfile>>());
        expect(result.fold((l) => null, (r) => r), updatedProfileModel);
        verify(() => mockRemoteDataSource.updateProfile(any())).called(1);
      });

      test('should return updated UserProfile when update succeeds with UserProfileModel', () async {
        // Arrange
        final updatedProfileModel = mockProfileModel.copyWith(name: 'Jane Smith');
        when(() => mockRemoteDataSource.updateProfile(mockProfileModel))
            .thenAnswer((_) async => updatedProfileModel);

        // Act
        final result = await repository.updateProfile(mockProfileModel);

        // Assert
        expect(result, isA<Right<Failure, UserProfile>>());
        expect(result.fold((l) => null, (r) => r), updatedProfileModel);
        verify(() => mockRemoteDataSource.updateProfile(mockProfileModel)).called(1);
      });

      test('should return ServerFailure when update fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateProfile(any()))
            .thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateProfile(mockUserProfile);

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        expect(result.fold((l) => l.message, (r) => null), contains('Failed to update profile'));
        verify(() => mockRemoteDataSource.updateProfile(any())).called(1);
      });

      test('should handle validation errors during update', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateProfile(any()))
            .thenThrow(ArgumentError('Invalid email format'));

        // Act
        final result = await repository.updateProfile(mockUserProfile);

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Invalid email format'));
      });
    });

    group('updateAvatar', () {
      const imagePath = '/path/to/avatar.jpg';

      test('should return updated UserProfile when avatar update succeeds', () async {
        // Arrange
        final updatedProfileModel = mockProfileModel.copyWith(
          avatarUrl: 'https://example.com/new-avatar.jpg',
        );
        when(() => mockRemoteDataSource.updateAvatar(imagePath))
            .thenAnswer((_) async => updatedProfileModel);

        // Act
        final result = await repository.updateAvatar(imagePath);

        // Assert
        expect(result, isA<Right<Failure, UserProfile>>());
        expect(result.fold((l) => null, (r) => r), updatedProfileModel);
        expect(result.fold((l) => null, (r) => r.avatarUrl), 'https://example.com/new-avatar.jpg');
        verify(() => mockRemoteDataSource.updateAvatar(imagePath)).called(1);
      });

      test('should return ServerFailure when avatar update fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateAvatar(imagePath))
            .thenThrow(Exception('File upload failed'));

        // Act
        final result = await repository.updateAvatar(imagePath);

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        expect(result.fold((l) => l.message, (r) => null), contains('Failed to update avatar'));
        verify(() => mockRemoteDataSource.updateAvatar(imagePath)).called(1);
      });

      test('should handle file not found errors', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateAvatar(imagePath))
            .thenThrow(const FileSystemException('File not found'));

        // Act
        final result = await repository.updateAvatar(imagePath);

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('File not found'));
      });

      test('should handle invalid file format errors', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateAvatar(imagePath))
            .thenThrow(const FormatException('Invalid image format'));

        // Act
        final result = await repository.updateAvatar(imagePath);

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Invalid image format'));
      });
    });

    group('deleteAvatar', () {
      test('should return updated UserProfile when avatar deletion succeeds', () async {
        // Arrange
        final updatedProfileModel = UserProfileModel(
          id: mockProfileModel.id,
          name: mockProfileModel.name,
          email: mockProfileModel.email,
          phoneNumber: mockProfileModel.phoneNumber,
          avatarUrl: null, // Explicitly set to null
          bio: mockProfileModel.bio,
          isEmailVerified: mockProfileModel.isEmailVerified,
          isPhoneVerified: mockProfileModel.isPhoneVerified,
          createdAt: mockProfileModel.createdAt,
          updatedAt: mockProfileModel.updatedAt,
        );
        when(() => mockRemoteDataSource.deleteAvatar())
            .thenAnswer((_) async => updatedProfileModel);

        // Act
        final result = await repository.deleteAvatar();

        // Assert
        expect(result, isA<Right<Failure, UserProfile>>());
        expect(result.fold((l) => null, (r) => r), updatedProfileModel);
        expect(result.fold((l) => null, (r) => r.avatarUrl), isNull);
        verify(() => mockRemoteDataSource.deleteAvatar()).called(1);
      });

      test('should return ServerFailure when avatar deletion fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteAvatar())
            .thenThrow(Exception('Deletion failed'));

        // Act
        final result = await repository.deleteAvatar();

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        expect(result.fold((l) => l.message, (r) => null), contains('Failed to delete avatar'));
        verify(() => mockRemoteDataSource.deleteAvatar()).called(1);
      });

      test('should handle permission denied errors', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteAvatar())
            .thenThrow(Exception('Permission denied'));

        // Act
        final result = await repository.deleteAvatar();

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Permission denied'));
      });
    });

    group('Error Handling Edge Cases', () {
      test('should handle null pointer exceptions gracefully', () async {
        // Arrange
        when(() => mockRemoteDataSource.getProfile())
            .thenThrow(TypeError());

        // Act
        final result = await repository.getProfile();

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
      });

      test('should handle timeout exceptions', () async {
        // Arrange
        when(() => mockRemoteDataSource.getProfile())
            .thenThrow(Exception('Request timeout'));

        // Act
        final result = await repository.getProfile();

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Request timeout'));
      });

      test('should handle malformed data exceptions', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateProfile(any()))
            .thenThrow(const FormatException('Malformed JSON'));

        // Act
        final result = await repository.updateProfile(mockUserProfile);

        // Assert
        expect(result, isA<Left<Failure, UserProfile>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Malformed JSON'));
      });
    });

    group('isEmailAvailable', () {
      const testEmail = 'test@example.com';

      test('should return true when email is available', () async {
        // Arrange
        when(() => mockRemoteDataSource.isEmailAvailable(testEmail))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.isEmailAvailable(testEmail);

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => null, (r) => r), true);
        verify(() => mockRemoteDataSource.isEmailAvailable(testEmail)).called(1);
      });

      test('should return false when email is not available', () async {
        // Arrange
        when(() => mockRemoteDataSource.isEmailAvailable(testEmail))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.isEmailAvailable(testEmail);

        // Assert
        expect(result, isA<Right<Failure, bool>>());
        expect(result.fold((l) => null, (r) => r), false);
        verify(() => mockRemoteDataSource.isEmailAvailable(testEmail)).called(1);
      });

      test('should return ServerFailure when email check fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.isEmailAvailable(testEmail))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.isEmailAvailable(testEmail);

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        expect(result.fold((l) => l.message, (r) => null), contains('Failed to check email availability'));
        verify(() => mockRemoteDataSource.isEmailAvailable(testEmail)).called(1);
      });

      test('should handle validation errors for invalid email format', () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        when(() => mockRemoteDataSource.isEmailAvailable(invalidEmail))
            .thenThrow(const FormatException('Invalid email format'));

        // Act
        final result = await repository.isEmailAvailable(invalidEmail);

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Invalid email format'));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        when(() => mockRemoteDataSource.isEmailAvailable(testEmail))
            .thenThrow(Exception('Internal server error'));

        // Act
        final result = await repository.isEmailAvailable(testEmail);

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Internal server error'));
      });
    });

    group('sendEmailVerification', () {
      test('should return success when email verification is sent', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendEmailVerification())
            .thenAnswer((_) async {});

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result, isA<Right<Failure, void>>());
        expect(result.isRight(), true);
        verify(() => mockRemoteDataSource.sendEmailVerification()).called(1);
      });

      test('should return ServerFailure when email verification fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendEmailVerification())
            .thenThrow(Exception('Email service unavailable'));

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        expect(result.fold((l) => l.message, (r) => null), contains('Failed to send email verification'));
        verify(() => mockRemoteDataSource.sendEmailVerification()).called(1);
      });

      test('should handle timeout errors during email verification', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendEmailVerification())
            .thenThrow(Exception('Request timeout'));

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Request timeout'));
      });

      test('should handle rate limiting errors', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendEmailVerification())
            .thenThrow(Exception('Rate limit exceeded'));

        // Act
        final result = await repository.sendEmailVerification();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Rate limit exceeded'));
      });
    });

    group('sendPhoneVerification', () {
      const testPhoneNumber = '+1234567890';

      test('should return success when phone verification is sent', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendPhoneVerification(testPhoneNumber))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.sendPhoneVerification(testPhoneNumber);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        expect(result.isRight(), true);
        verify(() => mockRemoteDataSource.sendPhoneVerification(testPhoneNumber)).called(1);
      });

      test('should return ServerFailure when phone verification fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendPhoneVerification(testPhoneNumber))
            .thenThrow(Exception('SMS service unavailable'));

        // Act
        final result = await repository.sendPhoneVerification(testPhoneNumber);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        expect(result.fold((l) => l.message, (r) => null), contains('Failed to send phone verification'));
        verify(() => mockRemoteDataSource.sendPhoneVerification(testPhoneNumber)).called(1);
      });

      test('should handle invalid phone number format', () async {
        // Arrange
        const invalidPhone = 'invalid-phone';
        when(() => mockRemoteDataSource.sendPhoneVerification(invalidPhone))
            .thenThrow(const FormatException('Invalid phone number format'));

        // Act
        final result = await repository.sendPhoneVerification(invalidPhone);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Invalid phone number format'));
      });

      test('should handle unsupported country codes', () async {
        // Arrange
        const unsupportedPhone = '+999123456789';
        when(() => mockRemoteDataSource.sendPhoneVerification(unsupportedPhone))
            .thenThrow(Exception('Unsupported country code'));

        // Act
        final result = await repository.sendPhoneVerification(unsupportedPhone);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Unsupported country code'));
      });

      test('should handle carrier restrictions', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendPhoneVerification(testPhoneNumber))
            .thenThrow(Exception('Carrier blocked SMS'));

        // Act
        final result = await repository.sendPhoneVerification(testPhoneNumber);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Carrier blocked SMS'));
      });
    });

    group('verifyPhoneNumber', () {
      const testPhoneNumber = '+1234567890';
      const testVerificationCode = '123456';

      test('should return success when phone verification succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.verifyPhoneCode(testPhoneNumber, testVerificationCode))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.verifyPhoneNumber(testPhoneNumber, testVerificationCode);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        expect(result.isRight(), true);
        verify(() => mockRemoteDataSource.verifyPhoneCode(testPhoneNumber, testVerificationCode)).called(1);
      });

      test('should return ServerFailure when phone verification fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.verifyPhoneCode(testPhoneNumber, testVerificationCode))
            .thenThrow(Exception('Invalid verification code'));

        // Act
        final result = await repository.verifyPhoneNumber(testPhoneNumber, testVerificationCode);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
        expect(result.fold((l) => l.message, (r) => null), contains('Failed to verify phone number'));
        verify(() => mockRemoteDataSource.verifyPhoneCode(testPhoneNumber, testVerificationCode)).called(1);
      });

      test('should handle expired verification code', () async {
        // Arrange
        when(() => mockRemoteDataSource.verifyPhoneCode(testPhoneNumber, testVerificationCode))
            .thenThrow(Exception('Verification code expired'));

        // Act
        final result = await repository.verifyPhoneNumber(testPhoneNumber, testVerificationCode);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Verification code expired'));
      });

      test('should handle invalid verification code format', () async {
        // Arrange
        const invalidCode = 'abc123';
        when(() => mockRemoteDataSource.verifyPhoneCode(testPhoneNumber, invalidCode))
            .thenThrow(const FormatException('Code must be 6 digits'));

        // Act
        final result = await repository.verifyPhoneNumber(testPhoneNumber, invalidCode);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Code must be 6 digits'));
      });

      test('should handle too many verification attempts', () async {
        // Arrange
        when(() => mockRemoteDataSource.verifyPhoneCode(testPhoneNumber, testVerificationCode))
            .thenThrow(Exception('Too many failed attempts'));

        // Act
        final result = await repository.verifyPhoneNumber(testPhoneNumber, testVerificationCode);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Too many failed attempts'));
      });

      test('should handle verification for different phone numbers', () async {
        // Arrange
        const wrongPhoneNumber = '+9876543210';
        when(() => mockRemoteDataSource.verifyPhoneCode(wrongPhoneNumber, testVerificationCode))
            .thenThrow(Exception('Phone number mismatch'));

        // Act
        final result = await repository.verifyPhoneNumber(wrongPhoneNumber, testVerificationCode);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null) as ServerFailure;
        expect(failure.message, contains('Phone number mismatch'));
      });
    });

    group('Integration Scenarios', () {
      test('should handle rapid successive calls correctly', () async {
        // Arrange
        when(() => mockRemoteDataSource.getProfile())
            .thenAnswer((_) async => mockProfileModel);

        // Act
        final futures = List.generate(5, (_) => repository.getProfile());
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, isA<Right<Failure, UserProfile>>());
        }
        verify(() => mockRemoteDataSource.getProfile()).called(5);
      });

      test('should handle concurrent update operations', () async {
        // Arrange
        final profile1 = mockUserProfile.copyWith(name: 'User 1');
        final profile2 = mockUserProfile.copyWith(name: 'User 2');
        
        when(() => mockRemoteDataSource.updateProfile(any()))
            .thenAnswer((invocation) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return mockProfileModel.copyWith(name: 'Updated');
        });

        // Act
        final results = await Future.wait([
          repository.updateProfile(profile1),
          repository.updateProfile(profile2),
        ]);

        // Assert
        for (final result in results) {
          expect(result, isA<Right<Failure, UserProfile>>());
        }
        verify(() => mockRemoteDataSource.updateProfile(any())).called(2);
      });

      test('should handle full verification workflow', () async {
        // Arrange
        const email = 'test@example.com';
        const phone = '+1234567890';
        const verificationCode = '123456';

        when(() => mockRemoteDataSource.isEmailAvailable(email))
            .thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.sendEmailVerification())
            .thenAnswer((_) async {});
        when(() => mockRemoteDataSource.sendPhoneVerification(phone))
            .thenAnswer((_) async {});
        when(() => mockRemoteDataSource.verifyPhoneCode(phone, verificationCode))
            .thenAnswer((_) async {});

        // Act
        final emailAvailableResult = await repository.isEmailAvailable(email);
        final emailVerificationResult = await repository.sendEmailVerification();
        final phoneVerificationResult = await repository.sendPhoneVerification(phone);
        final phoneVerifyResult = await repository.verifyPhoneNumber(phone, verificationCode);

        // Assert
        expect(emailAvailableResult, isA<Right<Failure, bool>>());
        expect(emailVerificationResult, isA<Right<Failure, void>>());
        expect(phoneVerificationResult, isA<Right<Failure, void>>());
        expect(phoneVerifyResult, isA<Right<Failure, void>>());

        verify(() => mockRemoteDataSource.isEmailAvailable(email)).called(1);
        verify(() => mockRemoteDataSource.sendEmailVerification()).called(1);
        verify(() => mockRemoteDataSource.sendPhoneVerification(phone)).called(1);
        verify(() => mockRemoteDataSource.verifyPhoneCode(phone, verificationCode)).called(1);
      });

      test('should handle mixed success and failure scenarios', () async {
        // Arrange
        const testEmail = 'test@example.com';
        when(() => mockRemoteDataSource.isEmailAvailable(testEmail))
            .thenAnswer((_) async => false);
        when(() => mockRemoteDataSource.sendEmailVerification())
            .thenThrow(Exception('Service unavailable'));

        // Act
        final emailResult = await repository.isEmailAvailable(testEmail);
        final verificationResult = await repository.sendEmailVerification();

        // Assert
        expect(emailResult, isA<Right<Failure, bool>>());
        expect(emailResult.fold((l) => null, (r) => r), false);
        expect(verificationResult, isA<Left<Failure, void>>());
      });
    });
  });
}
