import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/logging/domain/entities/log_config.dart';
import 'package:flutter_library/core/logging/domain/entities/log_entry.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_library/core/logging/domain/repositories/logging_repository.dart';
import 'package:flutter_library/core/logging/domain/usecases/log_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggingRepository extends Mock implements LoggingRepository {}

void main() {
  late LogMessage useCase;
  late MockLoggingRepository mockRepository;

  setUp(() {
    mockRepository = MockLoggingRepository();
    useCase = LogMessage(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(LogEntry(
      id: '1',
      timestamp: DateTime.now(),
      level: LogLevel.info,
      message: 'test',
    ));
  });

  group('LogMessage', () {
    const tConfig = LogConfig(
      enabled: true,
      globalLevel: LogLevel.info,
      localLoggingEnabled: true,
    );

    final tParams = LogMessageParams(
      level: LogLevel.info,
      message: 'Test message',
      feature: 'books',
      action: 'search',
      metadata: {'query': 'flutter'},
    );

    test('should save log entry when logging is enabled', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.saveLogEntry(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verify(() => mockRepository.saveLogEntry(any())).called(1);
    });

    test('should not log when logging is disabled', () async {
      // arrange
      const disabledConfig = LogConfig(enabled: false);
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(disabledConfig));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.saveLogEntry(any()));
    });

    test('should not log when level does not meet threshold', () async {
      // arrange
      const config = LogConfig(
        enabled: true,
        globalLevel: LogLevel.error, // Only errors
      );
      final params = LogMessageParams(
        level: LogLevel.info, // Info won't be logged
        message: 'Test',
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(config));

      // act
      final result = await useCase(params);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.saveLogEntry(any()));
    });

    test('should respect feature-specific log levels', () async {
      // arrange
      final config = LogConfig(
        enabled: true,
        globalLevel: LogLevel.warning,
        featureLevels: {'books': LogLevel.debug},
      );
      final params = LogMessageParams(
        level: LogLevel.debug,
        message: 'Debug message',
        feature: 'books',
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => Right(config));
      when(() => mockRepository.saveLogEntry(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(params);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.saveLogEntry(any())).called(1);
    });

    test('should not save locally when local logging is disabled', () async {
      // arrange
      const config = LogConfig(
        enabled: true,
        globalLevel: LogLevel.info,
        localLoggingEnabled: false,
      );

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(config));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.saveLogEntry(any()));
    });

    test('should include userId and sessionId in log entry', () async {
      // arrange
      final params = LogMessageParams(
        level: LogLevel.info,
        message: 'Test',
        userId: 'user123',
        sessionId: 'session456',
      );
      LogEntry? capturedEntry;

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.saveLogEntry(any())).thenAnswer((invocation) async {
        capturedEntry = invocation.positionalArguments[0] as LogEntry;
        return const Right(null);
      });

      // act
      await useCase(params);

      // assert
      expect(capturedEntry?.userId, 'user123');
      expect(capturedEntry?.sessionId, 'session456');
    });

    test('should return failure when config retrieval fails', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Left(CacheFailure('Cache error')));
      verifyNever(() => mockRepository.saveLogEntry(any()));
    });
  });
}
