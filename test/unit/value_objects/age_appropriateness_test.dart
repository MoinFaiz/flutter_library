import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('AgeAppropriateness Tests', () {
    group('Enum Values', () {
      test('should have correct enum values', () {
        // Assert
        expect(AgeAppropriateness.values.length, equals(4));
        expect(AgeAppropriateness.values, contains(AgeAppropriateness.children));
        expect(AgeAppropriateness.values, contains(AgeAppropriateness.youngAdult));
        expect(AgeAppropriateness.values, contains(AgeAppropriateness.adult));
        expect(AgeAppropriateness.values, contains(AgeAppropriateness.allAges));
      });

      test('should have correct enum names', () {
        // Assert
        expect(AgeAppropriateness.children.name, equals('children'));
        expect(AgeAppropriateness.youngAdult.name, equals('youngAdult'));
        expect(AgeAppropriateness.adult.name, equals('adult'));
        expect(AgeAppropriateness.allAges.name, equals('allAges'));
      });
    });

    group('Display Names', () {
      test('should have correct display names', () {
        // Assert
        expect(AgeAppropriateness.children.displayName, equals('Children (0-12)'));
        expect(AgeAppropriateness.youngAdult.displayName, equals('Young Adult (13-17)'));
        expect(AgeAppropriateness.adult.displayName, equals('Adult (18+)'));
        expect(AgeAppropriateness.allAges.displayName, equals('All Ages'));
      });

      test('should return different display names for different enum values', () {
        // Arrange
        final allDisplayNames = AgeAppropriateness.values.map((e) => e.displayName).toSet();

        // Assert
        expect(allDisplayNames.length, equals(4)); // All display names should be unique
      });
    });

    group('Enum Parsing', () {
      test('should parse enum from name correctly', () {
        // Arrange & Act
        final childrenEnum = AgeAppropriateness.values.byName('children');
        final youngAdultEnum = AgeAppropriateness.values.byName('youngAdult');
        final adultEnum = AgeAppropriateness.values.byName('adult');
        final allAgesEnum = AgeAppropriateness.values.byName('allAges');

        // Assert
        expect(childrenEnum, equals(AgeAppropriateness.children));
        expect(youngAdultEnum, equals(AgeAppropriateness.youngAdult));
        expect(adultEnum, equals(AgeAppropriateness.adult));
        expect(allAgesEnum, equals(AgeAppropriateness.allAges));
      });

      test('should throw ArgumentError for invalid enum name', () {
        // Act & Assert
        expect(
          () => AgeAppropriateness.values.byName('invalid'),
          throwsArgumentError,
        );
      });

      test('should parse enum from name with case sensitivity', () {
        // Act & Assert
        expect(
          () => AgeAppropriateness.values.byName('Children'), // Wrong case
          throwsArgumentError,
        );
        expect(
          () => AgeAppropriateness.values.byName('ADULT'), // Wrong case
          throwsArgumentError,
        );
      });
    });

    group('Enum Comparison', () {
      test('should compare enum values correctly', () {
        // Assert
        expect(AgeAppropriateness.children == AgeAppropriateness.children, isTrue);
        expect(AgeAppropriateness.children == AgeAppropriateness.adult, isFalse);
        expect(AgeAppropriateness.youngAdult != AgeAppropriateness.allAges, isTrue);
      });

      test('should work correctly in sets', () {
        // Arrange
        final ageList = [
          AgeAppropriateness.children,
          AgeAppropriateness.adult,
          AgeAppropriateness.children, // Duplicate
        ];
        final ageSet = ageList.toSet();

        // Assert
        expect(ageSet.length, equals(2)); // Duplicates should be removed
        expect(ageSet, contains(AgeAppropriateness.children));
        expect(ageSet, contains(AgeAppropriateness.adult));
        expect(ageSet, isNot(contains(AgeAppropriateness.youngAdult)));
      });

      test('should work correctly in maps as keys', () {
        // Arrange
        final ageMap = <AgeAppropriateness, String>{
          AgeAppropriateness.children: 'Kids books',
          AgeAppropriateness.youngAdult: 'Teen books',
          AgeAppropriateness.adult: 'Adult books',
          AgeAppropriateness.allAges: 'Family books',
        };

        // Assert
        expect(ageMap[AgeAppropriateness.children], equals('Kids books'));
        expect(ageMap[AgeAppropriateness.youngAdult], equals('Teen books'));
        expect(ageMap[AgeAppropriateness.adult], equals('Adult books'));
        expect(ageMap[AgeAppropriateness.allAges], equals('Family books'));
      });
    });

    group('Enum Iteration', () {
      test('should iterate through all values', () {
        // Arrange
        final valuesList = <AgeAppropriateness>[];

        // Act
        for (final ageType in AgeAppropriateness.values) {
          valuesList.add(ageType);
        }

        // Assert
        expect(valuesList.length, equals(4));
        expect(valuesList, contains(AgeAppropriateness.children));
        expect(valuesList, contains(AgeAppropriateness.youngAdult));
        expect(valuesList, contains(AgeAppropriateness.adult));
        expect(valuesList, contains(AgeAppropriateness.allAges));
      });

      test('should maintain order in values list', () {
        // Assert
        expect(AgeAppropriateness.values[0], equals(AgeAppropriateness.children));
        expect(AgeAppropriateness.values[1], equals(AgeAppropriateness.youngAdult));
        expect(AgeAppropriateness.values[2], equals(AgeAppropriateness.adult));
        expect(AgeAppropriateness.values[3], equals(AgeAppropriateness.allAges));
      });
    });

    group('String Representation', () {
      test('should have correct toString representation', () {
        // Assert
        expect(AgeAppropriateness.children.toString(), equals('AgeAppropriateness.children'));
        expect(AgeAppropriateness.youngAdult.toString(), equals('AgeAppropriateness.youngAdult'));
        expect(AgeAppropriateness.adult.toString(), equals('AgeAppropriateness.adult'));
        expect(AgeAppropriateness.allAges.toString(), equals('AgeAppropriateness.allAges'));
      });

      test('should have correct index property', () {
        // Assert
        expect(AgeAppropriateness.children.index, equals(0));
        expect(AgeAppropriateness.youngAdult.index, equals(1));
        expect(AgeAppropriateness.adult.index, equals(2));
        expect(AgeAppropriateness.allAges.index, equals(3));
      });
    });

    group('Use Cases', () {
      test('should work in switch statements', () {
        // Arrange
        String getAgeDescription(AgeAppropriateness age) {
          switch (age) {
            case AgeAppropriateness.children:
              return 'For young readers';
            case AgeAppropriateness.youngAdult:
              return 'For teenagers';
            case AgeAppropriateness.adult:
              return 'For mature readers';
            case AgeAppropriateness.allAges:
              return 'For everyone';
          }
        }

        // Act & Assert
        expect(getAgeDescription(AgeAppropriateness.children), equals('For young readers'));
        expect(getAgeDescription(AgeAppropriateness.youngAdult), equals('For teenagers'));
        expect(getAgeDescription(AgeAppropriateness.adult), equals('For mature readers'));
        expect(getAgeDescription(AgeAppropriateness.allAges), equals('For everyone'));
      });

      test('should work for filtering collections', () {
        // Arrange
        final bookAges = [
          AgeAppropriateness.children,
          AgeAppropriateness.adult,
          AgeAppropriateness.youngAdult,
          AgeAppropriateness.children,
          AgeAppropriateness.allAges,
        ];

        // Act
        final childrenBooks = bookAges.where((age) => age == AgeAppropriateness.children).toList();
        final nonAdultBooks = bookAges.where((age) => age != AgeAppropriateness.adult).toList();

        // Assert
        expect(childrenBooks.length, equals(2));
        expect(nonAdultBooks.length, equals(4));
        expect(nonAdultBooks, isNot(contains(AgeAppropriateness.adult)));
      });

      test('should work for sorting by age category', () {
        // Arrange
        final ages = [
          AgeAppropriateness.adult,
          AgeAppropriateness.children,
          AgeAppropriateness.allAges,
          AgeAppropriateness.youngAdult,
        ];

        // Act
        ages.sort((a, b) => a.index.compareTo(b.index));

        // Assert
        expect(ages[0], equals(AgeAppropriateness.children));
        expect(ages[1], equals(AgeAppropriateness.youngAdult));
        expect(ages[2], equals(AgeAppropriateness.adult));
        expect(ages[3], equals(AgeAppropriateness.allAges));
      });

      test('should work as JSON-serializable values', () {
        // Arrange
        final ageData = <String, dynamic>{
          'book1': AgeAppropriateness.children.name,
          'book2': AgeAppropriateness.adult.name,
        };

        // Act
        final book1Age = AgeAppropriateness.values.byName(ageData['book1']);
        final book2Age = AgeAppropriateness.values.byName(ageData['book2']);

        // Assert
        expect(book1Age, equals(AgeAppropriateness.children));
        expect(book2Age, equals(AgeAppropriateness.adult));
      });
    });

    group('Edge Cases', () {
      test('should handle enum in conditional expressions', () {
        // Arrange
        final age = AgeAppropriateness.children;

        // Act
        final isForKids = age == AgeAppropriateness.children || age == AgeAppropriateness.allAges;
        final isRestrictedContent = age == AgeAppropriateness.adult;

        // Assert
        expect(isForKids, isTrue);
        expect(isRestrictedContent, isFalse);
      });

      test('should work with null safety', () {
        // Arrange
        AgeAppropriateness? nullableAge;
        const AgeAppropriateness nonNullableAge = AgeAppropriateness.adult;

        // Assert
        expect(nullableAge, isNull);
        expect(nonNullableAge, isNotNull);
        expect(nonNullableAge, equals(AgeAppropriateness.adult));
      });

      test('should maintain immutability', () {
        // Arrange
        const age1 = AgeAppropriateness.children;
        const age2 = AgeAppropriateness.children;

        // Assert
        expect(identical(age1, age2), isTrue); // Same instance
        expect(age1.displayName, equals(age2.displayName));
      });
    });
  });
}
