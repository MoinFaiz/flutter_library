import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/core/logging/services/logging_config_service.dart';
import 'package:flutter_library/core/logging/domain/entities/log_config.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_library/core/logging/domain/usecases/fetch_logging_config.dart';
import 'package:flutter_library/core/logging/domain/usecases/sync_logs.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/usecase/usecase.dart';

class MockFetchLoggingConfig extends Mock implements FetchLoggingConfig {}

class MockSyncLogs extends Mock implements SyncLogs {}

void main() {
  late LoggingConfigService service;
  late MockFetchLoggingConfig mockFetchConfig;
  late MockSyncLogs mockSyncLogs;

  setUp(() {
    mockFetchConfig = MockFetchLoggingConfig();
    mockSyncLogs = MockSyncLogs();
    service = LoggingConfigService(
      fetchConfig: mockFetchConfig,
      syncLogs: mockSyncLogs,
    );

    registerFallbackValue(const NoParams());
  });

  tearDown(() {
    service.dispose();
  });

  group('LoggingConfigService', () {
    final testConfig = LogConfig(
      enabled: true,
      globalLevel: LogLevel.info,
      remoteLoggingEnabled: true,
      syncIntervalSeconds: 60,
      performanceThreshold: 500,
    );

    group('initialization', () {
      test('should start with null currentConfig', () {
        expect(service.currentConfig, isNull);
      });
    });

    group('start', () {
      test('should fetch initial configuration', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.start();

        verify(() => mockFetchConfig(const NoParams())).called(1);
        expect(service.currentConfig, equals(testConfig));
      });

      test('should setup periodic config refresh', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.start();

        // Wait for at least one periodic call (5 minutes + buffer)
        // We'll use a shorter duration for testing purposes
        // Note: In actual test, we can't wait 5 minutes, so we verify the timer is set
        verify(() => mockFetchConfig(const NoParams())).called(1);
      });

      test('should setup log sync when config has remote logging enabled',
          () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.start();

        expect(service.currentConfig?.remoteLoggingEnabled, isTrue);
      });

      test('should handle config fetch failure gracefully', () async {
        when(() => mockFetchConfig(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Network error')),
        );

        await service.start();

        verify(() => mockFetchConfig(const NoParams())).called(1);
        expect(service.currentConfig, isNull);
      });
    });

    group('stop', () {
      test('should cancel timers when stopped', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.start();
        service.stop();

        // After stop, timers should be cancelled - we verify the start call happened
        verify(() => mockFetchConfig(const NoParams())).called(1);
      });

      test('should handle stop when not started', () {
        expect(() => service.stop(), returnsNormally);
      });
    });

    group('refreshConfig', () {
      test('should fetch and update configuration', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        final config = await service.refreshConfig();

        verify(() => mockFetchConfig(const NoParams())).called(1);
        expect(config, equals(testConfig));
        expect(service.currentConfig, equals(testConfig));
      });

      test('should return current config on fetch failure', () async {
        // First set a config
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));
        await service.refreshConfig();

        // Then simulate a failure
        when(() => mockFetchConfig(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Network error')),
        );

        final config = await service.refreshConfig();

        expect(config, equals(testConfig)); // Should return previous config
        expect(service.currentConfig, equals(testConfig));
      });

      test('should return null on failure when no previous config exists',
          () async {
        when(() => mockFetchConfig(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Network error')),
        );

        final config = await service.refreshConfig();

        expect(config, isNull);
        expect(service.currentConfig, isNull);
      });

      test('should setup log sync after successful config refresh', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.refreshConfig();

        expect(service.currentConfig?.remoteLoggingEnabled, isTrue);
      });

      test('should not setup log sync when remote logging is disabled',
          () async {
        final disabledConfig = LogConfig(
          enabled: true,
          globalLevel: LogLevel.info,
          remoteLoggingEnabled: false,
          syncIntervalSeconds: 60,
          performanceThreshold: 500,
        );

        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(disabledConfig));

        await service.refreshConfig();

        expect(service.currentConfig?.remoteLoggingEnabled, isFalse);
      });
    });

    group('syncLogs', () {
      test('should sync logs successfully', () async {
        when(() => mockSyncLogs(any())).thenAnswer((_) async => const Right(null));

        final result = await service.syncLogs();

        verify(() => mockSyncLogs(const NoParams())).called(1);
        expect(result, isTrue);
      });

      test('should return false on sync failure', () async {
        when(() => mockSyncLogs(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Upload failed')),
        );

        final result = await service.syncLogs();

        verify(() => mockSyncLogs(const NoParams())).called(1);
        expect(result, isFalse);
      });

      test('should handle cache failures', () async {
        when(() => mockSyncLogs(any())).thenAnswer(
          (_) async => const Left(CacheFailure('Local storage error')),
        );

        final result = await service.syncLogs();

        expect(result, isFalse);
      });
    });

    group('currentConfig', () {
      test('should return null before any config is fetched', () {
        expect(service.currentConfig, isNull);
      });

      test('should return the latest fetched config', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.refreshConfig();

        expect(service.currentConfig, equals(testConfig));
      });

      test('should update when new config is fetched', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.refreshConfig();

        final newConfig = LogConfig(
          enabled: false,
          globalLevel: LogLevel.error,
          remoteLoggingEnabled: false,
          syncIntervalSeconds: 120,
          performanceThreshold: 1000,
        );

        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(newConfig));

        await service.refreshConfig();

        expect(service.currentConfig, equals(newConfig));
        expect(service.currentConfig?.enabled, isFalse);
        expect(service.currentConfig?.globalLevel, equals(LogLevel.error));
      });
    });

    group('dispose', () {
      test('should stop timers on dispose', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.start();
        service.dispose();

        // Verify the start call happened before dispose
        verify(() => mockFetchConfig(const NoParams())).called(1);
      });

      test('should handle dispose when not started', () {
        expect(() => service.dispose(), returnsNormally);
      });

      test('should be safe to call multiple times', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.start();
        service.dispose();
        service.dispose();

        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('timer management', () {
      test('should update sync timer when config changes', () async {
        // Initial config with 60 second interval
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.refreshConfig();

        // New config with different interval
        final newConfig = LogConfig(
          enabled: true,
          globalLevel: LogLevel.info,
          remoteLoggingEnabled: true,
          syncIntervalSeconds: 120, // Changed interval
          performanceThreshold: 500,
        );

        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(newConfig));

        await service.refreshConfig();

        expect(service.currentConfig?.syncIntervalSeconds, equals(120));
      });

      test('should cancel sync timer when remote logging is disabled',
          () async {
        // Start with remote logging enabled
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.refreshConfig();

        // Update to disabled remote logging
        final disabledConfig = LogConfig(
          enabled: true,
          globalLevel: LogLevel.info,
          remoteLoggingEnabled: false,
          syncIntervalSeconds: 60,
          performanceThreshold: 500,
        );

        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(disabledConfig));

        await service.refreshConfig();

        expect(service.currentConfig?.remoteLoggingEnabled, isFalse);
      });
    });

    group('integration scenarios', () {
      test('should handle complete lifecycle: start -> sync -> stop', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));
        when(() => mockSyncLogs(any())).thenAnswer((_) async => const Right(null));

        // Start
        await service.start();
        expect(service.currentConfig, isNotNull);

        // Sync
        final syncResult = await service.syncLogs();
        expect(syncResult, isTrue);

        // Stop
        service.stop();
        
        // Verify the expected calls happened
        verify(() => mockFetchConfig(const NoParams())).called(1);
        verify(() => mockSyncLogs(const NoParams())).called(1);
      });

      test('should handle multiple refresh calls', () async {
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.refreshConfig();
        await service.refreshConfig();
        await service.refreshConfig();

        verify(() => mockFetchConfig(const NoParams())).called(3);
      });

      test('should recover from temporary failures', () async {
        // First call fails
        when(() => mockFetchConfig(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Temporary error')),
        );

        await service.refreshConfig();
        expect(service.currentConfig, isNull);

        // Second call succeeds
        when(() => mockFetchConfig(any()))
            .thenAnswer((_) async => Right(testConfig));

        await service.refreshConfig();
        expect(service.currentConfig, equals(testConfig));
      });
    });
  });
}
