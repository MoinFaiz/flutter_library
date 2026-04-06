import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/logging/domain/entities/log_config.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_library/core/logging/domain/repositories/logging_repository.dart';
import 'package:flutter_library/core/logging/domain/usecases/log_message.dart';
import 'package:flutter_library/core/logging/domain/usecases/track_audit_event.dart';
import 'package:flutter_library/core/logging/domain/usecases/track_performance.dart';
import 'package:flutter_library/core/logging/services/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLogMessage extends Mock implements LogMessage {}
class MockTrackAuditEvent extends Mock implements TrackAuditEvent {}
class MockTrackPerformance extends Mock implements TrackPerformance {}
class MockLoggingRepository extends Mock implements LoggingRepository {}

void main() {
  late AppLogger logger;
  late MockLogMessage mockLogMessage;
  late MockTrackAuditEvent mockTrackAuditEvent;
  late MockTrackPerformance mockTrackPerformance;
  late MockLoggingRepository mockRepository;

  setUp(() {
    mockLogMessage = MockLogMessage();
    mockTrackAuditEvent = MockTrackAuditEvent();
    mockTrackPerformance = MockTrackPerformance();
    mockRepository = MockLoggingRepository();

    logger = AppLogger(
      logMessage: mockLogMessage,
      trackAuditEvent: mockTrackAuditEvent,
      trackPerformance: mockTrackPerformance,
      repository: mockRepository,
    );
  });

  setUpAll(() {
    registerFallbackValue(const LogMessageParams(
      level: LogLevel.info,
      message: 'test',
    ));
    registerFallbackValue(const TrackAuditEventParams(
      feature: 'test',
      action: 'test',
    ));
    registerFallbackValue(TrackPerformanceParams(
      operation: 'test',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    ));
  });

  group('AppLogger', () {
    group('setUserId and setSessionId', () {
      test('should set user ID', () async {
        // arrange
        logger.setUserId('user123');
        when(() => mockLogMessage(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.info('Test message');

        // assert
        final captured = verify(() => mockLogMessage(captureAny())).captured;
        final params = captured.first as LogMessageParams;
        expect(params.userId, 'user123');
      });

      test('should set session ID', () async {
        // arrange
        logger.setSessionId('session456');
        when(() => mockLogMessage(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.info('Test message');

        // assert
        final captured = verify(() => mockLogMessage(captureAny())).captured;
        final params = captured.first as LogMessageParams;
        expect(params.sessionId, 'session456');
      });
    });

    group('logging methods', () {
      test('should log trace message', () async {
        // arrange
        when(() => mockLogMessage(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.trace('Trace message', feature: 'books');

        // assert
        final captured = verify(() => mockLogMessage(captureAny())).captured;
        final params = captured.first as LogMessageParams;
        expect(params.level, LogLevel.trace);
        expect(params.message, 'Trace message');
        expect(params.feature, 'books');
      });

      test('should log debug message', () async {
        // arrange
        when(() => mockLogMessage(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.debug('Debug message', feature: 'cart');

        // assert
        final captured = verify(() => mockLogMessage(captureAny())).captured;
        final params = captured.first as LogMessageParams;
        expect(params.level, LogLevel.debug);
        expect(params.message, 'Debug message');
        expect(params.feature, 'cart');
      });

      test('should log info message', () async {
        // arrange
        when(() => mockLogMessage(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.info('Info message', feature: 'favorites');

        // assert
        final captured = verify(() => mockLogMessage(captureAny())).captured;
        final params = captured.first as LogMessageParams;
        expect(params.level, LogLevel.info);
        expect(params.message, 'Info message');
        expect(params.feature, 'favorites');
      });

      test('should log warning message', () async {
        // arrange
        when(() => mockLogMessage(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.warning('Warning message', action: 'save');

        // assert
        final captured = verify(() => mockLogMessage(captureAny())).captured;
        final params = captured.first as LogMessageParams;
        expect(params.level, LogLevel.warning);
        expect(params.message, 'Warning message');
        expect(params.action, 'save');
      });

      test('should log error message with metadata', () async {
        // arrange
        when(() => mockLogMessage(any()))
            .thenAnswer((_) async => const Right(null));
        final error = Exception('Test error');

        // act
        await logger.error(
          'Error occurred',
          feature: 'books',
          error: error,
          metadata: {'key': 'value'},
        );

        // assert
        final captured = verify(() => mockLogMessage(captureAny())).captured;
        final params = captured.first as LogMessageParams;
        expect(params.level, LogLevel.error);
        expect(params.message, 'Error occurred');
        expect(params.metadata?['error'], error.toString());
        expect(params.metadata?['key'], 'value');
      });

      test('should include metadata in logs', () async {
        // arrange
        when(() => mockLogMessage(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.info(
          'Test',
          metadata: {'count': 10, 'query': 'flutter'},
        );

        // assert
        final captured = verify(() => mockLogMessage(captureAny())).captured;
        final params = captured.first as LogMessageParams;
        expect(params.metadata, {'count': 10, 'query': 'flutter'});
      });
    });

    group('audit', () {
      test('should track audit event', () async {
        // arrange
        when(() => mockTrackAuditEvent(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.audit(
          feature: 'cart',
          action: 'checkout',
          parameters: {'total': 99.99},
          success: true,
        );

        // assert
        final captured = verify(() => mockTrackAuditEvent(captureAny())).captured;
        final params = captured.first as TrackAuditEventParams;
        expect(params.feature, 'cart');
        expect(params.action, 'checkout');
        expect(params.parameters, {'total': 99.99});
        expect(params.success, true);
      });

      test('should include userId and sessionId in audit', () async {
        // arrange
        logger.setUserId('user123');
        logger.setSessionId('session456');
        when(() => mockTrackAuditEvent(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await logger.audit(feature: 'books', action: 'search');

        // assert
        final captured = verify(() => mockTrackAuditEvent(captureAny())).captured;
        final params = captured.first as TrackAuditEventParams;
        expect(params.userId, 'user123');
        expect(params.sessionId, 'session456');
      });
    });

    group('trackPerformanceAsync', () {
      test('should track successful async operation', () async {
        // arrange
        when(() => mockTrackPerformance(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await logger.trackPerformanceAsync<String>(
          operation: 'fetch_data',
          feature: 'books',
          fn: () async {
            await Future.delayed(const Duration(milliseconds: 10));
            return 'result';
          },
        );

        // assert
        expect(result, 'result');
        final captured = verify(() => mockTrackPerformance(captureAny())).captured;
        final params = captured.first as TrackPerformanceParams;
        expect(params.operation, 'fetch_data');
        expect(params.feature, 'books');
        expect(params.success, true);
      });

      test('should track failed async operation', () async {
        // arrange
        when(() => mockTrackPerformance(any()))
            .thenAnswer((_) async => const Right(null));

        // act & assert
        await expectLater(
          logger.trackPerformanceAsync(
            operation: 'failing_operation',
            fn: () async => throw Exception('Failed'),
          ),
          throwsException,
        );
        final captured = verify(() => mockTrackPerformance(captureAny())).captured;
        final params = captured.first as TrackPerformanceParams;
        expect(params.success, false);
      });
    });

    group('trackPerformanceSync', () {
      test('should track successful sync operation', () {
        // arrange
        when(() => mockTrackPerformance(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = logger.trackPerformanceSync<int>(
          operation: 'calculate',
          fn: () => 42,
        );

        // assert
        expect(result, 42);
        verify(() => mockTrackPerformance(any())).called(1);
      });

      test('should track failed sync operation', () {
        // arrange
        when(() => mockTrackPerformance(any()))
            .thenAnswer((_) async => const Right(null));

        // act & assert
        expect(
          () => logger.trackPerformanceSync(
            operation: 'failing',
            fn: () => throw Exception('Failed'),
          ),
          throwsException,
        );
        verify(() => mockTrackPerformance(any())).called(1);
      });
    });

    group('PerformanceTracker', () {
      test('should track performance manually', () async {
        // arrange
        when(() => mockTrackPerformance(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        final tracker = logger.trackPerformance(
          operation: 'manual_operation',
          feature: 'test',
        );
        await Future.delayed(const Duration(milliseconds: 10));
        await tracker.stop();

        // assert
        expect(tracker.elapsedMs, greaterThan(0));
        verify(() => mockTrackPerformance(any())).called(1);
      });

      test('should track failed operation', () async {
        // arrange
        when(() => mockTrackPerformance(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        final tracker = logger.trackPerformance(operation: 'test');
        await tracker.stop(success: false);

        // assert
        final captured = verify(() => mockTrackPerformance(captureAny())).captured;
        final params = captured.first as TrackPerformanceParams;
        expect(params.success, false);
      });
    });

    group('getConfig', () {
      test('should return config when available', () async {
        // arrange
        const config = LogConfig(globalLevel: LogLevel.debug);
        when(() => mockRepository.getConfig())
            .thenAnswer((_) async => const Right(config));

        // act
        final result = await logger.getConfig();

        // assert
        expect(result, config);
        verify(() => mockRepository.getConfig()).called(1);
      });

      test('should return null when config retrieval fails', () async {
        // arrange
        when(() => mockRepository.getConfig())
            .thenAnswer((_) async => const Left(CacheFailure('Error')));

        // act
        final result = await logger.getConfig();

        // assert
        expect(result, null);
      });
    });
  });
}
