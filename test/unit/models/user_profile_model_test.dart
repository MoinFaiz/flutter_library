import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/profile/data/models/user_profile_model.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfileModel Tests', () {
    final testDateTime = DateTime(2023, 6, 15, 10, 30);
    final testBirthDate = DateTime(1990, 5, 12);
    
    final testAddressJson = {
      'street': '123 Main St',
      'city': 'Anytown',
      'state': 'CA',
      'zipCode': '12345',
      'country': 'USA',
      'isDefault': true,
    };

    final testUserProfileJson = {
      'id': 'user_123',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phoneNumber': '+1234567890',
      'avatarUrl': 'https://example.com/avatar.jpg',
      'address': testAddressJson,
      'birthDate': '1990-05-12T00:00:00.000Z',
      'bio': 'Software developer and book lover',
      'isEmailVerified': true,
      'isPhoneVerified': false,
      'createdAt': '2023-06-15T10:30:00.000Z',
      'updatedAt': '2023-06-15T10:30:00.000Z',
    };

    final testUserProfileAddress = ProfileAddressModel(
      street: '123 Main St',
      city: 'Anytown',
      state: 'CA',
      zipCode: '12345',
      country: 'USA',
      isDefault: true,
    );

    final testUserProfileModel = UserProfileModel(
      id: 'user_123',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      avatarUrl: 'https://example.com/avatar.jpg',
      address: testUserProfileAddress,
      birthDate: testBirthDate,
      bio: 'Software developer and book lover',
      isEmailVerified: true,
      isPhoneVerified: false,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

    group('Constructor', () {
      test('should create UserProfileModel with all properties', () {
        // Assert
        expect(testUserProfileModel.id, equals('user_123'));
        expect(testUserProfileModel.name, equals('John Doe'));
        expect(testUserProfileModel.email, equals('john.doe@example.com'));
        expect(testUserProfileModel.phoneNumber, equals('+1234567890'));
        expect(testUserProfileModel.avatarUrl, equals('https://example.com/avatar.jpg'));
        expect(testUserProfileModel.address, equals(testUserProfileAddress));
        expect(testUserProfileModel.birthDate, equals(testBirthDate));
        expect(testUserProfileModel.bio, equals('Software developer and book lover'));
        expect(testUserProfileModel.isEmailVerified, isTrue);
        expect(testUserProfileModel.isPhoneVerified, isFalse);
        expect(testUserProfileModel.createdAt, equals(testDateTime));
        expect(testUserProfileModel.updatedAt, equals(testDateTime));
      });

      test('should create UserProfileModel with minimal required properties', () {
        // Arrange
        final minimalProfile = UserProfileModel(
          id: 'user_minimal',
          name: 'Jane Smith',
          email: 'jane@example.com',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Assert
        expect(minimalProfile.id, equals('user_minimal'));
        expect(minimalProfile.name, equals('Jane Smith'));
        expect(minimalProfile.email, equals('jane@example.com'));
        expect(minimalProfile.phoneNumber, isNull);
        expect(minimalProfile.avatarUrl, isNull);
        expect(minimalProfile.address, isNull);
        expect(minimalProfile.birthDate, isNull);
        expect(minimalProfile.bio, isNull);
        expect(minimalProfile.isEmailVerified, isFalse);
        expect(minimalProfile.isPhoneVerified, isFalse);
        expect(minimalProfile.createdAt, equals(testDateTime));
        expect(minimalProfile.updatedAt, equals(testDateTime));
      });
    });

    group('JSON Serialization', () {
      test('should create UserProfileModel from complete JSON', () {
        // Act
        final userProfile = UserProfileModel.fromJson(testUserProfileJson);

        // Assert
        expect(userProfile.id, equals('user_123'));
        expect(userProfile.name, equals('John Doe'));
        expect(userProfile.email, equals('john.doe@example.com'));
        expect(userProfile.phoneNumber, equals('+1234567890'));
        expect(userProfile.avatarUrl, equals('https://example.com/avatar.jpg'));
        expect(userProfile.address, isA<ProfileAddressModel>());
        expect(userProfile.address!.street, equals('123 Main St'));
        expect(userProfile.birthDate, equals(DateTime.parse('1990-05-12T00:00:00.000Z')));
        expect(userProfile.bio, equals('Software developer and book lover'));
        expect(userProfile.isEmailVerified, isTrue);
        expect(userProfile.isPhoneVerified, isFalse);
        expect(userProfile.createdAt, equals(DateTime.parse('2023-06-15T10:30:00.000Z')));
        expect(userProfile.updatedAt, equals(DateTime.parse('2023-06-15T10:30:00.000Z')));
      });

      test('should create UserProfileModel from minimal JSON', () {
        // Arrange
        final minimalJson = {
          'id': 'user_minimal',
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'createdAt': '2023-06-15T10:30:00.000Z',
          'updatedAt': '2023-06-15T10:30:00.000Z',
        };

        // Act
        final userProfile = UserProfileModel.fromJson(minimalJson);

        // Assert
        expect(userProfile.id, equals('user_minimal'));
        expect(userProfile.name, equals('Jane Smith'));
        expect(userProfile.email, equals('jane@example.com'));
        expect(userProfile.phoneNumber, isNull);
        expect(userProfile.avatarUrl, isNull);
        expect(userProfile.address, isNull);
        expect(userProfile.birthDate, isNull);
        expect(userProfile.bio, isNull);
        expect(userProfile.isEmailVerified, isFalse);
        expect(userProfile.isPhoneVerified, isFalse);
      });

      test('should handle null optional fields in JSON', () {
        // Arrange
        final jsonWithNulls = {
          'id': 'user_test',
          'name': 'Test User',
          'email': 'test@example.com',
          'phoneNumber': null,
          'avatarUrl': null,
          'address': null,
          'birthDate': null,
          'bio': null,
          'isEmailVerified': null,
          'isPhoneVerified': null,
          'createdAt': '2023-06-15T10:30:00.000Z',
          'updatedAt': '2023-06-15T10:30:00.000Z',
        };

        // Act
        final userProfile = UserProfileModel.fromJson(jsonWithNulls);

        // Assert
        expect(userProfile.phoneNumber, isNull);
        expect(userProfile.avatarUrl, isNull);
        expect(userProfile.address, isNull);
        expect(userProfile.birthDate, isNull);
        expect(userProfile.bio, isNull);
        expect(userProfile.isEmailVerified, isFalse); // defaults to false
        expect(userProfile.isPhoneVerified, isFalse); // defaults to false
      });

      test('should convert UserProfileModel to complete JSON', () {
        // Act
        final json = testUserProfileModel.toJson();

        // Assert
        expect(json['id'], equals('user_123'));
        expect(json['name'], equals('John Doe'));
        expect(json['email'], equals('john.doe@example.com'));
        expect(json['phoneNumber'], equals('+1234567890'));
        expect(json['avatarUrl'], equals('https://example.com/avatar.jpg'));
        expect(json['address'], isA<Map<String, dynamic>>());
        expect(json['address']['street'], equals('123 Main St'));
        expect(json['birthDate'], equals('1990-05-12T00:00:00.000'));
        expect(json['bio'], equals('Software developer and book lover'));
        expect(json['isEmailVerified'], isTrue);
        expect(json['isPhoneVerified'], isFalse);
        expect(json['createdAt'], equals('2023-06-15T10:30:00.000'));
        expect(json['updatedAt'], equals('2023-06-15T10:30:00.000'));
      });

      test('should convert UserProfileModel with null fields to JSON', () {
        // Arrange
        final minimalProfile = UserProfileModel(
          id: 'user_minimal',
          name: 'Jane Smith',
          email: 'jane@example.com',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act
        final json = minimalProfile.toJson();

        // Assert
        expect(json['phoneNumber'], isNull);
        expect(json['avatarUrl'], isNull);
        expect(json['address'], isNull);
        expect(json['birthDate'], isNull);
        expect(json['bio'], isNull);
        expect(json['isEmailVerified'], isFalse);
        expect(json['isPhoneVerified'], isFalse);
      });
    });

    group('Entity Conversion', () {
      test('should create UserProfileModel from UserProfile entity', () {
        // Arrange
        final entity = UserProfile(
          id: 'entity_123',
          name: 'Entity User',
          email: 'entity@example.com',
          phoneNumber: '+9876543210',
          isEmailVerified: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act
        final model = UserProfileModel.fromEntity(entity);

        // Assert
        expect(model, isA<UserProfileModel>());
        expect(model.id, equals('entity_123'));
        expect(model.name, equals('Entity User'));
        expect(model.email, equals('entity@example.com'));
        expect(model.phoneNumber, equals('+9876543210'));
        expect(model.isEmailVerified, isTrue);
        expect(model.createdAt, equals(testDateTime));
        expect(model.updatedAt, equals(testDateTime));
      });

      test('should preserve all entity properties when converting', () {
        // Arrange
        final entity = UserProfile(
          id: 'full_entity',
          name: 'Full Entity User',
          email: 'full@example.com',
          phoneNumber: '+1111111111',
          avatarUrl: 'https://example.com/full.jpg',
          address: testUserProfileAddress,
          birthDate: testBirthDate,
          bio: 'Full bio',
          isEmailVerified: true,
          isPhoneVerified: true,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act
        final model = UserProfileModel.fromEntity(entity);

        // Assert
        expect(model.id, equals(entity.id));
        expect(model.name, equals(entity.name));
        expect(model.email, equals(entity.email));
        expect(model.phoneNumber, equals(entity.phoneNumber));
        expect(model.avatarUrl, equals(entity.avatarUrl));
        expect(model.address, equals(entity.address));
        expect(model.birthDate, equals(entity.birthDate));
        expect(model.bio, equals(entity.bio));
        expect(model.isEmailVerified, equals(entity.isEmailVerified));
        expect(model.isPhoneVerified, equals(entity.isPhoneVerified));
        expect(model.createdAt, equals(entity.createdAt));
        expect(model.updatedAt, equals(entity.updatedAt));
      });
    });

    group('CopyWith Method', () {
      test('should create copy with no changes when no parameters provided', () {
        // Act
        final copied = testUserProfileModel.copyWith();

        // Assert
        expect(copied, isA<UserProfileModel>());
        expect(copied.id, equals(testUserProfileModel.id));
        expect(copied.name, equals(testUserProfileModel.name));
        expect(copied.email, equals(testUserProfileModel.email));
        expect(copied.phoneNumber, equals(testUserProfileModel.phoneNumber));
        expect(copied.avatarUrl, equals(testUserProfileModel.avatarUrl));
        expect(copied.address, equals(testUserProfileModel.address));
        expect(copied.birthDate, equals(testUserProfileModel.birthDate));
        expect(copied.bio, equals(testUserProfileModel.bio));
        expect(copied.isEmailVerified, equals(testUserProfileModel.isEmailVerified));
        expect(copied.isPhoneVerified, equals(testUserProfileModel.isPhoneVerified));
        expect(copied.createdAt, equals(testUserProfileModel.createdAt));
        expect(copied.updatedAt, equals(testUserProfileModel.updatedAt));
      });

      test('should create copy with updated name and email', () {
        // Act
        final copied = testUserProfileModel.copyWith(
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
        );

        // Assert
        expect(copied.name, equals('Jane Smith'));
        expect(copied.email, equals('jane.smith@example.com'));
        expect(copied.id, equals(testUserProfileModel.id)); // unchanged
        expect(copied.phoneNumber, equals(testUserProfileModel.phoneNumber)); // unchanged
      });

      test('should create copy with updated verification status', () {
        // Act
        final copied = testUserProfileModel.copyWith(
          isEmailVerified: false,
          isPhoneVerified: true,
        );

        // Assert
        expect(copied.isEmailVerified, isFalse);
        expect(copied.isPhoneVerified, isTrue);
        expect(copied.name, equals(testUserProfileModel.name)); // unchanged
        expect(copied.email, equals(testUserProfileModel.email)); // unchanged
      });

      test('should create copy with updated timestamps', () {
        // Arrange
        final newTimestamp = DateTime(2023, 12, 25, 15, 45);

        // Act
        final copied = testUserProfileModel.copyWith(
          updatedAt: newTimestamp,
        );

        // Assert
        expect(copied.updatedAt, equals(newTimestamp));
        expect(copied.createdAt, equals(testUserProfileModel.createdAt)); // unchanged
      });
    });

    group('JSON Round Trip', () {
      test('should maintain data integrity through JSON round trip', () {
        // Act
        final json = testUserProfileModel.toJson();
        final reconstructed = UserProfileModel.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(testUserProfileModel.id));
        expect(reconstructed.name, equals(testUserProfileModel.name));
        expect(reconstructed.email, equals(testUserProfileModel.email));
        expect(reconstructed.phoneNumber, equals(testUserProfileModel.phoneNumber));
        expect(reconstructed.avatarUrl, equals(testUserProfileModel.avatarUrl));
        expect(reconstructed.address, isNotNull);
        expect(reconstructed.address!.street, equals(testUserProfileModel.address!.street));
        expect(reconstructed.birthDate, equals(testUserProfileModel.birthDate));
        expect(reconstructed.bio, equals(testUserProfileModel.bio));
        expect(reconstructed.isEmailVerified, equals(testUserProfileModel.isEmailVerified));
        expect(reconstructed.isPhoneVerified, equals(testUserProfileModel.isPhoneVerified));
        expect(reconstructed.createdAt, equals(testUserProfileModel.createdAt));
        expect(reconstructed.updatedAt, equals(testUserProfileModel.updatedAt));
      });

      test('should handle round trip with minimal data', () {
        // Arrange
        final minimalProfile = UserProfileModel(
          id: 'minimal_test',
          name: 'Minimal User',
          email: 'minimal@example.com',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act
        final json = minimalProfile.toJson();
        final reconstructed = UserProfileModel.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(minimalProfile.id));
        expect(reconstructed.name, equals(minimalProfile.name));
        expect(reconstructed.email, equals(minimalProfile.email));
        expect(reconstructed.phoneNumber, isNull);
        expect(reconstructed.address, isNull);
        expect(reconstructed.birthDate, isNull);
        expect(reconstructed.bio, isNull);
      });
    });

    group('Inheritance and Type Checking', () {
      test('should be instance of UserProfile entity', () {
        // Assert
        expect(testUserProfileModel, isA<UserProfile>());
        expect(testUserProfileModel, isA<UserProfileModel>());
      });

      test('should inherit all UserProfile properties and methods', () {
        // Assert - check inherited methods work
        expect(testUserProfileModel.displayName, equals('John'));
        expect(testUserProfileModel.initials, equals('JD'));
        expect(testUserProfileModel.isProfileComplete, isTrue);
        expect(testUserProfileModel.completionPercentage, equals(1.0));
      });
    });

    group('Edge Cases', () {
      test('should handle very long strings', () {
        // Arrange
        final longString = 'a' * 1000;
        final profileWithLongStrings = UserProfileModel(
          id: longString,
          name: longString,
          email: '$longString@example.com',
          bio: longString,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act
        final json = profileWithLongStrings.toJson();
        final reconstructed = UserProfileModel.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(longString));
        expect(reconstructed.name, equals(longString));
        expect(reconstructed.bio, equals(longString));
      });

      test('should handle special characters in strings', () {
        // Arrange
        final specialName = 'José María Øresund 中文 🎉';
        final profileWithSpecialChars = UserProfileModel(
          id: 'special_chars',
          name: specialName,
          email: 'special@例え.テスト',
          bio: 'Special chars: áéíóú ñ ç ü ß 中文 日本語 🎉🎊🎈',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Act
        final json = profileWithSpecialChars.toJson();
        final reconstructed = UserProfileModel.fromJson(json);

        // Assert
        expect(reconstructed.name, equals(specialName));
        expect(reconstructed.email, equals('special@例え.テスト'));
        expect(reconstructed.bio, contains('🎉🎊🎈'));
      });

      test('should handle different date formats', () {
        // Arrange
        final differentDateFormats = [
          '2023-06-15T10:30:00.000Z',
          '2023-06-15T10:30:00Z',
          '2023-06-15T10:30:00.123456Z',
        ];

        for (final dateString in differentDateFormats) {
          final json = {
            'id': 'date_test',
            'name': 'Date Test',
            'email': 'date@example.com',
            'birthDate': dateString,
            'createdAt': dateString,
            'updatedAt': dateString,
          };

          // Act & Assert
          expect(() => UserProfileModel.fromJson(json), returnsNormally);
        }
      });

      test('should handle empty and whitespace strings', () {
        // Arrange
        final json = {
          'id': '',
          'name': '   ',
          'email': '\t\n',
          'phoneNumber': '',
          'avatarUrl': '   ',
          'bio': '',
          'createdAt': '2023-06-15T10:30:00.000Z',
          'updatedAt': '2023-06-15T10:30:00.000Z',
        };

        // Act
        final userProfile = UserProfileModel.fromJson(json);

        // Assert
        expect(userProfile.id, equals(''));
        expect(userProfile.name, equals('   '));
        expect(userProfile.email, equals('\t\n'));
        expect(userProfile.phoneNumber, equals(''));
        expect(userProfile.avatarUrl, equals('   '));
        expect(userProfile.bio, equals(''));
      });
    });
  });

  group('ProfileAddressModel Tests', () {
    final testAddressJson = {
      'street': '456 Oak Street',
      'city': 'Springfield',
      'state': 'IL',
      'zipCode': '62701',
      'country': 'USA',
      'isDefault': false,
    };

    final testAddressModel = ProfileAddressModel(
      street: '456 Oak Street',
      city: 'Springfield',
      state: 'IL',
      zipCode: '62701',
      country: 'USA',
      isDefault: false,
    );

    group('Constructor', () {
      test('should create ProfileAddressModel with all properties', () {
        // Assert
        expect(testAddressModel.street, equals('456 Oak Street'));
        expect(testAddressModel.city, equals('Springfield'));
        expect(testAddressModel.state, equals('IL'));
        expect(testAddressModel.zipCode, equals('62701'));
        expect(testAddressModel.country, equals('USA'));
        expect(testAddressModel.isDefault, isFalse);
      });

      test('should create ProfileAddressModel with default values', () {
        // Arrange & Act
        const addressModel = ProfileAddressModel();

        // Assert
        expect(addressModel.street, isNull);
        expect(addressModel.city, isNull);
        expect(addressModel.state, isNull);
        expect(addressModel.zipCode, isNull);
        expect(addressModel.country, isNull);
        expect(addressModel.isDefault, isTrue); // Default value
      });
    });

    group('JSON Serialization', () {
      test('should create ProfileAddressModel from JSON', () {
        // Act
        final addressModel = ProfileAddressModel.fromJson(testAddressJson);

        // Assert
        expect(addressModel.street, equals('456 Oak Street'));
        expect(addressModel.city, equals('Springfield'));
        expect(addressModel.state, equals('IL'));
        expect(addressModel.zipCode, equals('62701'));
        expect(addressModel.country, equals('USA'));
        expect(addressModel.isDefault, isFalse);
      });

      test('should handle missing fields in JSON with defaults', () {
        // Arrange
        final minimalJson = {
          'street': '789 Pine St',
        };

        // Act
        final addressModel = ProfileAddressModel.fromJson(minimalJson);

        // Assert
        expect(addressModel.street, equals('789 Pine St'));
        expect(addressModel.city, isNull);
        expect(addressModel.state, isNull);
        expect(addressModel.zipCode, isNull);
        expect(addressModel.country, isNull);
        expect(addressModel.isDefault, isTrue); // Default value
      });

      test('should convert ProfileAddressModel to JSON', () {
        // Act
        final json = testAddressModel.toJson();

        // Assert
        expect(json['street'], equals('456 Oak Street'));
        expect(json['city'], equals('Springfield'));
        expect(json['state'], equals('IL'));
        expect(json['zipCode'], equals('62701'));
        expect(json['country'], equals('USA'));
        expect(json['isDefault'], isFalse);
      });
    });

    group('Entity Conversion', () {
      test('should create ProfileAddressModel from ProfileAddress entity', () {
        // Arrange
        const entity = ProfileAddress(
          street: '123 Entity St',
          city: 'Entity City',
          state: 'EC',
          zipCode: '12345',
          country: 'Entity Country',
          isDefault: true,
        );

        // Act
        final model = ProfileAddressModel.fromEntity(entity);

        // Assert
        expect(model, isA<ProfileAddressModel>());
        expect(model.street, equals('123 Entity St'));
        expect(model.city, equals('Entity City'));
        expect(model.state, equals('EC'));
        expect(model.zipCode, equals('12345'));
        expect(model.country, equals('Entity Country'));
        expect(model.isDefault, isTrue);
      });
    });

    group('CopyWith Method', () {
      test('should create copy with updated fields', () {
        // Act
        final copied = testAddressModel.copyWith(
          street: '999 New Street',
          isDefault: true,
        );

        // Assert
        expect(copied, isA<ProfileAddressModel>());
        expect(copied.street, equals('999 New Street'));
        expect(copied.isDefault, isTrue);
        expect(copied.city, equals(testAddressModel.city)); // unchanged
        expect(copied.state, equals(testAddressModel.state)); // unchanged
      });
    });

    group('Inheritance', () {
      test('should be instance of ProfileAddress entity', () {
        // Assert
        expect(testAddressModel, isA<ProfileAddress>());
        expect(testAddressModel, isA<ProfileAddressModel>());
      });

      test('should inherit ProfileAddress methods', () {
        // Assert - check inherited methods work
        expect(testAddressModel.isComplete, isTrue);
        expect(testAddressModel.formattedAddress, isNotEmpty);
        expect(testAddressModel.formattedAddress, contains('456 Oak Street'));
        expect(testAddressModel.formattedAddress, contains('Springfield'));
      });
    });

    group('JSON Round Trip', () {
      test('should maintain data integrity through JSON round trip', () {
        // Act
        final json = testAddressModel.toJson();
        final reconstructed = ProfileAddressModel.fromJson(json);

        // Assert
        expect(reconstructed.street, equals(testAddressModel.street));
        expect(reconstructed.city, equals(testAddressModel.city));
        expect(reconstructed.state, equals(testAddressModel.state));
        expect(reconstructed.zipCode, equals(testAddressModel.zipCode));
        expect(reconstructed.country, equals(testAddressModel.country));
        expect(reconstructed.isDefault, equals(testAddressModel.isDefault));
      });
    });
  });
}
