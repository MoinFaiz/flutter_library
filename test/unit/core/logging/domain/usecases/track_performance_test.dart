import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/logging/domain/entities/log_config.dart';
import 'package:flutter_library/core/logging/domain/entities/performance_metric.dart';
import 'package:flutter_library/core/logging/domain/repositories/logging_repository.dart';
import 'package:flutter_library/core/logging/domain/usecases/track_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggingRepository extends Mock implements LoggingRepository {}

void main() {
  late TrackPerformance useCase;
  late MockLoggingRepository mockRepository;

  setUp(() {
    mockRepository = MockLoggingRepository();
    useCase = TrackPerformance(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(PerformanceMetric(
      id: '1',
      operation: 'test',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      durationMs: 100.0,
    ));
  });

  group('TrackPerformance', () {
    final startTime = DateTime(2025, 10, 31, 10, 30, 0);
    final endTime = DateTime(2025, 10, 31, 10, 30, 0, 150);

    const tConfig = LogConfig(
      enabled: true,
      performanceTrackingEnabled: true,
      performanceThreshold: 100.0,
    );

    final tParams = TrackPerformanceParams(
      operation: 'fetch_books',
      feature: 'books',
      startTime: startTime,
      endTime: endTime,
      success: true,
    );

    test('should save performance metric when tracking is enabled and exceeds threshold', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.savePerformanceMetric(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verify(() => mockRepository.savePerformanceMetric(any())).called(1);
    });

    test('should not track when logging is disabled', () async {
      // arrange
      const disabledConfig = LogConfig(enabled: false);
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(disabledConfig));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.savePerformanceMetric(any()));
    });

    test('should not track when performance tracking is disabled', () async {
      // arrange
      const config = LogConfig(
        enabled: true,
        performanceTrackingEnabled: false,
      );
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(config));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.savePerformanceMetric(any()));
    });

    test('should not track when duration is below threshold', () async {
      // arrange
      final fastEndTime = DateTime(2025, 10, 31, 10, 30, 0, 50); // 50ms
      final params = TrackPerformanceParams(
        operation: 'fast_operation',
        startTime: startTime,
        endTime: fastEndTime,
      );
      const config = LogConfig(
        enabled: true,
        performanceTrackingEnabled: true,
        performanceThreshold: 100.0, // Threshold is 100ms
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(config));

      // act
      final result = await useCase(params);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.savePerformanceMetric(any()));
    });

    test('should calculate duration correctly', () async {
      // arrange
      PerformanceMetric? capturedMetric;

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.savePerformanceMetric(any())).thenAnswer((invocation) async {
        capturedMetric = invocation.positionalArguments[0] as PerformanceMetric;
        return const Right(null);
      });

      // act
      await useCase(tParams);

      // assert
      expect(capturedMetric?.durationMs, 150.0); // 150ms difference
    });

    test('should include metadata in metric', () async {
      // arrange
      final params = TrackPerformanceParams(
        operation: 'api_call',
        feature: 'books',
        startTime: startTime,
        endTime: endTime,
        metadata: {'endpoint': '/books', 'method': 'GET'},
      );
      PerformanceMetric? capturedMetric;

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.savePerformanceMetric(any())).thenAnswer((invocation) async {
        capturedMetric = invocation.positionalArguments[0] as PerformanceMetric;
        return const Right(null);
      });

      // act
      await useCase(params);

      // assert
      expect(capturedMetric?.metadata, {'endpoint': '/books', 'method': 'GET'});
      expect(capturedMetric?.feature, 'books');
    });

    test('should track failed operations', () async {
      // arrange
      final params = TrackPerformanceParams(
        operation: 'failed_operation',
        startTime: startTime,
        endTime: endTime,
        success: false,
      );
      PerformanceMetric? capturedMetric;

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.savePerformanceMetric(any())).thenAnswer((invocation) async {
        capturedMetric = invocation.positionalArguments[0] as PerformanceMetric;
        return const Right(null);
      });

      // act
      await useCase(params);

      // assert
      expect(capturedMetric?.success, false);
    });

    test('should return failure when config retrieval fails', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Left(CacheFailure('Cache error')));
      verifyNever(() => mockRepository.savePerformanceMetric(any()));
    });
  });
}
