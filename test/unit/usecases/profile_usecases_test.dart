import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/delete_avatar_usecase.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  group('Profile Use Cases Tests', () {
    late MockProfileRepository mockRepository;
    late GetProfileUseCase getProfileUseCase;
    late UpdateProfileUseCase updateProfileUseCase;
    late UpdateAvatarUseCase updateAvatarUseCase;
    late DeleteAvatarUseCase deleteAvatarUseCase;

    setUpAll(() {
      registerFallbackValue(UserProfile(
        id: 'fallback',
        name: 'Fallback User',
        email: 'fallback@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    });

    setUp(() {
      mockRepository = MockProfileRepository();
      getProfileUseCase = GetProfileUseCase(repository: mockRepository);
      updateProfileUseCase = UpdateProfileUseCase(repository: mockRepository);
      updateAvatarUseCase = UpdateAvatarUseCase(repository: mockRepository);
      deleteAvatarUseCase = DeleteAvatarUseCase(repository: mockRepository);
    });

    final mockProfile = UserProfile(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      avatarUrl: 'https://example.com/avatar.jpg',
      birthDate: DateTime(1990, 1, 1),
      bio: 'Book lover',
      address: const ProfileAddress(
        street: '123 Main St',
        city: 'Springfield',
        state: 'IL',
        zipCode: '12345',
        country: 'USA',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('GetProfileUseCase', () {
      test('should return UserProfile when repository call is successful', () async {
        // arrange
        when(() => mockRepository.getProfile())
            .thenAnswer((_) async => Right(mockProfile));

        // act
        final result = await getProfileUseCase();

        // assert
        expect(result, equals(Right(mockProfile)));
        verify(() => mockRepository.getProfile()).called(1);
      });

      test('should return Failure when repository call fails', () async {
        // arrange
        when(() => mockRepository.getProfile())
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await getProfileUseCase();

        // assert
        expect(result, equals(const Left(ServerFailure())));
        verify(() => mockRepository.getProfile()).called(1);
      });

      test('should return NetworkFailure when network error occurs', () async {
        // arrange
        when(() => mockRepository.getProfile())
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await getProfileUseCase();

        // assert
        expect(result, equals(const Left(NetworkFailure())));
        verify(() => mockRepository.getProfile()).called(1);
      });

      test('should return CacheFailure when cache error occurs', () async {
        // arrange
        when(() => mockRepository.getProfile())
            .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

        // act
        final result = await getProfileUseCase();

        // assert
        expect(result, isA<Left<Failure, UserProfile>>());
        final failure = (result as Left).value;
        expect(failure, isA<CacheFailure>());
        verify(() => mockRepository.getProfile()).called(1);
      });
    });

    group('UpdateProfileUseCase', () {
      test('should return updated UserProfile when validation passes and repository call is successful', () async {
        // arrange
        final updatedProfile = mockProfile.copyWith(name: 'Jane Doe');
        when(() => mockRepository.updateProfile(any()))
            .thenAnswer((_) async => Right(updatedProfile));

        // act
        final result = await updateProfileUseCase(updatedProfile);

        // assert
        expect(result, equals(Right(updatedProfile)));
        verify(() => mockRepository.updateProfile(updatedProfile)).called(1);
      });

      test('should return ValidationFailure when name is empty', () async {
        // arrange
        final invalidProfile = mockProfile.copyWith(name: '');

        // act
        final result = await updateProfileUseCase(invalidProfile);

        // assert
        expect(result, equals(const Left(ValidationFailure('Name cannot be empty'))));
        verifyNever(() => mockRepository.updateProfile(any()));
      });

      test('should return ValidationFailure when name is only whitespace', () async {
        // arrange
        final invalidProfile = mockProfile.copyWith(name: '   ');

        // act
        final result = await updateProfileUseCase(invalidProfile);

        // assert
        expect(result, equals(const Left(ValidationFailure('Name cannot be empty'))));
        verifyNever(() => mockRepository.updateProfile(any()));
      });

      test('should return ValidationFailure when email is empty', () async {
        // arrange
        final invalidProfile = mockProfile.copyWith(email: '');

        // act
        final result = await updateProfileUseCase(invalidProfile);

        // assert
        expect(result, equals(const Left(ValidationFailure('Email cannot be empty'))));
        verifyNever(() => mockRepository.updateProfile(any()));
      });

      test('should return ValidationFailure when email format is invalid', () async {
        // arrange
        final invalidProfile = mockProfile.copyWith(email: 'invalid-email');

        // act
        final result = await updateProfileUseCase(invalidProfile);

        // assert
        expect(result, equals(const Left(ValidationFailure('Please enter a valid email address'))));
        verifyNever(() => mockRepository.updateProfile(any()));
      });

      test('should return ValidationFailure for invalid email formats', () async {
        final invalidEmails = [
          'plainaddress',
          '@missingusername.com',
          'username@.com',
          'username@com',
          'username@com.', // Invalid: ends with dot
        ];

        for (final invalidEmail in invalidEmails) {
          final invalidProfile = mockProfile.copyWith(email: invalidEmail);
          final result = await updateProfileUseCase(invalidProfile);
          expect(result, equals(const Left(ValidationFailure('Please enter a valid email address'))),
              reason: 'Email: $invalidEmail should be invalid');
        }
      });

      test('should accept valid email formats', () async {
        // arrange
        final validEmails = [
          'user@example.com',
          'user.name@example.com',
          'user+tag@example.co.uk',
          'user123@example-site.com',
        ];

        for (final validEmail in validEmails) {
          final validProfile = mockProfile.copyWith(email: validEmail);
          when(() => mockRepository.updateProfile(any()))
              .thenAnswer((_) async => Right(validProfile));

          // act
          final result = await updateProfileUseCase(validProfile);

          // assert
          expect(result, isA<Right<Failure, UserProfile>>(),
              reason: 'Email: $validEmail should be valid');
        }
      });

      test('should return ValidationFailure when phone number format is invalid', () async {
        // arrange
        final invalidProfile = mockProfile.copyWith(phoneNumber: 'invalid-phone');

        // act
        final result = await updateProfileUseCase(invalidProfile);

        // assert
        expect(result, equals(const Left(ValidationFailure('Please enter a valid phone number'))));
        verifyNever(() => mockRepository.updateProfile(any()));
      });

      test('should accept valid phone number formats', () async {
        // arrange
        final validPhoneNumbers = [
          '+1234567890',
          '+123456789012345',
          '1234567890',
        ];

        for (final validPhone in validPhoneNumbers) {
          final validProfile = mockProfile.copyWith(phoneNumber: validPhone);
          when(() => mockRepository.updateProfile(any()))
              .thenAnswer((_) async => Right(validProfile));

          // act
          final result = await updateProfileUseCase(validProfile);

          // assert
          expect(result, isA<Right<Failure, UserProfile>>(),
              reason: 'Phone: $validPhone should be valid');
        }
      });

      test('should accept profile with null phone number', () async {
        // arrange
        final validProfile = mockProfile.copyWith(phoneNumber: null);
        when(() => mockRepository.updateProfile(any()))
            .thenAnswer((_) async => Right(validProfile));

        // act
        final result = await updateProfileUseCase(validProfile);

        // assert
        expect(result, equals(Right(validProfile)));
        verify(() => mockRepository.updateProfile(validProfile)).called(1);
      });

      test('should accept profile with empty phone number', () async {
        // arrange
        final validProfile = mockProfile.copyWith(phoneNumber: '');
        when(() => mockRepository.updateProfile(any()))
            .thenAnswer((_) async => Right(validProfile));

        // act
        final result = await updateProfileUseCase(validProfile);

        // assert
        expect(result, equals(Right(validProfile)));
        verify(() => mockRepository.updateProfile(validProfile)).called(1);
      });

      test('should return ServerFailure when repository update fails', () async {
        // arrange
        when(() => mockRepository.updateProfile(any()))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await updateProfileUseCase(mockProfile);

        // assert
        expect(result, equals(const Left(ServerFailure())));
        verify(() => mockRepository.updateProfile(mockProfile)).called(1);
      });

      test('should return NetworkFailure when network error occurs', () async {
        // arrange
        when(() => mockRepository.updateProfile(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await updateProfileUseCase(mockProfile);

        // assert
        expect(result, equals(const Left(NetworkFailure())));
        verify(() => mockRepository.updateProfile(mockProfile)).called(1);
      });
    });

    group('UpdateAvatarUseCase', () {
      test('should return updated UserProfile when avatar update is successful', () async {
        // arrange
        const avatarPath = '/path/to/avatar.jpg';
        final updatedProfile = mockProfile.copyWith(avatarUrl: 'https://example.com/new-avatar.jpg');
        when(() => mockRepository.updateAvatar(avatarPath))
            .thenAnswer((_) async => Right(updatedProfile));

        // act
        final result = await updateAvatarUseCase(avatarPath);

        // assert
        expect(result, equals(Right(updatedProfile)));
        verify(() => mockRepository.updateAvatar(avatarPath)).called(1);
      });

      test('should return ValidationFailure when avatar path is empty', () async {
        // act
        final result = await updateAvatarUseCase('');

        // assert
        expect(result, equals(const Left(ValidationFailure('Please select an image'))));
        verifyNever(() => mockRepository.updateAvatar(any()));
      });

      test('should return ServerFailure when repository update fails', () async {
        // arrange
        const avatarPath = '/path/to/avatar.jpg';
        when(() => mockRepository.updateAvatar(avatarPath))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await updateAvatarUseCase(avatarPath);

        // assert
        expect(result, equals(const Left(ServerFailure())));
        verify(() => mockRepository.updateAvatar(avatarPath)).called(1);
      });

      test('should return ValidationFailure for unsupported file types', () async {
        // arrange
        final invalidPaths = [
          '/path/to/file.txt',
          '/path/to/file.pdf',
          '/path/to/file.doc',
        ];

        for (final invalidPath in invalidPaths) {
          // act
          final result = await updateAvatarUseCase(invalidPath);

          // assert
          expect(result, equals(const Left(ValidationFailure('Unsupported file type. Please use JPG, PNG, or GIF'))));
          verifyNever(() => mockRepository.updateAvatar(any()));
        }
      });

      test('should accept supported image file types', () async {
        // arrange
        final validPaths = [
          '/path/to/file.jpg',
          '/path/to/file.jpeg',
          '/path/to/file.png',
          '/path/to/file.gif',
          '/path/to/file.JPG',
          '/path/to/file.PNG',
        ];

        for (final validPath in validPaths) {
          final updatedProfile = mockProfile.copyWith(avatarUrl: 'https://example.com/new-avatar.jpg');
          when(() => mockRepository.updateAvatar(validPath))
              .thenAnswer((_) async => Right(updatedProfile));

          // act
          final result = await updateAvatarUseCase(validPath);

          // assert
          expect(result, isA<Right<Failure, UserProfile>>(),
              reason: 'Path: $validPath should be valid');
        }
      });
    });

    group('DeleteAvatarUseCase', () {
      test('should return updated UserProfile when avatar deletion is successful', () async {
        // arrange
        final updatedProfile = mockProfile.copyWith(avatarUrl: null);
        when(() => mockRepository.deleteAvatar())
            .thenAnswer((_) async => Right(updatedProfile));

        // act
        final result = await deleteAvatarUseCase();

        // assert
        expect(result, equals(Right(updatedProfile)));
        verify(() => mockRepository.deleteAvatar()).called(1);
      });

      test('should return ServerFailure when repository deletion fails', () async {
        // arrange
        when(() => mockRepository.deleteAvatar())
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await deleteAvatarUseCase();

        // assert
        expect(result, equals(const Left(ServerFailure())));
        verify(() => mockRepository.deleteAvatar()).called(1);
      });

      test('should return NetworkFailure when network error occurs', () async {
        // arrange
        when(() => mockRepository.deleteAvatar())
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await deleteAvatarUseCase();

        // assert
        expect(result, equals(const Left(NetworkFailure())));
        verify(() => mockRepository.deleteAvatar()).called(1);
      });

      test('should return ValidationFailure when user has no avatar to delete', () async {
        // arrange
        when(() => mockRepository.deleteAvatar())
            .thenAnswer((_) async => const Left(ValidationFailure('No avatar found to delete')));

        // act
        final result = await deleteAvatarUseCase();

        // assert
        expect(result, equals(const Left(ValidationFailure('No avatar found to delete'))));
        verify(() => mockRepository.deleteAvatar()).called(1);
      });
    });

    group('Integration scenarios', () {
      test('should handle concurrent profile operations correctly', () async {
        // arrange
        when(() => mockRepository.getProfile())
            .thenAnswer((_) async => Right(mockProfile));
        when(() => mockRepository.updateProfile(any()))
            .thenAnswer((_) async => Right(mockProfile));

        // act
        final futures = await Future.wait([
          getProfileUseCase(),
          updateProfileUseCase(mockProfile),
        ]);

        // assert
        expect(futures.length, equals(2));
        expect(futures[0], isA<Right<Failure, UserProfile>>());
        expect(futures[1], isA<Right<Failure, UserProfile>>());
      });

      test('should handle profile update after avatar update workflow', () async {
        // arrange
        const avatarPath = '/path/to/avatar.jpg';
        final profileWithAvatar = mockProfile.copyWith(avatarUrl: 'https://example.com/new-avatar.jpg');
        final finalProfile = profileWithAvatar.copyWith(name: 'Updated Name');

        when(() => mockRepository.updateAvatar(avatarPath))
            .thenAnswer((_) async => Right(profileWithAvatar));
        when(() => mockRepository.updateProfile(finalProfile))
            .thenAnswer((_) async => Right(finalProfile));

        // act
        final avatarResult = await updateAvatarUseCase(avatarPath);
        final profileResult = await updateProfileUseCase(finalProfile);

        // assert
        expect(avatarResult, equals(Right(profileWithAvatar)));
        expect(profileResult, equals(Right(finalProfile)));
        verify(() => mockRepository.updateAvatar(avatarPath)).called(1);
        verify(() => mockRepository.updateProfile(finalProfile)).called(1);
      });
    });
  });
}
