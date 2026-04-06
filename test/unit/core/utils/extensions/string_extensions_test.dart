import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/utils/extensions/string_extensions.dart';

void main() {
  group('StringExtensions Tests', () {
    group('capitalize', () {
      test('should capitalize first letter of lowercase string', () {
        expect('hello'.capitalize, equals('Hello'));
      });

      test('should handle uppercase string', () {
        expect('HELLO'.capitalize, equals('Hello'));
      });

      test('should handle mixed case string', () {
        expect('hELLO'.capitalize, equals('Hello'));
      });

      test('should handle single character', () {
        expect('a'.capitalize, equals('A'));
      });

      test('should handle empty string', () {
        expect(''.capitalize, equals(''));
      });

      test('should handle string starting with number', () {
        expect('1hello'.capitalize, equals('1hello'));
      });
    });

    group('titleCase', () {
      test('should convert multiple words to title case', () {
        expect('hello world'.titleCase, equals('Hello World'));
      });

      test('should handle single word', () {
        expect('hello'.titleCase, equals('Hello'));
      });

      test('should handle mixed case input', () {
        expect('hELLO wORLD'.titleCase, equals('Hello World'));
      });

      test('should handle empty string', () {
        expect(''.titleCase, equals(''));
      });

      test('should handle multiple spaces', () {
        expect('hello  world'.titleCase, equals('Hello  World'));
      });

      test('should handle string with punctuation', () {
        expect('hello, world!'.titleCase, contains('Hello,'));
      });
    });

    group('isEmail', () {
      test('should validate correct email addresses', () {
        expect('test@example.com'.isEmail, isTrue);
        expect('user.name@domain.com'.isEmail, isTrue);
        expect('user+tag@example.co.uk'.isEmail, isTrue);
        expect('user_name@example.com'.isEmail, isTrue);
      });

      test('should reject invalid email addresses', () {
        expect(''.isEmail, isFalse);
        expect('invalid'.isEmail, isFalse);
        expect('@example.com'.isEmail, isFalse);
        expect('user@'.isEmail, isFalse);
        expect('user..name@example.com'.isEmail, isFalse);
        expect('.user@example.com'.isEmail, isFalse);
        expect('user@example'.isEmail, isFalse);
      });

      test('should reject emails with consecutive dots', () {
        expect('user..name@example.com'.isEmail, isFalse);
      });

      test('should reject emails starting with dot', () {
        expect('.user@example.com'.isEmail, isFalse);
      });

      test('should reject emails with dot before @', () {
        expect('user.@example.com'.isEmail, isFalse);
      });

      test('should reject emails with dot after @', () {
        expect('user@.example.com'.isEmail, isFalse);
      });
    });

    group('isPhoneNumber', () {
      test('should validate international phone numbers', () {
        expect('+1234567890'.isPhoneNumber, isTrue);
        expect('+12'.isPhoneNumber, isTrue);
        expect('+123456789012345'.isPhoneNumber, isTrue);
      });

      test('should validate national phone numbers', () {
        expect('1234567890'.isPhoneNumber, isTrue);
        expect('12'.isPhoneNumber, isTrue);
      });

      test('should reject invalid phone numbers', () {
        expect(''.isPhoneNumber, isFalse);
        expect('abc'.isPhoneNumber, isFalse);
        expect('+'.isPhoneNumber, isFalse);
        expect('+0123'.isPhoneNumber, isFalse); // Can't start with 0 after +
        expect('0123'.isPhoneNumber, isFalse); // Can't start with 0
      });

      test('should reject phone numbers that are too short', () {
        expect('+1'.isPhoneNumber, isFalse); // Less than 3 chars
        expect('1'.isPhoneNumber, isFalse); // Less than 2 chars
      });

      test('should reject phone numbers with special characters', () {
        expect('+123-456-7890'.isPhoneNumber, isFalse);
        expect('+123 456 7890'.isPhoneNumber, isFalse);
        expect('(123) 456-7890'.isPhoneNumber, isFalse);
      });
    });

    group('removeWhitespace', () {
      test('should remove all whitespace', () {
        expect('hello world'.removeWhitespace, equals('helloworld'));
      });

      test('should handle multiple spaces', () {
        expect('hello   world'.removeWhitespace, equals('helloworld'));
      });

      test('should handle tabs and newlines', () {
        expect('hello\tworld\n'.removeWhitespace, equals('helloworld'));
      });

      test('should handle empty string', () {
        expect(''.removeWhitespace, equals(''));
      });

      test('should handle string with only whitespace', () {
        expect('   '.removeWhitespace, equals(''));
      });
    });

    group('isValidUrl', () {
      test('should validate URLs with schemes', () {
        expect('https://example.com'.isValidUrl, isTrue);
        expect('http://example.com'.isValidUrl, isTrue);
        expect('ftp://example.com'.isValidUrl, isTrue);
      });

      test('should validate file and mailto URLs', () {
        expect('file:///path/to/file'.isValidUrl, isTrue);
        expect('mailto:user@example.com'.isValidUrl, isTrue);
      });

      test('should validate domain-like patterns without scheme', () {
        expect('example.com'.isValidUrl, isTrue);
        expect('www.example.com'.isValidUrl, isTrue);
        expect('subdomain.example.com'.isValidUrl, isTrue);
      });

      test('should reject invalid URLs', () {
        expect(''.isValidUrl, isFalse);
        expect('invalid'.isValidUrl, isFalse);
        expect('.example.com'.isValidUrl, isFalse);
        expect('example.com.'.isValidUrl, isFalse);
      });

      test('should reject URLs without proper authority when scheme is present', () {
        expect('https://'.isValidUrl, isFalse);
        expect('http://'.isValidUrl, isFalse);
      });
    });

    group('truncate', () {
      test('should truncate string longer than max length', () {
        expect('hello world'.truncate(5), equals('hello...'));
      });

      test('should not truncate string shorter than max length', () {
        expect('hello'.truncate(10), equals('hello'));
      });

      test('should not truncate string equal to max length', () {
        expect('hello'.truncate(5), equals('hello'));
      });

      test('should use custom suffix', () {
        expect('hello world'.truncate(5, suffix: '>>'), equals('hello>>'));
      });

      test('should handle empty string', () {
        expect(''.truncate(5), equals(''));
      });

      test('should handle max length of 0', () {
        expect('hello'.truncate(0), equals('...'));
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in capitalize', () {
        expect('!hello'.capitalize, equals('!hello'));
        expect('@world'.capitalize, equals('@world'));
      });

      test('should handle unicode in capitalize', () {
        expect('über'.capitalize, equals('Über'));
      });

      test('should handle email with plus sign', () {
        expect('user+tag@example.com'.isEmail, isTrue);
      });

      test('should handle URL with query parameters', () {
        expect('https://example.com?param=value'.isValidUrl, isTrue);
      });

      test('should handle URL with fragment', () {
        expect('https://example.com#section'.isValidUrl, isTrue);
      });

      test('should handle very long strings in truncate', () {
        final longString = 'a' * 1000;
        final truncated = longString.truncate(10);
        expect(truncated.length, equals(13)); // 10 + '...' (3)
      });
    });
  });
}
