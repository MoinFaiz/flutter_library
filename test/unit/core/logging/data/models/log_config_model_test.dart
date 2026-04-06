import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/logging/data/models/log_config_model.dart';

void main() {
  group('LogConfigModel', () {
    final testJson = {
      'enabled': true,
      'global_level': 'debug',
      'feature_levels': {'feature1': 'trace', 'feature2': 'error'},
      'remote_logging_enabled': true,
      'local_logging_enabled': true,
      'performance_tracking_enabled': true,
      'audit_tracking_enabled': true,
      'performance_threshold': 250.5,
      'tracing_enabled_for_users': ['user1', 'user2'],
      'max_local_entries': 500,
      'sync_interval_seconds': 120,
    };

    group('fromJson', () {
      test('should create model from json with all fields', () {
        final model = LogConfigModel.fromJson(testJson);

        expect(model.enabled, isTrue);
        expect(model.globalLevel, equals('debug'));
        expect(model.featureLevels, equals({'feature1': 'trace', 'feature2': 'error'}));
        expect(model.remoteLoggingEnabled, isTrue);
        expect(model.localLoggingEnabled, isTrue);
        expect(model.performanceTrackingEnabled, isTrue);
        expect(model.auditTrackingEnabled, isTrue);
        expect(model.performanceThreshold, equals(250.5));
        expect(model.tracingEnabledForUsers, equals(['user1', 'user2']));
        expect(model.maxLocalEntries, equals(500));
        expect(model.syncIntervalSeconds, equals(120));
      });

      test('should use default values for missing fields', () {
        final model = LogConfigModel.fromJson({});

        expect(model.enabled, isTrue);
        expect(model.globalLevel, equals('info'));
        expect(model.featureLevels, isEmpty);
        expect(model.remoteLoggingEnabled, isTrue);
        expect(model.localLoggingEnabled, isTrue);
        expect(model.performanceTrackingEnabled, isTrue);
        expect(model.auditTrackingEnabled, isTrue);
        expect(model.performanceThreshold, equals(100.0));
        expect(model.tracingEnabledForUsers, isEmpty);
        expect(model.maxLocalEntries, equals(1000));
        expect(model.syncIntervalSeconds, equals(300));
      });

      test('should handle partial json with some defaults', () {
        final partialJson = {
          'enabled': false,
          'global_level': 'error',
          'performance_threshold': 500,
        };

        final model = LogConfigModel.fromJson(partialJson);

        expect(model.enabled, isFalse);
        expect(model.globalLevel, equals('error'));
        expect(model.performanceThreshold, equals(500.0));
        expect(model.remoteLoggingEnabled, isTrue); // default
        expect(model.maxLocalEntries, equals(1000)); // default
      });

      test('should handle integer performance threshold', () {
        final json = {
          ...testJson,
          'performance_threshold': 200, // integer
        };

        final model = LogConfigModel.fromJson(json);
        expect(model.performanceThreshold, equals(200.0));
      });

      test('should handle empty feature levels', () {
        final json = {
          ...testJson,
          'feature_levels': {},
        };

        final model = LogConfigModel.fromJson(json);
        expect(model.featureLevels, isEmpty);
      });

      test('should handle empty tracing users list', () {
        final json = {
          ...testJson,
          'tracing_enabled_for_users': [],
        };

        final model = LogConfigModel.fromJson(json);
        expect(model.tracingEnabledForUsers, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert model to json with all fields', () {
        final model = LogConfigModel(
          enabled: true,
          globalLevel: 'debug',
          featureLevels: {'feature1': 'trace', 'feature2': 'error'},
          remoteLoggingEnabled: true,
          localLoggingEnabled: true,
          performanceTrackingEnabled: true,
          auditTrackingEnabled: true,
          performanceThreshold: 250.5,
          tracingEnabledForUsers: ['user1', 'user2'],
          maxLocalEntries: 500,
          syncIntervalSeconds: 120,
        );

        final json = model.toJson();

        expect(json['enabled'], isTrue);
        expect(json['global_level'], equals('debug'));
        expect(json['feature_levels'], equals({'feature1': 'trace', 'feature2': 'error'}));
        expect(json['remote_logging_enabled'], isTrue);
        expect(json['local_logging_enabled'], isTrue);
        expect(json['performance_tracking_enabled'], isTrue);
        expect(json['audit_tracking_enabled'], isTrue);
        expect(json['performance_threshold'], equals(250.5));
        expect(json['tracing_enabled_for_users'], equals(['user1', 'user2']));
        expect(json['max_local_entries'], equals(500));
        expect(json['sync_interval_seconds'], equals(120));
      });

      test('should include all fields even when empty', () {
        final model = LogConfigModel(
          enabled: false,
          globalLevel: 'none',
          featureLevels: {},
          remoteLoggingEnabled: false,
          localLoggingEnabled: false,
          performanceTrackingEnabled: false,
          auditTrackingEnabled: false,
          performanceThreshold: 0.0,
          tracingEnabledForUsers: [],
          maxLocalEntries: 0,
          syncIntervalSeconds: 0,
        );

        final json = model.toJson();

        expect(json.containsKey('enabled'), isTrue);
        expect(json.containsKey('feature_levels'), isTrue);
        expect(json.containsKey('tracing_enabled_for_users'), isTrue);
        expect(json['enabled'], isFalse);
        expect(json['feature_levels'], isEmpty);
        expect(json['tracing_enabled_for_users'], isEmpty);
      });
    });

    group('round-trip conversions', () {
      test('should maintain data through json -> model -> json', () {
        final model = LogConfigModel.fromJson(testJson);
        final json = model.toJson();

        expect(json['enabled'], equals(testJson['enabled']));
        expect(json['global_level'], equals(testJson['global_level']));
        expect(json['feature_levels'], equals(testJson['feature_levels']));
        expect(json['remote_logging_enabled'], equals(testJson['remote_logging_enabled']));
        expect(json['local_logging_enabled'], equals(testJson['local_logging_enabled']));
        expect(json['performance_tracking_enabled'], equals(testJson['performance_tracking_enabled']));
        expect(json['audit_tracking_enabled'], equals(testJson['audit_tracking_enabled']));
        expect(json['performance_threshold'], equals(testJson['performance_threshold']));
        expect(json['tracing_enabled_for_users'], equals(testJson['tracing_enabled_for_users']));
        expect(json['max_local_entries'], equals(testJson['max_local_entries']));
        expect(json['sync_interval_seconds'], equals(testJson['sync_interval_seconds']));
      });

      test('should maintain data with default values', () {
        final model = LogConfigModel.fromJson({});
        final json = model.toJson();

        final modelAgain = LogConfigModel.fromJson(json);

        expect(modelAgain.enabled, equals(model.enabled));
        expect(modelAgain.globalLevel, equals(model.globalLevel));
        expect(modelAgain.performanceThreshold, equals(model.performanceThreshold));
        expect(modelAgain.maxLocalEntries, equals(model.maxLocalEntries));
      });
    });

    group('configuration scenarios', () {
      test('should support completely disabled configuration', () {
        final json = {
          'enabled': false,
          'global_level': 'none',
          'remote_logging_enabled': false,
          'local_logging_enabled': false,
          'performance_tracking_enabled': false,
          'audit_tracking_enabled': false,
        };

        final model = LogConfigModel.fromJson(json);

        expect(model.enabled, isFalse);
        expect(model.globalLevel, equals('none'));
        expect(model.remoteLoggingEnabled, isFalse);
        expect(model.localLoggingEnabled, isFalse);
        expect(model.performanceTrackingEnabled, isFalse);
        expect(model.auditTrackingEnabled, isFalse);
      });

      test('should support production configuration', () {
        final json = {
          'enabled': true,
          'global_level': 'error',
          'remote_logging_enabled': true,
          'local_logging_enabled': false,
          'performance_threshold': 1000.0,
          'max_local_entries': 100,
          'sync_interval_seconds': 60,
        };

        final model = LogConfigModel.fromJson(json);

        expect(model.enabled, isTrue);
        expect(model.globalLevel, equals('error'));
        expect(model.remoteLoggingEnabled, isTrue);
        expect(model.localLoggingEnabled, isFalse);
      });

      test('should support development configuration', () {
        final json = {
          'enabled': true,
          'global_level': 'trace',
          'remote_logging_enabled': false,
          'local_logging_enabled': true,
          'performance_tracking_enabled': true,
          'audit_tracking_enabled': true,
        };

        final model = LogConfigModel.fromJson(json);

        expect(model.enabled, isTrue);
        expect(model.globalLevel, equals('trace'));
        expect(model.localLoggingEnabled, isTrue);
        expect(model.performanceTrackingEnabled, isTrue);
      });

      test('should support feature-specific log levels', () {
        final json = {
          'global_level': 'info',
          'feature_levels': {
            'authentication': 'trace',
            'payment': 'debug',
            'analytics': 'warning',
          },
        };

        final model = LogConfigModel.fromJson(json);

        expect(model.globalLevel, equals('info'));
        expect(model.featureLevels['authentication'], equals('trace'));
        expect(model.featureLevels['payment'], equals('debug'));
        expect(model.featureLevels['analytics'], equals('warning'));
      });

      test('should support user-specific tracing', () {
        final json = {
          'tracing_enabled_for_users': ['test-user-1', 'test-user-2', 'admin'],
        };

        final model = LogConfigModel.fromJson(json);

        expect(model.tracingEnabledForUsers, hasLength(3));
        expect(model.tracingEnabledForUsers, contains('test-user-1'));
        expect(model.tracingEnabledForUsers, contains('admin'));
      });
    });
  });
}
