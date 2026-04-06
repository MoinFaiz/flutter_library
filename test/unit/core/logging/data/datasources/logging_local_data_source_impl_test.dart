import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/core/logging/data/datasources/logging_local_data_source_impl.dart';
import 'package:flutter_library/core/logging/data/models/log_config_model.dart';
import 'package:flutter_library/core/logging/data/models/log_entry_model.dart';
import 'package:flutter_library/core/logging/data/models/performance_metric_model.dart';
import 'package:flutter_library/core/logging/data/models/audit_event_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late LoggingLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = LoggingLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('LoggingLocalDataSourceImpl', () {
    final testConfig = LogConfigModel(
      enabled: true,
      globalLevel: 'info',
      featureLevels: {'test': 'debug'},
      remoteLoggingEnabled: true,
      localLoggingEnabled: true,
      performanceTrackingEnabled: true,
      auditTrackingEnabled: true,
      performanceThreshold: 100.0,
      tracingEnabledForUsers: ['user1'],
      maxLocalEntries: 1000,
      syncIntervalSeconds: 300,
    );

    final testLogEntry = LogEntryModel(
      id: 'log-1',
      timestamp: '2024-01-01T12:00:00.000',
      level: 'info',
      message: 'Test log',
      feature: 'test',
    );

    final testPerformanceMetric = PerformanceMetricModel(
      id: 'perf-1',
      operation: 'test-op',
      startTime: '2024-01-01T12:00:00.000',
      endTime: '2024-01-01T12:00:01.000',
      durationMs: 1000.0,
      success: true,
    );

    final testAuditEvent = AuditEventModel(
      id: 'audit-1',
      timestamp: '2024-01-01T12:00:00.000',
      feature: 'test',
      action: 'test-action',
      success: true,
    );

    group('getCachedConfig', () {
      test('should return config when cached', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('logging_config'))
            .thenReturn(json.encode(testConfig.toJson()));

        // Act
        final result = await dataSource.getCachedConfig();

        // Assert
        expect(result, isNotNull);
        expect(result?.enabled, equals(true));
        expect(result?.globalLevel, equals('info'));
        verify(() => mockSharedPreferences.getString('logging_config')).called(1);
      });

      test('should return null when no cached config', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('logging_config'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedConfig();

        // Assert
        expect(result, isNull);
        verify(() => mockSharedPreferences.getString('logging_config')).called(1);
      });
    });

    group('cacheConfig', () {
      test('should cache config successfully', () async {
        // Arrange
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheConfig(testConfig);

        // Assert
        verify(() => mockSharedPreferences.setString(
              'logging_config',
              any(),
            )).called(1);
      });
    });

    group('saveLogEntry', () {
      test('should save log entry to empty list', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(null);
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.saveLogEntry(testLogEntry);

        // Assert
        verify(() => mockSharedPreferences.getString('log_entries')).called(1);
        verify(() => mockSharedPreferences.setString('log_entries', any()))
            .called(1);
      });

      test('should append log entry to existing list', () async {
        // Arrange
        final existingLogs = [testLogEntry.toJson()];
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(json.encode(existingLogs));
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        final newEntry = LogEntryModel(
          id: 'log-2',
          timestamp: '2024-01-01T12:01:00.000',
          level: 'debug',
          message: 'Another log',
        );

        // Act
        await dataSource.saveLogEntry(newEntry);

        // Assert
        verify(() => mockSharedPreferences.getString('log_entries')).called(1);
        final captured = verify(() =>
                mockSharedPreferences.setString('log_entries', captureAny()))
            .captured;
        final savedJson = json.decode(captured.first as String) as List;
        expect(savedJson.length, equals(2));
      });
    });

    group('getLocalLogs', () {
      test('should return empty list when no logs cached', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getLocalLogs();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all logs when no filters', () async {
        // Arrange
        final logs = [testLogEntry.toJson(), testLogEntry.toJson()];
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(json.encode(logs));

        // Act
        final result = await dataSource.getLocalLogs();

        // Assert
        expect(result.length, equals(2));
      });

      test('should filter logs by since date', () async {
        // Arrange
        final oldLog = LogEntryModel(
          id: 'old',
          timestamp: '2024-01-01T10:00:00.000',
          level: 'info',
          message: 'Old',
        );
        final newLog = LogEntryModel(
          id: 'new',
          timestamp: '2024-01-01T14:00:00.000',
          level: 'info',
          message: 'New',
        );
        final logs = [oldLog.toJson(), newLog.toJson()];
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(json.encode(logs));

        // Act
        final result = await dataSource.getLocalLogs(
          since: DateTime.parse('2024-01-01T12:00:00.000'),
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('new'));
      });

      test('should limit number of logs returned', () async {
        // Arrange
        final logs = List.generate(
          10,
          (i) => LogEntryModel(
            id: 'log-$i',
            timestamp: '2024-01-01T12:00:00.000',
            level: 'info',
            message: 'Log $i',
          ).toJson(),
        );
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(json.encode(logs));

        // Act
        final result = await dataSource.getLocalLogs(limit: 5);

        // Assert
        expect(result.length, equals(5));
      });

      test('should apply both since filter and limit', () async {
        // Arrange
        final logs = List.generate(
          10,
          (i) => LogEntryModel(
            id: 'log-$i',
            timestamp: '2024-01-01T${12 + i}:00:00.000',
            level: 'info',
            message: 'Log $i',
          ).toJson(),
        );
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(json.encode(logs));

        // Act
        final result = await dataSource.getLocalLogs(
          since: DateTime.parse('2024-01-01T15:00:00.000'),
          limit: 2,
        );

        // Assert
        expect(result.length, equals(2));
      });
    });

    group('clearLogs', () {
      test('should remove logs from storage', () async {
        // Arrange
        when(() => mockSharedPreferences.remove('log_entries'))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.clearLogs();

        // Assert
        verify(() => mockSharedPreferences.remove('log_entries')).called(1);
      });
    });

    group('savePerformanceMetric', () {
      test('should save performance metric to empty list', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('performance_metrics'))
            .thenReturn(null);
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.savePerformanceMetric(testPerformanceMetric);

        // Assert
        verify(() => mockSharedPreferences.setString('performance_metrics', any()))
            .called(1);
      });

      test('should append metric to existing list', () async {
        // Arrange
        final existingMetrics = [testPerformanceMetric.toJson()];
        when(() => mockSharedPreferences.getString('performance_metrics'))
            .thenReturn(json.encode(existingMetrics));
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.savePerformanceMetric(testPerformanceMetric);

        // Assert
        final captured = verify(() => mockSharedPreferences.setString(
                  'performance_metrics',
                  captureAny(),
                ))
            .captured;
        final savedJson = json.decode(captured.first as String) as List;
        expect(savedJson.length, equals(2));
      });
    });

    group('getPerformanceMetrics', () {
      test('should return empty list when no metrics cached', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('performance_metrics'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getPerformanceMetrics();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all metrics when no filters', () async {
        // Arrange
        final metrics = [
          testPerformanceMetric.toJson(),
          testPerformanceMetric.toJson()
        ];
        when(() => mockSharedPreferences.getString('performance_metrics'))
            .thenReturn(json.encode(metrics));

        // Act
        final result = await dataSource.getPerformanceMetrics();

        // Assert
        expect(result.length, equals(2));
      });

      test('should filter metrics by since date', () async {
        // Arrange
        final oldMetric = PerformanceMetricModel(
          id: 'old',
          operation: 'op',
          startTime: '2024-01-01T10:00:00.000',
          endTime: '2024-01-01T10:00:01.000',
          durationMs: 1000,
          success: true,
        );
        final newMetric = PerformanceMetricModel(
          id: 'new',
          operation: 'op',
          startTime: '2024-01-01T14:00:00.000',
          endTime: '2024-01-01T14:00:01.000',
          durationMs: 1000,
          success: true,
        );
        final metrics = [oldMetric.toJson(), newMetric.toJson()];
        when(() => mockSharedPreferences.getString('performance_metrics'))
            .thenReturn(json.encode(metrics));

        // Act
        final result = await dataSource.getPerformanceMetrics(
          since: DateTime.parse('2024-01-01T12:00:00.000'),
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('new'));
      });

      test('should limit number of metrics returned', () async {
        // Arrange
        final metrics = List.generate(
          10,
          (i) => PerformanceMetricModel(
            id: 'metric-$i',
            operation: 'op',
            startTime: '2024-01-01T12:00:00.000',
            endTime: '2024-01-01T12:00:01.000',
            durationMs: 1000,
            success: true,
          ).toJson(),
        );
        when(() => mockSharedPreferences.getString('performance_metrics'))
            .thenReturn(json.encode(metrics));

        // Act
        final result = await dataSource.getPerformanceMetrics(limit: 3);

        // Assert
        expect(result.length, equals(3));
      });
    });

    group('saveAuditEvent', () {
      test('should save audit event to empty list', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('audit_events'))
            .thenReturn(null);
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.saveAuditEvent(testAuditEvent);

        // Assert
        verify(() => mockSharedPreferences.setString('audit_events', any()))
            .called(1);
      });

      test('should append event to existing list', () async {
        // Arrange
        final existingEvents = [testAuditEvent.toJson()];
        when(() => mockSharedPreferences.getString('audit_events'))
            .thenReturn(json.encode(existingEvents));
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.saveAuditEvent(testAuditEvent);

        // Assert
        final captured = verify(() =>
                mockSharedPreferences.setString('audit_events', captureAny()))
            .captured;
        final savedJson = json.decode(captured.first as String) as List;
        expect(savedJson.length, equals(2));
      });
    });

    group('getAuditEvents', () {
      test('should return empty list when no events cached', () async {
        // Arrange
        when(() => mockSharedPreferences.getString('audit_events'))
            .thenReturn(null);

        // Act
        final result = await dataSource.getAuditEvents();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all events when no filters', () async {
        // Arrange
        final events = [testAuditEvent.toJson(), testAuditEvent.toJson()];
        when(() => mockSharedPreferences.getString('audit_events'))
            .thenReturn(json.encode(events));

        // Act
        final result = await dataSource.getAuditEvents();

        // Assert
        expect(result.length, equals(2));
      });

      test('should filter events by since date', () async {
        // Arrange
        final oldEvent = AuditEventModel(
          id: 'old',
          timestamp: '2024-01-01T10:00:00.000',
          feature: 'test',
          action: 'action',
          success: true,
        );
        final newEvent = AuditEventModel(
          id: 'new',
          timestamp: '2024-01-01T14:00:00.000',
          feature: 'test',
          action: 'action',
          success: true,
        );
        final events = [oldEvent.toJson(), newEvent.toJson()];
        when(() => mockSharedPreferences.getString('audit_events'))
            .thenReturn(json.encode(events));

        // Act
        final result = await dataSource.getAuditEvents(
          since: DateTime.parse('2024-01-01T12:00:00.000'),
        );

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals('new'));
      });

      test('should limit number of events returned', () async {
        // Arrange
        final events = List.generate(
          10,
          (i) => AuditEventModel(
            id: 'event-$i',
            timestamp: '2024-01-01T12:00:00.000',
            feature: 'test',
            action: 'action',
            success: true,
          ).toJson(),
        );
        when(() => mockSharedPreferences.getString('audit_events'))
            .thenReturn(json.encode(events));

        // Act
        final result = await dataSource.getAuditEvents(limit: 4);

        // Assert
        expect(result.length, equals(4));
      });
    });

    group('rotateLogEntries', () {
      test('should not rotate when under limit', () async {
        // Arrange
        final logs = List.generate(
          5,
          (i) => LogEntryModel(
            id: 'log-$i',
            timestamp: '2024-01-01T12:00:00.000',
            level: 'info',
            message: 'Log $i',
          ).toJson(),
        );
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(json.encode(logs));

        // Act
        await dataSource.rotateLogEntries(10);

        // Assert
        verifyNever(() => mockSharedPreferences.setString('log_entries', any()));
      });

      test('should trim logs when over limit', () async {
        // Arrange
        final logs = List.generate(
          10,
          (i) => LogEntryModel(
            id: 'log-$i',
            timestamp: '2024-01-01T12:00:00.000',
            level: 'info',
            message: 'Log $i',
          ).toJson(),
        );
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(json.encode(logs));
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.rotateLogEntries(5);

        // Assert
        final captured = verify(() =>
                mockSharedPreferences.setString('log_entries', captureAny()))
            .captured;
        final savedJson = json.decode(captured.first as String) as List;
        expect(savedJson.length, equals(5));
        // Should keep the last 5 entries (log-5 through log-9)
        expect((savedJson.first as Map)['id'], equals('log-5'));
        expect((savedJson.last as Map)['id'], equals('log-9'));
      });

      test('should handle exactly at limit', () async {
        // Arrange
        final logs = List.generate(
          5,
          (i) => LogEntryModel(
            id: 'log-$i',
            timestamp: '2024-01-01T12:00:00.000',
            level: 'info',
            message: 'Log $i',
          ).toJson(),
        );
        when(() => mockSharedPreferences.getString('log_entries'))
            .thenReturn(json.encode(logs));

        // Act
        await dataSource.rotateLogEntries(5);

        // Assert
        verifyNever(() => mockSharedPreferences.setString('log_entries', any()));
      });
    });
  });
}
