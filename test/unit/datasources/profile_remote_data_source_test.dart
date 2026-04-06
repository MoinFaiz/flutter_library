import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_library/features/profile/data/models/user_profile_model.dart';

void main() {
  group('ProfileRemoteDataSource Tests', () {
    late ProfileRemoteDataSourceImpl dataSource;
    late Dio dio;

    setUp(() {
      dio = Dio();
      dataSource = ProfileRemoteDataSourceImpl(dio: dio);
    });

    group('getProfile', () {
      test('should return mock user profile', () async {
        // Act
        final result = await dataSource.getProfile();

        // Assert
        expect(result, isA<UserProfileModel>());
        expect(result.id, equals('user_001'));
        expect(result.name, equals('John Doe'));
        expect(result.email, equals('john.doe@example.com'));
        expect(result.phoneNumber, equals('+1 (555) 123-4567'));
        expect(result.isEmailVerified, isTrue);
        expect(result.isPhoneVerified, isFalse);
      });

      test('should simulate network delay', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.getProfile();

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(700)); // Should be around 800ms
      });
    });

    group('updateProfile', () {
      test('should update profile and return updated model', () async {
        // Arrange
        final originalProfile = await dataSource.getProfile();
        final updatedProfile = originalProfile.copyWith(
          name: 'Jane Doe',
          email: 'jane.doe@example.com',
        );

        // Act
        final result = await dataSource.updateProfile(updatedProfile);

        // Assert
        expect(result.name, equals('Jane Doe'));
        expect(result.email, equals('jane.doe@example.com'));
        expect(result.id, equals(originalProfile.id)); // ID should remain same
        expect(result.updatedAt.isAfter(originalProfile.updatedAt), isTrue);
      });

      test('should simulate network delay for update', () async {
        // Arrange
        final profile = await dataSource.getProfile();
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.updateProfile(profile);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(900)); // Should be around 1000ms
      });

      test('should persist changes across subsequent calls', () async {
        // Arrange
        final originalProfile = await dataSource.getProfile();
        final updatedProfile = originalProfile.copyWith(
          name: 'Updated Name',
          bio: 'Updated bio description',
        );

        // Act
        await dataSource.updateProfile(updatedProfile);
        final retrievedProfile = await dataSource.getProfile();

        // Assert
        expect(retrievedProfile.name, equals('Updated Name'));
        expect(retrievedProfile.bio, equals('Updated bio description'));
      });
    });

    group('updateAvatar', () {
      test('should update avatar URL and return updated profile', () async {
        // Arrange
        const imagePath = '/path/to/avatar.jpg';

        // Act
        final result = await dataSource.updateAvatar(imagePath);

        // Assert
        expect(result.avatarUrl, equals('https://example.com/avatars/user_001.jpg'));
        expect(result.updatedAt, isNotNull);
      });

      test('should simulate longer network delay for image upload', () async {
        // Arrange
        const imagePath = '/path/to/avatar.jpg';
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.updateAvatar(imagePath);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(1900)); // Should be around 2000ms
      });

      test('should persist avatar URL across subsequent calls', () async {
        // Arrange
        const imagePath = '/path/to/avatar.jpg';

        // Act
        await dataSource.updateAvatar(imagePath);
        final profile = await dataSource.getProfile();

        // Assert
        expect(profile.avatarUrl, equals('https://example.com/avatars/user_001.jpg'));
      });
    });

    group('deleteAvatar', () {
      test('should remove avatar URL and return updated profile', () async {
        // Arrange - first ensure there's an avatar to delete
        await dataSource.updateAvatar('/path/to/avatar.jpg');
        var profileWithAvatar = await dataSource.getProfile();
        expect(profileWithAvatar.avatarUrl, isNotNull); // Verify avatar exists

        // Act
        final result = await dataSource.deleteAvatar();

        // Assert
        expect(result.avatarUrl, isNull);
        expect(result.updatedAt, isNotNull);
      });

      test('should simulate network delay for deletion', () async {
        // Arrange
        await dataSource.updateAvatar('/path/to/avatar.jpg');
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.deleteAvatar();

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(400)); // Should be around 500ms
      });

      test('should persist avatar removal across subsequent calls', () async {
        // Arrange
        await dataSource.updateAvatar('/path/to/avatar.jpg');

        // Act
        await dataSource.deleteAvatar();
        final profile = await dataSource.getProfile();

        // Assert
        expect(profile.avatarUrl, isNull);
      });
    });

    group('isEmailAvailable', () {
      test('should return false for taken emails', () async {
        // Act & Assert
        expect(await dataSource.isEmailAvailable('admin@example.com'), isFalse);
        expect(await dataSource.isEmailAvailable('test@example.com'), isFalse);
        expect(await dataSource.isEmailAvailable('user@example.com'), isFalse);
      });

      test('should return false for current user email', () async {
        // Arrange
        final profile = await dataSource.getProfile();

        // Act
        final result = await dataSource.isEmailAvailable(profile.email);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for current user email case insensitive', () async {
        // Arrange
        final profile = await dataSource.getProfile();

        // Act
        final result = await dataSource.isEmailAvailable(profile.email.toUpperCase());

        // Assert
        expect(result, isFalse);
      });

      test('should return true for available emails', () async {
        // Act & Assert
        expect(await dataSource.isEmailAvailable('available@example.com'), isTrue);
        expect(await dataSource.isEmailAvailable('new.user@example.com'), isTrue);
        expect(await dataSource.isEmailAvailable('another@domain.com'), isTrue);
      });

      test('should simulate network delay for email check', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.isEmailAvailable('test@check.com');

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(500)); // Should be around 600ms
      });
    });

    group('sendEmailVerification', () {
      test('should complete without error', () async {
        // Act & Assert
        await expectLater(dataSource.sendEmailVerification(), completes);
      });

      test('should simulate network delay', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.sendEmailVerification();

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(900)); // Should be around 1000ms
      });
    });

    group('sendPhoneVerification', () {
      test('should complete without error for valid phone number', () async {
        // Act & Assert
        await expectLater(
          dataSource.sendPhoneVerification('+1 (555) 987-6543'),
          completes,
        );
      });

      test('should simulate network delay', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.sendPhoneVerification('+1 (555) 987-6543');

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(700)); // Should be around 800ms
      });
    });

    group('verifyPhoneCode', () {
      test('should complete successfully with correct code', () async {
        // Act & Assert
        await expectLater(
          dataSource.verifyPhoneCode('+1 (555) 987-6543', '123456'),
          completes,
        );
      });

      test('should update profile with verified phone number', () async {
        // Arrange
        const newPhoneNumber = '+1 (555) 987-6543';

        // Act
        await dataSource.verifyPhoneCode(newPhoneNumber, '123456');
        final profile = await dataSource.getProfile();

        // Assert
        expect(profile.phoneNumber, equals(newPhoneNumber));
        expect(profile.isPhoneVerified, isTrue);
      });

      test('should throw exception with incorrect code', () async {
        // Act & Assert
        await expectLater(
          dataSource.verifyPhoneCode('+1 (555) 987-6543', 'wrong'),
          throwsA(isA<Exception>()),
        );
      });

      test('should simulate network delay', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.verifyPhoneCode('+1 (555) 987-6543', '123456');

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(500)); // Should be around 600ms
      });
    });

    group('isPhoneAvailable', () {
      test('should return false for taken phone numbers', () async {
        // Act & Assert
        expect(await dataSource.isPhoneAvailable('+1 (555) 000-0000'), isFalse);
        expect(await dataSource.isPhoneAvailable('+1 (555) 111-1111'), isFalse);
        expect(await dataSource.isPhoneAvailable('+1 (555) 999-9999'), isFalse);
      });

      test('should return false for current user phone number', () async {
        // Arrange
        final profile = await dataSource.getProfile();

        // Act
        final result = await dataSource.isPhoneAvailable(profile.phoneNumber ?? '');

        // Assert
        expect(result, isFalse);
      });

      test('should return true for available phone numbers', () async {
        // Act & Assert - Use phone numbers that are not in the taken list and not the current user's
        expect(await dataSource.isPhoneAvailable('+1 (555) 123-4568'), isTrue);
        expect(await dataSource.isPhoneAvailable('+1 (444) 555-6666'), isTrue);
        expect(await dataSource.isPhoneAvailable('+1 (777) 888-9999'), isTrue);
      });

      test('should simulate network delay for phone check', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.isPhoneAvailable('+1 (555) 123-4568');

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThan(500)); // Should be around 600ms
      });
    });

    group('Integration Tests', () {
      test('should handle complete profile management workflow', () async {
        // 1. Get initial profile and ensure clean state for avatar
        // Ensure we start with no avatar for this test
        await dataSource.deleteAvatar();
        var profile = await dataSource.getProfile();
        expect(profile.avatarUrl, isNull);
        expect(profile.isEmailVerified, isTrue); // From mock data

        // 2. Update profile information
        final updatedProfile = profile.copyWith(
          name: 'Integration Test User',
          bio: 'Updated during integration test',
        );
        await dataSource.updateProfile(updatedProfile);

        // 3. Add avatar
        await dataSource.updateAvatar('/test/avatar.jpg');

        // 4. Verify phone number
        await dataSource.verifyPhoneCode('+1 (555) 999-8888', '123456');

        // 5. Get final profile and verify all changes
        final finalProfile = await dataSource.getProfile();
        expect(finalProfile.name, equals('Integration Test User'));
        expect(finalProfile.bio, equals('Updated during integration test'));
        expect(finalProfile.avatarUrl, equals('https://example.com/avatars/user_001.jpg'));
        expect(finalProfile.phoneNumber, equals('+1 (555) 999-8888'));
        expect(finalProfile.isPhoneVerified, isTrue);
      });

      test('should handle avatar lifecycle', () async {
        // 1. Start with no avatar (ensure clean state)
        await dataSource.deleteAvatar();
        var profile = await dataSource.getProfile();
        expect(profile.avatarUrl, isNull);

        // 2. Add avatar
        await dataSource.updateAvatar('/test/avatar1.jpg');
        profile = await dataSource.getProfile();
        expect(profile.avatarUrl, isNotNull);

        // 3. Update avatar
        await dataSource.updateAvatar('/test/avatar2.jpg');
        profile = await dataSource.getProfile();
        expect(profile.avatarUrl, equals('https://example.com/avatars/user_001.jpg'));

        // 4. Delete avatar
        await dataSource.deleteAvatar();
        profile = await dataSource.getProfile();
        expect(profile.avatarUrl, isNull);
      });

      test('should validate availability checks work with current state', () async {
        // 1. Get current profile
        final profile = await dataSource.getProfile();

        // 2. Update email and phone
        final newEmail = 'newtest@example.com';
        const newPhone = '+1 (555) 777-8888';
        
        await dataSource.updateProfile(profile.copyWith(email: newEmail));
        await dataSource.verifyPhoneCode(newPhone, '123456');

        // 3. Check availability reflects current state
        expect(await dataSource.isEmailAvailable(newEmail), isFalse);
        expect(await dataSource.isPhoneAvailable(newPhone), isFalse);
        
        // 4. Check other emails/phones are still available
        expect(await dataSource.isEmailAvailable('another@example.com'), isTrue);
        expect(await dataSource.isPhoneAvailable('+1 (555) 555-5555'), isTrue);
      });
    });
  });
}
