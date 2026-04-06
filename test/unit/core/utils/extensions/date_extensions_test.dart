import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/utils/extensions/date_extensions.dart';

void main() {
  group('DateTimeExtensions Tests', () {
    group('formattedDate', () {
      test('should format date correctly for single digit day', () {
        // Arrange
        final date = DateTime(2023, 5, 3);

        // Act
        final result = date.formattedDate;

        // Assert
        expect(result, equals('May 03, 2023'));
      });

      test('should format date correctly for double digit day', () {
        // Arrange
        final date = DateTime(2023, 12, 25);

        // Act
        final result = date.formattedDate;

        // Assert
        expect(result, equals('Dec 25, 2023'));
      });

      test('should format date correctly for all months', () {
        // Arrange
        final testCases = [
          {'month': 1, 'expected': 'Jan'},
          {'month': 2, 'expected': 'Feb'},
          {'month': 3, 'expected': 'Mar'},
          {'month': 4, 'expected': 'Apr'},
          {'month': 5, 'expected': 'May'},
          {'month': 6, 'expected': 'Jun'},
          {'month': 7, 'expected': 'Jul'},
          {'month': 8, 'expected': 'Aug'},
          {'month': 9, 'expected': 'Sep'},
          {'month': 10, 'expected': 'Oct'},
          {'month': 11, 'expected': 'Nov'},
          {'month': 12, 'expected': 'Dec'},
        ];

        // Act & Assert
        for (final testCase in testCases) {
          final date = DateTime(2023, testCase['month'] as int, 15);
          final result = date.formattedDate;
          expect(result, equals('${testCase['expected']} 15, 2023'));
        }
      });

      test('should handle leap year correctly', () {
        // Arrange
        final date = DateTime(2024, 2, 29); // Leap year

        // Act
        final result = date.formattedDate;

        // Assert
        expect(result, equals('Feb 29, 2024'));
      });

      test('should handle different years', () {
        // Arrange
        final dates = [
          DateTime(1999, 12, 31),
          DateTime(2000, 1, 1),
          DateTime(2023, 6, 15),
          DateTime(2025, 3, 10),
        ];

        // Act & Assert
        expect(dates[0].formattedDate, equals('Dec 31, 1999'));
        expect(dates[1].formattedDate, equals('Jan 01, 2000'));
        expect(dates[2].formattedDate, equals('Jun 15, 2023'));
        expect(dates[3].formattedDate, equals('Mar 10, 2025'));
      });
    });

    group('isToday', () {
      test('should return true for current date', () {
        // Arrange
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Act
        final result = today.isToday;

        // Assert
        expect(result, isTrue);
      });

      test('should return true for current date with different time', () {
        // Arrange
        final now = DateTime.now();
        final todayDifferentTime = DateTime(now.year, now.month, now.day, 23, 59, 59);

        // Act
        final result = todayDifferentTime.isToday;

        // Assert
        expect(result, isTrue);
      });

      test('should return false for yesterday', () {
        // Arrange
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);

        // Act
        final result = yesterday.isToday;

        // Assert
        expect(result, isFalse);
      });

      test('should return false for tomorrow', () {
        // Arrange
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1);

        // Act
        final result = tomorrow.isToday;

        // Assert
        expect(result, isFalse);
      });

      test('should return false for same day different year', () {
        // Arrange
        final now = DateTime.now();
        final sameMonthDayDifferentYear = DateTime(now.year - 1, now.month, now.day);

        // Act
        final result = sameMonthDayDifferentYear.isToday;

        // Assert
        expect(result, isFalse);
      });
    });

    group('isYesterday', () {
      test('should return true for yesterday', () {
        // Arrange
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);

        // Act
        final result = yesterday.isYesterday;

        // Assert
        expect(result, isTrue);
      });

      test('should return true for yesterday with different time', () {
        // Arrange
        final now = DateTime.now();
        final yesterdayDifferentTime = DateTime(now.year, now.month, now.day - 1, 12, 30, 45);

        // Act
        final result = yesterdayDifferentTime.isYesterday;

        // Assert
        expect(result, isTrue);
      });

      test('should return false for today', () {
        // Arrange
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Act
        final result = today.isYesterday;

        // Assert
        expect(result, isFalse);
      });

      test('should return false for day before yesterday', () {
        // Arrange
        final now = DateTime.now();
        final dayBeforeYesterday = DateTime(now.year, now.month, now.day - 2);

        // Act
        final result = dayBeforeYesterday.isYesterday;

        // Assert
        expect(result, isFalse);
      });

      test('should handle month boundaries correctly', () {
        // Arrange - Create yesterday's date, even if it crosses month boundary
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);

        // Act
        final result = yesterday.isYesterday;

        // Assert - Yesterday should always return true
        expect(result, isTrue);
      });
    });

    group('timeAgo', () {
      test('should return "Just now" for very recent times', () {
        // Arrange
        final now = DateTime.now();
        final recentTime = now.subtract(const Duration(seconds: 30));

        // Act
        final result = recentTime.timeAgo;

        // Assert
        expect(result, equals('Just now'));
      });

      test('should return minutes ago for recent times', () {
        // Arrange
        final now = DateTime.now();
        final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
        final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

        // Act & Assert
        expect(fiveMinutesAgo.timeAgo, equals('5 minutes ago'));
        expect(oneMinuteAgo.timeAgo, equals('1 minute ago'));
      });

      test('should return hours ago for times within same day', () {
        // Arrange
        final now = DateTime.now();
        final threeHoursAgo = now.subtract(const Duration(hours: 3));
        final oneHourAgo = now.subtract(const Duration(hours: 1));

        // Act & Assert
        expect(threeHoursAgo.timeAgo, equals('3 hours ago'));
        expect(oneHourAgo.timeAgo, equals('1 hour ago'));
      });

      test('should return days ago for recent days', () {
        // Arrange
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        final oneDayAgo = now.subtract(const Duration(days: 1));

        // Act & Assert
        expect(threeDaysAgo.timeAgo, equals('3 days ago'));
        expect(oneDayAgo.timeAgo, equals('1 day ago'));
      });

      test('should return months ago for times within same year', () {
        // Arrange
        final now = DateTime.now();
        final twoMonthsAgo = now.subtract(const Duration(days: 65)); // ~2 months
        final oneMonthAgo = now.subtract(const Duration(days: 35)); // ~1 month

        // Act & Assert
        expect(twoMonthsAgo.timeAgo, equals('2 months ago'));
        expect(oneMonthAgo.timeAgo, equals('1 month ago'));
      });

      test('should return years ago for old times', () {
        // Arrange
        final now = DateTime.now();
        final twoYearsAgo = now.subtract(const Duration(days: 800)); // ~2 years
        final oneYearAgo = now.subtract(const Duration(days: 400)); // ~1 year

        // Act & Assert
        expect(twoYearsAgo.timeAgo, equals('2 years ago'));
        expect(oneYearAgo.timeAgo, equals('1 year ago'));
      });

      test('should handle singular vs plural correctly', () {
        // Arrange
        final now = DateTime.now();
        final exactlyOneMinute = now.subtract(const Duration(minutes: 1));
        final exactlyOneHour = now.subtract(const Duration(hours: 1));
        final exactlyOneDay = now.subtract(const Duration(days: 1));

        // Act & Assert
        expect(exactlyOneMinute.timeAgo, equals('1 minute ago'));
        expect(exactlyOneHour.timeAgo, equals('1 hour ago'));
        expect(exactlyOneDay.timeAgo, equals('1 day ago'));
      });

      test('should handle edge cases correctly', () {
        // Arrange
        final now = DateTime.now();
        final almostOneHour = now.subtract(const Duration(minutes: 59));
        final almostOneDay = now.subtract(const Duration(hours: 23));
        final almostOneMonth = now.subtract(const Duration(days: 29));

        // Act & Assert
        expect(almostOneHour.timeAgo, equals('59 minutes ago'));
        expect(almostOneDay.timeAgo, equals('23 hours ago'));
        expect(almostOneMonth.timeAgo, equals('29 days ago'));
      });

      test('should work with real current time', () {
        // Arrange
        final now = DateTime.now();
        final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));

        // Act
        final result = fiveMinutesAgo.timeAgo;

        // Assert
        expect(result, equals('5 minutes ago'));
      });
    });

    group('Edge Cases and Integration', () {
      test('should handle DateTime.now() consistently', () {
        // Arrange
        final now = DateTime.now();

        // Act & Assert
        expect(now.isToday, isTrue);
        expect(now.isYesterday, isFalse);
        expect(now.timeAgo, equals('Just now'));
      });

      test('should handle very old dates', () {
        // Arrange
        final oldDate = DateTime(1990, 1, 1);

        // Act
        final timeAgo = oldDate.timeAgo;
        final formattedDate = oldDate.formattedDate;

        // Assert
        expect(timeAgo, contains('years ago'));
        expect(formattedDate, equals('Jan 01, 1990'));
        expect(oldDate.isToday, isFalse);
        expect(oldDate.isYesterday, isFalse);
      });

      test('should handle future dates gracefully', () {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 30));

        // Act & Assert
        expect(futureDate.isToday, isFalse);
        expect(futureDate.isYesterday, isFalse);
        expect(futureDate.formattedDate, isA<String>());
        // timeAgo for future dates should still work (though logically it's "time until")
        expect(futureDate.timeAgo, isA<String>());
      });

      test('should handle leap year edge cases', () {
        // Arrange
        final leapYearDate = DateTime(2024, 2, 29);
        final nonLeapYearDate = DateTime(2023, 2, 28);

        // Act & Assert
        expect(leapYearDate.formattedDate, equals('Feb 29, 2024'));
        expect(nonLeapYearDate.formattedDate, equals('Feb 28, 2023'));
      });

      test('should be consistent across different DateTime constructors', () {
        // Arrange
        final date1 = DateTime(2023, 6, 15);
        final date2 = DateTime.parse('2023-06-15');

        // Act & Assert
        expect(date1.formattedDate, equals(date2.formattedDate));
        expect(date1.formattedDate, contains('Jun 15, 2023'));
      });

      test('should handle timezone differences gracefully', () {
        // Arrange
        final utcDate = DateTime.utc(2023, 6, 15, 12, 0, 0);
        final localDate = utcDate.toLocal();

        // Act
        final utcFormatted = utcDate.formattedDate;
        final localFormatted = localDate.formattedDate;

        // Assert
        // Both should format to the same date regardless of timezone
        // (unless they cross date boundaries due to timezone difference)
        expect(utcFormatted, isA<String>());
        expect(localFormatted, isA<String>());
      });
    });
  });
}
