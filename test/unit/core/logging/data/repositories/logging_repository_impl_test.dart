import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/core/logging/data/repositories/logging_repository_impl.dart';
import 'package:flutter_library/core/logging/data/datasources/logging_local_data_source.dart';
import 'package:flutter_library/core/logging/data/datasources/logging_remote_data_source.dart';
import 'package:flutter_library/core/logging/data/models/log_config_model.dart';
import 'package:flutter_library/core/logging/data/models/log_entry_model.dart';
import 'package:flutter_library/core/logging/data/models/performance_metric_model.dart';
import 'package:flutter_library/core/logging/data/models/audit_event_model.dart';
import 'package:flutter_library/core/logging/domain/entities/log_entry.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_library/core/logging/domain/entities/performance_metric.dart';
import 'package:flutter_library/core/logging/domain/entities/audit_event.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockLoggingRemoteDataSource extends Mock
    implements LoggingRemoteDataSource {}

class MockLoggingLocalDataSource extends Mock
    implements LoggingLocalDataSource {}

class FakeLogConfigModel extends Fake implements LogConfigModel {}

class FakeLogEntryModel extends Fake implements LogEntryModel {}

class FakePerformanceMetricModel extends Fake implements PerformanceMetricModel {}

class FakeAuditEventModel extends Fake implements AuditEventModel {}

void main() {
  late LoggingRepositoryImpl repository;
  late MockLoggingRemoteDataSource mockRemoteDataSource;
  late MockLoggingLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeLogConfigModel());
    registerFallbackValue(FakeLogEntryModel());
    registerFallbackValue(FakePerformanceMetricModel());
    registerFallbackValue(FakeAuditEventModel());
  });

  setUp(() {
    mockRemoteDataSource = MockLoggingRemoteDataSource();
    mockLocalDataSource = MockLoggingLocalDataSource();
    repository = LoggingRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('LoggingRepositoryImpl', () {
    final testConfigModel = LogConfigModel(
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

    final testLogEntry = LogEntry(
      id: 'log-1',
      timestamp: DateTime.parse('2024-01-01T12:00:00.000'),
      level: LogLevel.info,
      message: 'Test log',
    );

    final testPerformanceMetric = PerformanceMetric(
      id: 'perf-1',
      operation: 'test-op',
      startTime: DateTime.parse('2024-01-01T12:00:00.000'),
      endTime: DateTime.parse('2024-01-01T12:00:01.000'),
      durationMs: 1000.0,
      success: true,
    );

    final testAuditEvent = AuditEvent(
      id: 'audit-1',
      timestamp: DateTime.parse('2024-01-01T12:00:00.000'),
      feature: 'test',
      action: 'test-action',
      success: true,
    );

    group('getConfig', () {
      test('should return cached config when available', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedConfig())
            .thenAnswer((_) async => testConfigModel);

        // Act
        final result = await repository.getConfig();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should return config'),
          (config) {
            expect(config.enabled, isTrue);
            expect(config.globalLevel, equals(LogLevel.info));
          },
        );
        verify(() => mockLocalDataSource.getCachedConfig()).called(1);
      });

      test('should return default config when no cache', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedConfig())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getConfig();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should return default config'),
          (config) {
            expect(config.enabled, isTrue); // Default config
          },
        );
      });

      test('should return default config on exception', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedConfig())
            .thenThrow(Exception('Error'));

        // Act
        final result = await repository.getConfig();

        // Assert
        expect(result.isRight(), isTrue);
      });
    });

    group('fetchRemoteConfig', () {
      test('should fetch, cache and return remote config', () async {
        // Arrange
        when(() => mockRemoteDataSource.fetchConfig())
            .thenAnswer((_) async => testConfigModel);
        when(() => mockLocalDataSource.cacheConfig(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.fetchRemoteConfig();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should return config'),
          (config) {
            expect(config.enabled, isTrue);
            expect(config.globalLevel, equals(LogLevel.info));
            expect(config.featureLevels['test'], equals(LogLevel.debug));
          },
        );
        verify(() => mockRemoteDataSource.fetchConfig()).called(1);
        verify(() => mockLocalDataSource.cacheConfig(testConfigModel)).called(1);
      });

      test('should return ServerFailure on ServerException', () async {
        // Arrange
        when(() => mockRemoteDataSource.fetchConfig())
            .thenThrow(ServerException('Server error'));

        // Act
        final result = await repository.fetchRemoteConfig();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect((failure as ServerFailure).message, contains('Server error'));
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should return cached config on generic exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.fetchConfig())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedConfig())
            .thenAnswer((_) async => testConfigModel);

        // Act
        final result = await repository.fetchRemoteConfig();

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.getCachedConfig()).called(1);
      });

      test('should return default config when fetch fails and no cache',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.fetchConfig())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedConfig())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.fetchRemoteConfig();

        // Assert
        expect(result.isRight(), isTrue);
      });
    });

    group('saveLogEntry', () {
      test('should save log entry successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.saveLogEntry(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedConfig())
            .thenAnswer((_) async => testConfigModel);
        when(() => mockLocalDataSource.rotateLogEntries(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.saveLogEntry(testLogEntry);

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.saveLogEntry(any())).called(1);
        verify(() => mockLocalDataSource.rotateLogEntries(1000)).called(1);
      });

      test('should save without rotation when no config', () async {
        // Arrange
        when(() => mockLocalDataSource.saveLogEntry(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedConfig())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.saveLogEntry(testLogEntry);

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.saveLogEntry(any())).called(1);
        verifyNever(() => mockLocalDataSource.rotateLogEntries(any()));
      });

      test('should return CacheFailure on CacheException', () async {
        // Arrange
        when(() => mockLocalDataSource.saveLogEntry(any()))
            .thenThrow(CacheException('Cache error'));

        // Act
        final result = await repository.saveLogEntry(testLogEntry);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<CacheFailure>());
          },
          (_) => fail('Should return failure'),
        );
      });
    });

    group('getLocalLogs', () {
      test('should return logs successfully', () async {
        // Arrange
        final models = [
          LogEntryModel.fromEntity(testLogEntry),
          LogEntryModel.fromEntity(testLogEntry),
        ];
        when(() => mockLocalDataSource.getLocalLogs(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => models);

        // Act
        final result = await repository.getLocalLogs();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should return logs'),
          (logs) {
            expect(logs.length, equals(2));
          },
        );
      });

      test('should pass limit and since parameters', () async {
        // Arrange
        when(() => mockLocalDataSource.getLocalLogs(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => []);

        final since = DateTime.parse('2024-01-01T12:00:00.000');

        // Act
        await repository.getLocalLogs(limit: 10, since: since);

        // Assert
        verify(() => mockLocalDataSource.getLocalLogs(
              limit: 10,
              since: since,
            )).called(1);
      });

      test('should return CacheFailure on CacheException', () async {
        // Arrange
        when(() => mockLocalDataSource.getLocalLogs(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenThrow(CacheException('Cache error'));

        // Act
        final result = await repository.getLocalLogs();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('syncLogsToServer', () {
      test('should sync logs successfully', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendLogs(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.syncLogsToServer([testLogEntry]);

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockRemoteDataSource.sendLogs(any())).called(1);
      });

      test('should return ServerFailure on ServerException', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendLogs(any()))
            .thenThrow(ServerException('Server error'));

        // Act
        final result = await repository.syncLogsToServer([testLogEntry]);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should return NetworkFailure on NetworkException', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendLogs(any()))
            .thenThrow(NetworkException('Network error'));

        // Act
        final result = await repository.syncLogsToServer([testLogEntry]);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('clearLocalLogs', () {
      test('should clear logs successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.clearLogs())
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.clearLocalLogs();

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.clearLogs()).called(1);
      });

      test('should return CacheFailure on CacheException', () async {
        // Arrange
        when(() => mockLocalDataSource.clearLogs())
            .thenThrow(CacheException('Cache error'));

        // Act
        final result = await repository.clearLocalLogs();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('savePerformanceMetric', () {
      test('should save performance metric successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.savePerformanceMetric(any()))
            .thenAnswer((_) async => {});

        // Act
        final result =
            await repository.savePerformanceMetric(testPerformanceMetric);

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.savePerformanceMetric(any())).called(1);
      });

      test('should return CacheFailure on CacheException', () async {
        // Arrange
        when(() => mockLocalDataSource.savePerformanceMetric(any()))
            .thenThrow(CacheException('Cache error'));

        // Act
        final result =
            await repository.savePerformanceMetric(testPerformanceMetric);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('getPerformanceMetrics', () {
      test('should return metrics successfully', () async {
        // Arrange
        final models = [
          PerformanceMetricModel.fromEntity(testPerformanceMetric),
          PerformanceMetricModel.fromEntity(testPerformanceMetric),
        ];
        when(() => mockLocalDataSource.getPerformanceMetrics(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => models);

        // Act
        final result = await repository.getPerformanceMetrics();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should return metrics'),
          (metrics) {
            expect(metrics.length, equals(2));
          },
        );
      });

      test('should pass limit and since parameters', () async {
        // Arrange
        when(() => mockLocalDataSource.getPerformanceMetrics(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => []);

        final since = DateTime.parse('2024-01-01T12:00:00.000');

        // Act
        await repository.getPerformanceMetrics(limit: 5, since: since);

        // Assert
        verify(() => mockLocalDataSource.getPerformanceMetrics(
              limit: 5,
              since: since,
            )).called(1);
      });

      test('should return CacheFailure on CacheException', () async {
        // Arrange
        when(() => mockLocalDataSource.getPerformanceMetrics(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenThrow(CacheException('Cache error'));

        // Act
        final result = await repository.getPerformanceMetrics();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('saveAuditEvent', () {
      test('should save audit event successfully', () async {
        // Arrange
        when(() => mockLocalDataSource.saveAuditEvent(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.saveAuditEvent(testAuditEvent);

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.saveAuditEvent(any())).called(1);
      });

      test('should return CacheFailure on CacheException', () async {
        // Arrange
        when(() => mockLocalDataSource.saveAuditEvent(any()))
            .thenThrow(CacheException('Cache error'));

        // Act
        final result = await repository.saveAuditEvent(testAuditEvent);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('getAuditEvents', () {
      test('should return events successfully', () async {
        // Arrange
        final models = [
          AuditEventModel.fromEntity(testAuditEvent),
          AuditEventModel.fromEntity(testAuditEvent),
        ];
        when(() => mockLocalDataSource.getAuditEvents(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => models);

        // Act
        final result = await repository.getAuditEvents();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should return events'),
          (events) {
            expect(events.length, equals(2));
          },
        );
      });

      test('should pass limit and since parameters', () async {
        // Arrange
        when(() => mockLocalDataSource.getAuditEvents(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenAnswer((_) async => []);

        final since = DateTime.parse('2024-01-01T12:00:00.000');

        // Act
        await repository.getAuditEvents(limit: 3, since: since);

        // Assert
        verify(() => mockLocalDataSource.getAuditEvents(
              limit: 3,
              since: since,
            )).called(1);
      });

      test('should return CacheFailure on CacheException', () async {
        // Arrange
        when(() => mockLocalDataSource.getAuditEvents(
              limit: any(named: 'limit'),
              since: any(named: 'since'),
            )).thenThrow(CacheException('Cache error'));

        // Act
        final result = await repository.getAuditEvents();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('syncAuditEventsToServer', () {
      test('should sync events successfully', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendAuditEvents(any()))
            .thenAnswer((_) async => {});

        // Act
        final result =
            await repository.syncAuditEventsToServer([testAuditEvent]);

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockRemoteDataSource.sendAuditEvents(any())).called(1);
      });

      test('should return ServerFailure on ServerException', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendAuditEvents(any()))
            .thenThrow(ServerException('Server error'));

        // Act
        final result =
            await repository.syncAuditEventsToServer([testAuditEvent]);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should return failure'),
        );
      });

      test('should return NetworkFailure on NetworkException', () async {
        // Arrange
        when(() => mockRemoteDataSource.sendAuditEvents(any()))
            .thenThrow(NetworkException('Network error'));

        // Act
        final result =
            await repository.syncAuditEventsToServer([testAuditEvent]);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });
  });
}
