import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogLevel', () {
    group('values', () {
      test('should have correct hierarchy values', () {
        expect(LogLevel.none.value, 0);
        expect(LogLevel.error.value, 1);
        expect(LogLevel.warning.value, 2);
        expect(LogLevel.info.value, 3);
        expect(LogLevel.debug.value, 4);
        expect(LogLevel.trace.value, 5);
      });
    });

    group('shouldLog', () {
      test('should return true when log level is within configured level', () {
        // ERROR (1) should log when config is INFO (3)
        expect(LogLevel.error.shouldLog(LogLevel.info), true);
        
        // WARNING (2) should log when config is INFO (3)
        expect(LogLevel.warning.shouldLog(LogLevel.info), true);
        
        // INFO (3) should log when config is INFO (3)
        expect(LogLevel.info.shouldLog(LogLevel.info), true);
      });

      test('should return false when log level exceeds configured level', () {
        // DEBUG (4) should NOT log when config is INFO (3)
        expect(LogLevel.debug.shouldLog(LogLevel.info), false);
        
        // TRACE (5) should NOT log when config is INFO (3)
        expect(LogLevel.trace.shouldLog(LogLevel.info), false);
      });

      test('should return false when configured level is NONE', () {
        expect(LogLevel.error.shouldLog(LogLevel.none), false);
        expect(LogLevel.warning.shouldLog(LogLevel.none), false);
        expect(LogLevel.info.shouldLog(LogLevel.none), false);
        expect(LogLevel.debug.shouldLog(LogLevel.none), false);
        expect(LogLevel.trace.shouldLog(LogLevel.none), false);
      });

      test('should return true for all levels when config is TRACE', () {
        expect(LogLevel.error.shouldLog(LogLevel.trace), true);
        expect(LogLevel.warning.shouldLog(LogLevel.trace), true);
        expect(LogLevel.info.shouldLog(LogLevel.trace), true);
        expect(LogLevel.debug.shouldLog(LogLevel.trace), true);
        expect(LogLevel.trace.shouldLog(LogLevel.trace), true);
      });
    });

    group('fromString', () {
      test('should return correct LogLevel from string', () {
        expect(LogLevel.fromString('none'), LogLevel.none);
        expect(LogLevel.fromString('error'), LogLevel.error);
        expect(LogLevel.fromString('warning'), LogLevel.warning);
        expect(LogLevel.fromString('info'), LogLevel.info);
        expect(LogLevel.fromString('debug'), LogLevel.debug);
        expect(LogLevel.fromString('trace'), LogLevel.trace);
      });

      test('should be case insensitive', () {
        expect(LogLevel.fromString('ERROR'), LogLevel.error);
        expect(LogLevel.fromString('Warning'), LogLevel.warning);
        expect(LogLevel.fromString('INFO'), LogLevel.info);
      });

      test('should return info as default for invalid string', () {
        expect(LogLevel.fromString('invalid'), LogLevel.info);
        expect(LogLevel.fromString(''), LogLevel.info);
        expect(LogLevel.fromString('xyz'), LogLevel.info);
      });
    });
  });
}
