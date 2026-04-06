import 'package:flutter_library/core/logging/domain/entities/log_config.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogConfig', () {
    test('should create instance with default values', () {
      const config = LogConfig();

      expect(config.enabled, true);
      expect(config.globalLevel, LogLevel.info);
      expect(config.featureLevels, {});
      expect(config.remoteLoggingEnabled, true);
      expect(config.localLoggingEnabled, true);
      expect(config.performanceTrackingEnabled, true);
      expect(config.auditTrackingEnabled, true);
      expect(config.performanceThreshold, 100.0);
      expect(config.tracingEnabledForUsers, []);
      expect(config.maxLocalEntries, 1000);
      expect(config.syncIntervalSeconds, 300);
    });

    test('should create instance with custom values', () {
      final config = LogConfig(
        enabled: false,
        globalLevel: LogLevel.debug,
        featureLevels: {'books': LogLevel.trace},
        remoteLoggingEnabled: false,
        localLoggingEnabled: false,
        performanceTrackingEnabled: false,
        auditTrackingEnabled: false,
        performanceThreshold: 200.0,
        tracingEnabledForUsers: ['user1', 'user2'],
        maxLocalEntries: 500,
        syncIntervalSeconds: 600,
      );

      expect(config.enabled, false);
      expect(config.globalLevel, LogLevel.debug);
      expect(config.featureLevels, {'books': LogLevel.trace});
      expect(config.remoteLoggingEnabled, false);
      expect(config.localLoggingEnabled, false);
      expect(config.performanceTrackingEnabled, false);
      expect(config.auditTrackingEnabled, false);
      expect(config.performanceThreshold, 200.0);
      expect(config.tracingEnabledForUsers, ['user1', 'user2']);
      expect(config.maxLocalEntries, 500);
      expect(config.syncIntervalSeconds, 600);
    });

    group('getLevelForFeature', () {
      test('should return NONE when disabled', () {
        const config = LogConfig(enabled: false);
        
        expect(config.getLevelForFeature('books'), LogLevel.none);
        expect(config.getLevelForFeature('cart'), LogLevel.none);
        expect(config.getLevelForFeature(null), LogLevel.none);
      });

      test('should return globalLevel when feature is null', () {
        const config = LogConfig(globalLevel: LogLevel.debug);
        
        expect(config.getLevelForFeature(null), LogLevel.debug);
      });

      test('should return feature-specific level when available', () {
        final config = LogConfig(
          globalLevel: LogLevel.info,
          featureLevels: {
            'books': LogLevel.debug,
            'cart': LogLevel.trace,
          },
        );
        
        expect(config.getLevelForFeature('books'), LogLevel.debug);
        expect(config.getLevelForFeature('cart'), LogLevel.trace);
      });

      test('should return globalLevel when feature not in featureLevels', () {
        final config = LogConfig(
          globalLevel: LogLevel.info,
          featureLevels: {'books': LogLevel.debug},
        );
        
        expect(config.getLevelForFeature('cart'), LogLevel.info);
        expect(config.getLevelForFeature('favorites'), LogLevel.info);
      });
    });

    group('isTracingEnabledForUser', () {
      test('should return false when disabled', () {
        const config = LogConfig(
          enabled: false,
          tracingEnabledForUsers: ['user1'],
        );
        
        expect(config.isTracingEnabledForUser('user1'), false);
        expect(config.isTracingEnabledForUser('user2'), false);
      });

      test('should return true for all users when list is empty', () {
        const config = LogConfig(tracingEnabledForUsers: []);
        
        expect(config.isTracingEnabledForUser('user1'), true);
        expect(config.isTracingEnabledForUser('user2'), true);
        expect(config.isTracingEnabledForUser(null), true);
      });

      test('should return true only for users in the list', () {
        const config = LogConfig(
          tracingEnabledForUsers: ['user1', 'user2'],
        );
        
        expect(config.isTracingEnabledForUser('user1'), true);
        expect(config.isTracingEnabledForUser('user2'), true);
        expect(config.isTracingEnabledForUser('user3'), false);
      });

      test('should return false for null userId when list is not empty', () {
        const config = LogConfig(
          tracingEnabledForUsers: ['user1'],
        );
        
        expect(config.isTracingEnabledForUser(null), false);
      });
    });

    test('should support copyWith', () {
      const original = LogConfig(
        enabled: true,
        globalLevel: LogLevel.info,
      );

      final copied = original.copyWith(
        globalLevel: LogLevel.debug,
        performanceThreshold: 200.0,
      );

      expect(copied.enabled, true);
      expect(copied.globalLevel, LogLevel.debug);
      expect(copied.performanceThreshold, 200.0);
      expect(copied.syncIntervalSeconds, 300); // Original value
    });

    test('should support equality', () {
      const config1 = LogConfig(globalLevel: LogLevel.info);
      const config2 = LogConfig(globalLevel: LogLevel.info);
      const config3 = LogConfig(globalLevel: LogLevel.debug);

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });
}
