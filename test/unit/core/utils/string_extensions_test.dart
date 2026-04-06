import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library/core/utils/extensions/string_extensions.dart';

void main() {
  group('String Extensions Tests', () {
    group('capitalize', () {
      test('should capitalize first letter of single word', () {
        expect('hello'.capitalize, equals('Hello'));
        expect('world'.capitalize, equals('World'));
        expect('test'.capitalize, equals('Test'));
      });

      test('should handle empty string', () {
        expect(''.capitalize, equals(''));
      });

      test('should handle single character', () {
        expect('a'.capitalize, equals('A'));
        expect('z'.capitalize, equals('Z'));
      });

      test('should handle already capitalized string', () {
        expect('Hello'.capitalize, equals('Hello'));
        expect('World'.capitalize, equals('World'));
      });

      test('should lowercase rest of the string', () {
        expect('hELLO'.capitalize, equals('Hello'));
        expect('wORLD'.capitalize, equals('World'));
        expect('tEST'.capitalize, equals('Test'));
      });

      test('should handle numbers and special characters', () {
        expect('1hello'.capitalize, equals('1hello'));
        expect('!hello'.capitalize, equals('!hello'));
        expect('#test'.capitalize, equals('#test'));
      });

      test('should handle mixed case and spaces', () {
        expect('hello world'.capitalize, equals('Hello world'));
        expect('test STRING'.capitalize, equals('Test string'));
      });
    });

    group('titleCase', () {
      test('should convert words to title case', () {
        expect('hello world'.titleCase, equals('Hello World'));
        expect('the quick brown fox'.titleCase, equals('The Quick Brown Fox'));
        expect('flutter development'.titleCase, equals('Flutter Development'));
      });

      test('should handle single word', () {
        expect('hello'.titleCase, equals('Hello'));
        expect('world'.titleCase, equals('World'));
      });

      test('should handle empty string', () {
        expect(''.titleCase, equals(''));
      });

      test('should handle multiple spaces', () {
        expect('hello  world'.titleCase, equals('Hello  World'));
        expect('test   string'.titleCase, equals('Test   String'));
      });

      test('should handle mixed case input', () {
        expect('hELLo WoRLd'.titleCase, equals('Hello World'));
        expect('UPPERCASE TEXT'.titleCase, equals('Uppercase Text'));
        expect('lowercase text'.titleCase, equals('Lowercase Text'));
      });
    });

    group('isEmail', () {
      test('should return true for valid email addresses', () {
        expect('test@example.com'.isEmail, isTrue);
        expect('user@domain.org'.isEmail, isTrue);
        expect('name.lastname@company.co.uk'.isEmail, isTrue);
        expect('user123@example123.com'.isEmail, isTrue);
      });

      test('should return false for invalid email addresses', () {
        expect('invalid-email'.isEmail, isFalse);
        expect('test@'.isEmail, isFalse);
        expect('@example.com'.isEmail, isFalse);
        expect('test.example.com'.isEmail, isFalse);
        expect('test@.com'.isEmail, isFalse);
        expect('test@example.'.isEmail, isFalse);
      });

      test('should return false for empty string', () {
        expect(''.isEmail, isFalse);
      });

      test('should handle edge cases', () {
        expect('a@b.co'.isEmail, isTrue);
        expect('@'.isEmail, isFalse);
        expect('test@@example.com'.isEmail, isFalse);
        expect('test@exam ple.com'.isEmail, isFalse);
      });

      test('should handle plus signs and hyphens', () {
        expect('user+tag@example.com'.isEmail, isTrue);
        expect('user-name@example.com'.isEmail, isTrue);
        expect('user_name@example.com'.isEmail, isTrue);
      });
    });

    group('isPhoneNumber', () {
      test('should return true for valid phone numbers', () {
        expect('+1234567890'.isPhoneNumber, isTrue);
        expect('1234567890'.isPhoneNumber, isTrue);
        expect('+123456789012345'.isPhoneNumber, isTrue);
      });

      test('should return false for invalid phone numbers', () {
        expect(''.isPhoneNumber, isFalse);
        expect('abc123'.isPhoneNumber, isFalse);
        expect('12345678901234567'.isPhoneNumber, isFalse); // Too long
        expect('+0123456789'.isPhoneNumber, isFalse); // Starting with 0 after +
      });

      test('should handle edge cases', () {
        expect('+12'.isPhoneNumber, isTrue); // Minimum valid length
        expect('12'.isPhoneNumber, isTrue); // Minimum without +
        expect('123-456-7890'.isPhoneNumber, isFalse); // Contains hyphens
        expect('(123) 456-7890'.isPhoneNumber, isFalse); // Contains spaces and parentheses
      });
    });

    group('removeWhitespace', () {
      test('should remove all whitespace', () {
        expect('hello world'.removeWhitespace, equals('helloworld'));
        expect('test   string'.removeWhitespace, equals('teststring'));
        expect('  spaced  text  '.removeWhitespace, equals('spacedtext'));
      });

      test('should handle tabs and newlines', () {
        expect('hello\tworld'.removeWhitespace, equals('helloworld'));
        expect('hello\nworld'.removeWhitespace, equals('helloworld'));
        expect('hello\r\nworld'.removeWhitespace, equals('helloworld'));
      });

      test('should handle empty string', () {
        expect(''.removeWhitespace, equals(''));
      });

      test('should handle string with only whitespace', () {
        expect('   '.removeWhitespace, equals(''));
        expect('\t\n\r'.removeWhitespace, equals(''));
      });

      test('should preserve non-whitespace characters', () {
        expect('hello@world.com'.removeWhitespace, equals('hello@world.com'));
        expect('123-456-7890'.removeWhitespace, equals('123-456-7890'));
      });
    });

    group('isValidUrl', () {
      test('should return true for valid URLs', () {
        expect('https://www.example.com'.isValidUrl, isTrue);
        expect('http://example.com'.isValidUrl, isTrue);
        expect('https://subdomain.example.com/path'.isValidUrl, isTrue);
        expect('ftp://ftp.example.com'.isValidUrl, isTrue);
      });

      test('should return false for invalid URLs', () {
        expect('not-a-url'.isValidUrl, isFalse);
        expect(''.isValidUrl, isFalse);
        expect('http://'.isValidUrl, isFalse);
        expect('://example.com'.isValidUrl, isFalse);
      });

      test('should handle edge cases', () {
        expect('example.com'.isValidUrl, isTrue); // Uri.tryParse might accept this
        expect('www.example.com'.isValidUrl, isTrue);
        expect('mailto:test@example.com'.isValidUrl, isTrue);
        expect('file:///path/to/file'.isValidUrl, isTrue);
      });
    });

    group('truncate', () {
      test('should truncate long strings', () {
        const longString = 'This is a very long string that should be truncated';
        expect(longString.truncate(20), equals('This is a very long ...'));
        expect(longString.truncate(10), equals('This is a ...'));
        expect(longString.truncate(5), equals('This ...'));
      });

      test('should not truncate short strings', () {
        const shortString = 'Short';
        expect(shortString.truncate(10), equals('Short'));
        expect(shortString.truncate(5), equals('Short'));
      });

      test('should handle edge cases', () {
        expect(''.truncate(10), equals(''));
        expect('Test'.truncate(4), equals('Test'));
        expect('Test'.truncate(3), equals('Tes...'));
        expect('Test'.truncate(0), equals('...'));
      });

      test('should use custom suffix', () {
        const longString = 'This is a long string';
        expect(longString.truncate(10, suffix: '***'), equals('This is a ***'));
        expect(longString.truncate(10, suffix: '>>'), equals('This is a >>'));
        expect(longString.truncate(10, suffix: ''), equals('This is a '));
      });

      test('should handle exact length match', () {
        const testString = 'Exactly ten ch';
        expect(testString.truncate(14), equals('Exactly ten ch'));
        expect(testString.truncate(13), equals('Exactly ten c...'));
      });
    });

    group('combined extensions', () {
      test('should work when chained together', () {
        expect('  HELLO WORLD  '.removeWhitespace.capitalize, equals('Helloworld'));
        expect('hello world'.titleCase.removeWhitespace, equals('HelloWorld'));
        expect('VERY LONG TEXT STRING'.titleCase.truncate(10), equals('Very Long ...'));
      });

      test('should handle null-like scenarios properly', () {
        expect(''.capitalize.titleCase.removeWhitespace, equals(''));
        expect('   '.removeWhitespace.capitalize, equals(''));
      });
    });

    group('email validation edge cases', () {
      test('should handle international domain names', () {
        expect('test@example.museum'.isEmail, isTrue);
        expect('user@example.info'.isEmail, isTrue);
      });

      test('should reject emails with spaces', () {
        expect('test @example.com'.isEmail, isFalse);
        expect('test@ example.com'.isEmail, isFalse);
        expect('test@example .com'.isEmail, isFalse);
      });

      test('should handle dots correctly', () {
        expect('test.user@example.com'.isEmail, isTrue);
        expect('.test@example.com'.isEmail, isFalse);
        expect('test.@example.com'.isEmail, isFalse);
        expect('test..user@example.com'.isEmail, isFalse);
      });
    });

    group('phone number validation edge cases', () {
      test('should handle international formats', () {
        expect('+1'.isPhoneNumber, isFalse); // Too short
        expect('+12'.isPhoneNumber, isTrue); // Minimum valid
        expect('+12345678901234'.isPhoneNumber, isTrue); // Long but valid
        expect('+123456789012345'.isPhoneNumber, isTrue); // Maximum valid
        expect('+1234567890123456'.isPhoneNumber, isFalse); // Too long
      });

      test('should reject invalid formats', () {
        expect('1-234-567-8900'.isPhoneNumber, isFalse);
        expect('(123) 456-7890'.isPhoneNumber, isFalse);
        expect('123.456.7890'.isPhoneNumber, isFalse);
        expect('123 456 7890'.isPhoneNumber, isFalse);
      });
    });
  });
}
