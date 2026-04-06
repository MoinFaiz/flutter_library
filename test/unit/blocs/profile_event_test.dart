import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

void main() {
  group('ProfileEvent', () {
    final testProfile = UserProfile(
      id: 'user-123',
      name: 'John Doe',
      email: 'test@example.com',
      phoneNumber: '+1234567890',
      address: const ProfileAddress(
        street: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'USA',
      ),
      isEmailVerified: true,
      isPhoneVerified: false,
      avatarUrl: 'https://example.com/avatar.jpg',
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    group('LoadProfile', () {
      test('should have empty props', () {
        // Arrange
        const event = LoadProfile();

        // Act & Assert
        expect(event.props, isEmpty);
        expect(event, isA<ProfileEvent>());
      });

      test('should be equal when instances are the same', () {
        // Arrange
        const event1 = LoadProfile();
        const event2 = LoadProfile();

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should support const constructor', () {
        // Arrange & Act
        const event1 = LoadProfile();
        const event2 = LoadProfile();

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });

      test('should have consistent toString representation', () {
        // Arrange
        const event = LoadProfile();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result, contains('LoadProfile'));
      });
    });

    group('UpdateProfile', () {
      test('should have correct props', () {
        // Arrange
        final event = UpdateProfile(testProfile);

        // Act & Assert
        expect(event.props, [testProfile]);
        expect(event.profile, equals(testProfile));
        expect(event, isA<ProfileEvent>());
      });

      test('should be equal when profiles are the same', () {
        // Arrange
        final event1 = UpdateProfile(testProfile);
        final event2 = UpdateProfile(testProfile);

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when profiles are different', () {
        // Arrange
        final profile1 = testProfile;
        final profile2 = testProfile.copyWith(name: 'Jane Doe');
        final event1 = UpdateProfile(profile1);
        final event2 = UpdateProfile(profile2);

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should support const constructor', () {
        // Arrange & Act
        final event1 = UpdateProfile(testProfile);
        final event2 = UpdateProfile(testProfile);

        // Assert
        expect(event1, equals(event2));
        expect(event1.profile, equals(event2.profile));
      });

      test('should handle profile with minimal data', () {
        // Arrange
        final minimalProfile = UserProfile(
          id: 'user-456',
          name: 'Min User',
          email: 'minimal@example.com',
          phoneNumber: null,
          address: null,
          isEmailVerified: false,
          isPhoneVerified: false,
          avatarUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final event = UpdateProfile(minimalProfile);

        // Act & Assert
        expect(event.profile, equals(minimalProfile));
        expect(event.props, [minimalProfile]);
      });
    });

    group('UpdateAvatar', () {
      test('should have correct props', () {
        // Arrange
        const imagePath = '/path/to/avatar.jpg';
        const event = UpdateAvatar(imagePath);

        // Act & Assert
        expect(event.props, [imagePath]);
        expect(event.imagePath, equals(imagePath));
        expect(event, isA<ProfileEvent>());
      });

      test('should be equal when imagePaths are the same', () {
        // Arrange
        const imagePath = '/path/to/avatar.jpg';
        const event1 = UpdateAvatar(imagePath);
        const event2 = UpdateAvatar(imagePath);

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when imagePaths are different', () {
        // Arrange
        const event1 = UpdateAvatar('/path/to/avatar1.jpg');
        const event2 = UpdateAvatar('/path/to/avatar2.jpg');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should support const constructor', () {
        // Arrange & Act
        const event1 = UpdateAvatar('/path/to/avatar.jpg');
        const event2 = UpdateAvatar('/path/to/avatar.jpg');

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });

      test('should handle empty imagePath', () {
        // Arrange
        const event = UpdateAvatar('');

        // Act & Assert
        expect(event.imagePath, isEmpty);
        expect(event.props, ['']);
      });

      test('should handle special characters in imagePath', () {
        // Arrange
        const specialPath = '/path/with special chars !@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`/avatar.jpg';
        const event = UpdateAvatar(specialPath);

        // Act & Assert
        expect(event.imagePath, equals(specialPath));
        expect(event.props, [specialPath]);
      });

      test('should handle Unicode characters in imagePath', () {
        // Arrange
        const unicodePath = '/路径/用户头像/アバター/🖼️.jpg';
        const event = UpdateAvatar(unicodePath);

        // Act & Assert
        expect(event.imagePath, equals(unicodePath));
        expect(event.props, [unicodePath]);
      });

      test('should handle very long imagePath', () {
        // Arrange
        final longPath = '/path/${'a' * 1000}/avatar.jpg';
        final event = UpdateAvatar(longPath);

        // Act & Assert
        expect(event.imagePath.length, equals(1017)); // '/path/${'a' * 1000}/avatar.jpg'
        expect(event.imagePath, equals(longPath));
        expect(event.props, [longPath]);
      });

      test('should handle different image file extensions', () {
        // Arrange
        const jpgEvent = UpdateAvatar('/path/avatar.jpg');
        const pngEvent = UpdateAvatar('/path/avatar.png');
        const gifEvent = UpdateAvatar('/path/avatar.gif');
        const webpEvent = UpdateAvatar('/path/avatar.webp');

        // Act & Assert
        expect(jpgEvent.imagePath, contains('.jpg'));
        expect(pngEvent.imagePath, contains('.png'));
        expect(gifEvent.imagePath, contains('.gif'));
        expect(webpEvent.imagePath, contains('.webp'));
        expect(jpgEvent, isNot(equals(pngEvent)));
      });
    });

    group('DeleteAvatar', () {
      test('should have empty props', () {
        // Arrange
        const event = DeleteAvatar();

        // Act & Assert
        expect(event.props, isEmpty);
        expect(event, isA<ProfileEvent>());
      });

      test('should be equal when instances are the same', () {
        // Arrange
        const event1 = DeleteAvatar();
        const event2 = DeleteAvatar();

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should support const constructor', () {
        // Arrange & Act
        const event1 = DeleteAvatar();
        const event2 = DeleteAvatar();

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });

      test('should not be equal to other event types', () {
        // Arrange
        const deleteEvent = DeleteAvatar();
        const loadEvent = LoadProfile();

        // Act & Assert
        expect(deleteEvent, isNot(equals(loadEvent)));
        expect(deleteEvent.runtimeType, isNot(equals(loadEvent.runtimeType)));
      });
    });

    group('SendEmailVerification', () {
      test('should have empty props', () {
        // Arrange
        const event = SendEmailVerification();

        // Act & Assert
        expect(event.props, isEmpty);
        expect(event, isA<ProfileEvent>());
      });

      test('should be equal when instances are the same', () {
        // Arrange
        const event1 = SendEmailVerification();
        const event2 = SendEmailVerification();

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should support const constructor', () {
        // Arrange & Act
        const event1 = SendEmailVerification();
        const event2 = SendEmailVerification();

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });
    });

    group('SendPhoneVerification', () {
      test('should have correct props', () {
        // Arrange
        const phoneNumber = '+1234567890';
        const event = SendPhoneVerification(phoneNumber);

        // Act & Assert
        expect(event.props, [phoneNumber]);
        expect(event.phoneNumber, equals(phoneNumber));
        expect(event, isA<ProfileEvent>());
      });

      test('should be equal when phoneNumbers are the same', () {
        // Arrange
        const phoneNumber = '+1234567890';
        const event1 = SendPhoneVerification(phoneNumber);
        const event2 = SendPhoneVerification(phoneNumber);

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when phoneNumbers are different', () {
        // Arrange
        const event1 = SendPhoneVerification('+1234567890');
        const event2 = SendPhoneVerification('+9876543210');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should support const constructor', () {
        // Arrange & Act
        const event1 = SendPhoneVerification('+1234567890');
        const event2 = SendPhoneVerification('+1234567890');

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });

      test('should handle empty phoneNumber', () {
        // Arrange
        const event = SendPhoneVerification('');

        // Act & Assert
        expect(event.phoneNumber, isEmpty);
        expect(event.props, ['']);
      });

      test('should handle international phone number formats', () {
        // Arrange
        const usNumber = SendPhoneVerification('+1 (555) 123-4567');
        const ukNumber = SendPhoneVerification('+44 20 7946 0958');
        const jpNumber = SendPhoneVerification('+81 3-1234-5678');
        const inNumber = SendPhoneVerification('+91 98765 43210');

        // Act & Assert
        expect(usNumber.phoneNumber, equals('+1 (555) 123-4567'));
        expect(ukNumber.phoneNumber, equals('+44 20 7946 0958'));
        expect(jpNumber.phoneNumber, equals('+81 3-1234-5678'));
        expect(inNumber.phoneNumber, equals('+91 98765 43210'));
      });

      test('should handle special characters in phoneNumber', () {
        // Arrange
        const specialPhone = '+1-555.123.4567 ext. 890';
        const event = SendPhoneVerification(specialPhone);

        // Act & Assert
        expect(event.phoneNumber, equals(specialPhone));
        expect(event.props, [specialPhone]);
      });
    });

    group('VerifyPhoneNumber', () {
      test('should have correct props', () {
        // Arrange
        const phoneNumber = '+1234567890';
        const verificationCode = '123456';
        const event = VerifyPhoneNumber(phoneNumber, verificationCode);

        // Act & Assert
        expect(event.props, [phoneNumber, verificationCode]);
        expect(event.phoneNumber, equals(phoneNumber));
        expect(event.verificationCode, equals(verificationCode));
        expect(event, isA<ProfileEvent>());
      });

      test('should be equal when phoneNumbers and codes are the same', () {
        // Arrange
        const phoneNumber = '+1234567890';
        const verificationCode = '123456';
        const event1 = VerifyPhoneNumber(phoneNumber, verificationCode);
        const event2 = VerifyPhoneNumber(phoneNumber, verificationCode);

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when phoneNumbers differ', () {
        // Arrange
        const verificationCode = '123456';
        const event1 = VerifyPhoneNumber('+1234567890', verificationCode);
        const event2 = VerifyPhoneNumber('+9876543210', verificationCode);

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should not be equal when verification codes differ', () {
        // Arrange
        const phoneNumber = '+1234567890';
        const event1 = VerifyPhoneNumber(phoneNumber, '123456');
        const event2 = VerifyPhoneNumber(phoneNumber, '654321');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should support const constructor', () {
        // Arrange & Act
        const event1 = VerifyPhoneNumber('+1234567890', '123456');
        const event2 = VerifyPhoneNumber('+1234567890', '123456');

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });

      test('should handle empty phoneNumber and verificationCode', () {
        // Arrange
        const event = VerifyPhoneNumber('', '');

        // Act & Assert
        expect(event.phoneNumber, isEmpty);
        expect(event.verificationCode, isEmpty);
        expect(event.props, ['', '']);
      });

      test('should handle different verification code formats', () {
        // Arrange
        const phoneNumber = '+1234567890';
        const numericCode = VerifyPhoneNumber(phoneNumber, '123456');
        const alphanumericCode = VerifyPhoneNumber(phoneNumber, 'ABC123');
        const shortCode = VerifyPhoneNumber(phoneNumber, '12');
        const longCode = VerifyPhoneNumber(phoneNumber, '123456789012');

        // Act & Assert
        expect(numericCode.verificationCode, equals('123456'));
        expect(alphanumericCode.verificationCode, equals('ABC123'));
        expect(shortCode.verificationCode, equals('12'));
        expect(longCode.verificationCode, equals('123456789012'));
        expect(numericCode, isNot(equals(alphanumericCode)));
      });

      test('should handle special characters in verification code', () {
        // Arrange
        const phoneNumber = '+1234567890';
        const specialCode = '12-34-56';
        const event = VerifyPhoneNumber(phoneNumber, specialCode);

        // Act & Assert
        expect(event.verificationCode, equals(specialCode));
        expect(event.props, [phoneNumber, specialCode]);
      });
    });

    group('ProfileEvent base class', () {
      test('should have empty props by default', () {
        // Create a test implementation to access base class behavior
        final testEvent = _TestProfileEvent();
        
        // Act & Assert
        expect(testEvent.props, isEmpty);
        expect(testEvent.props, isA<List<Object?>>());
      });

      test('should support toString method', () {
        // Arrange
        const event = LoadProfile();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });
    });

    group('Event type differentiation', () {
      test('should distinguish between different event types', () {
        // Arrange
        const loadEvent = LoadProfile();
        final updateEvent = UpdateProfile(testProfile);
        const updateAvatarEvent = UpdateAvatar('/path/avatar.jpg');
        const deleteAvatarEvent = DeleteAvatar();
        const sendEmailEvent = SendEmailVerification();
        const sendPhoneEvent = SendPhoneVerification('+1234567890');
        const verifyPhoneEvent = VerifyPhoneNumber('+1234567890', '123456');

        // Act & Assert - All events should be different types
        final eventTypes = [
          loadEvent.runtimeType,
          updateEvent.runtimeType,
          updateAvatarEvent.runtimeType,
          deleteAvatarEvent.runtimeType,
          sendEmailEvent.runtimeType,
          sendPhoneEvent.runtimeType,
          verifyPhoneEvent.runtimeType,
        ];
        
        for (int i = 0; i < eventTypes.length; i++) {
          for (int j = i + 1; j < eventTypes.length; j++) {
            expect(eventTypes[i], isNot(equals(eventTypes[j])));
          }
        }
        
        // But all should be ProfileEvent
        expect(loadEvent, isA<ProfileEvent>());
        expect(updateEvent, isA<ProfileEvent>());
        expect(updateAvatarEvent, isA<ProfileEvent>());
        expect(deleteAvatarEvent, isA<ProfileEvent>());
        expect(sendEmailEvent, isA<ProfileEvent>());
        expect(sendPhoneEvent, isA<ProfileEvent>());
        expect(verifyPhoneEvent, isA<ProfileEvent>());
      });

      test('should work correctly with Set operations', () {
        // Arrange
        const event1 = LoadProfile();
        const event2 = LoadProfile(); // Same as event1
        final event3 = UpdateProfile(testProfile);
        const event4 = DeleteAvatar();

        // Act - Create set by adding elements
        final eventSet = <ProfileEvent>{};
        eventSet.add(event1);
        eventSet.add(event2); // This should not be added as it's equal to event1
        eventSet.add(event3);
        eventSet.add(event4);

        // Assert - Set should contain only 3 unique events
        expect(eventSet.length, equals(3));
        expect(eventSet.contains(event1), isTrue);
        expect(eventSet.contains(event2), isTrue); // Same as event1
        expect(eventSet.contains(event3), isTrue);
        expect(eventSet.contains(event4), isTrue);
      });
    });

    group('Event polymorphism', () {
      test('should work correctly with polymorphic lists', () {
        // Arrange
        final List<ProfileEvent> events = [
          const LoadProfile(),
          UpdateProfile(testProfile),
          const UpdateAvatar('/path/avatar.jpg'),
          const DeleteAvatar(),
          const SendEmailVerification(),
          const SendPhoneVerification('+1234567890'),
          const VerifyPhoneNumber('+1234567890', '123456'),
        ];

        // Act & Assert
        expect(events.length, equals(7));
        expect(events[0], isA<LoadProfile>());
        expect(events[1], isA<UpdateProfile>());
        expect(events[2], isA<UpdateAvatar>());
        expect(events[3], isA<DeleteAvatar>());
        expect(events[4], isA<SendEmailVerification>());
        expect(events[5], isA<SendPhoneVerification>());
        expect(events[6], isA<VerifyPhoneNumber>());
      });

      test('should support pattern matching', () {
        // Arrange
        final List<ProfileEvent> events = [
          const LoadProfile(),
          UpdateProfile(testProfile),
          const UpdateAvatar('/path/avatar.jpg'),
          const DeleteAvatar(),
          const SendEmailVerification(),
          const SendPhoneVerification('+1234567890'),
          const VerifyPhoneNumber('+1234567890', '123456'),
        ];

        // Act & Assert - Type checking via 'is'
        for (final event in events) {
          if (event is LoadProfile) {
            expect(event, isA<LoadProfile>());
            expect(event.props, isEmpty);
          } else if (event is UpdateProfile) {
            expect(event, isA<UpdateProfile>());
            expect(event.profile, isA<UserProfile>());
          } else if (event is UpdateAvatar) {
            expect(event, isA<UpdateAvatar>());
            expect(event.imagePath, isA<String>());
          } else if (event is DeleteAvatar) {
            expect(event, isA<DeleteAvatar>());
            expect(event.props, isEmpty);
          } else if (event is SendEmailVerification) {
            expect(event, isA<SendEmailVerification>());
            expect(event.props, isEmpty);
          } else if (event is SendPhoneVerification) {
            expect(event, isA<SendPhoneVerification>());
            expect(event.phoneNumber, isA<String>());
          } else if (event is VerifyPhoneNumber) {
            expect(event, isA<VerifyPhoneNumber>());
            expect(event.phoneNumber, isA<String>());
            expect(event.verificationCode, isA<String>());
          } else {
            fail('Unexpected event type: ${event.runtimeType}');
          }
        }
      });
    });

    group('Edge cases and validation', () {
      test('should handle rapid event creation', () {
        // Arrange & Act - Create many events rapidly
        final events = List.generate(1000, (index) {
          switch (index % 7) {
            case 0:
              return const LoadProfile();
            case 1:
              return UpdateProfile(testProfile);
            case 2:
              return UpdateAvatar('/path/avatar_$index.jpg');
            case 3:
              return const DeleteAvatar();
            case 4:
              return const SendEmailVerification();
            case 5:
              return SendPhoneVerification('+123456789$index');
            default:
              return VerifyPhoneNumber('+123456789$index', '${index % 1000000}');
          }
        });

        // Assert
        expect(events.length, equals(1000));
        expect(events.whereType<LoadProfile>().length, greaterThan(140));
        expect(events.whereType<UpdateProfile>().length, greaterThan(140));
        expect(events.whereType<UpdateAvatar>().length, greaterThan(140));
        expect(events.whereType<DeleteAvatar>().length, greaterThan(140));
        expect(events.whereType<SendEmailVerification>().length, greaterThan(140));
        expect(events.whereType<SendPhoneVerification>().length, greaterThan(140));
        expect(events.whereType<VerifyPhoneNumber>().length, greaterThan(140));
      });

      test('should handle event comparison in maps', () {
        // Arrange
        const loadEvent = LoadProfile();
        final updateEvent = UpdateProfile(testProfile);
        const avatarEvent = UpdateAvatar('/path/avatar.jpg');

        final eventMap = <ProfileEvent, String>{
          loadEvent: 'load',
          updateEvent: 'update',
          avatarEvent: 'avatar',
        };

        // Act & Assert
        expect(eventMap[const LoadProfile()], equals('load'));
        expect(eventMap[UpdateProfile(testProfile)], equals('update'));
        expect(eventMap[const UpdateAvatar('/path/avatar.jpg')], equals('avatar'));
        expect(eventMap.length, equals(3));
      });

      test('should maintain immutability', () {
        // Arrange
        final updateEvent = UpdateProfile(testProfile);
        const avatarEvent = UpdateAvatar('/path/avatar.jpg');
        const phoneEvent = SendPhoneVerification('+1234567890');
        const verifyEvent = VerifyPhoneNumber('+1234567890', '123456');

        // Act - Try to access properties multiple times
        final profile1 = updateEvent.profile;
        final profile2 = updateEvent.profile;
        final imagePath1 = avatarEvent.imagePath;
        final imagePath2 = avatarEvent.imagePath;
        final phoneNumber1 = phoneEvent.phoneNumber;
        final phoneNumber2 = phoneEvent.phoneNumber;
        final verifyPhone1 = verifyEvent.phoneNumber;
        final verifyPhone2 = verifyEvent.phoneNumber;
        final verifyCode1 = verifyEvent.verificationCode;
        final verifyCode2 = verifyEvent.verificationCode;

        // Assert - Should be consistent
        expect(profile1, equals(profile2));
        expect(imagePath1, equals(imagePath2));
        expect(phoneNumber1, equals(phoneNumber2));
        expect(verifyPhone1, equals(verifyPhone2));
        expect(verifyCode1, equals(verifyCode2));
      });
    });
  });
}

/// Test implementation of ProfileEvent to access base class behavior
class _TestProfileEvent extends ProfileEvent {
  const _TestProfileEvent();
}
