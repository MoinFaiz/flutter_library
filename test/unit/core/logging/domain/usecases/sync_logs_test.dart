import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/logging/domain/entities/log_config.dart';
import 'package:flutter_library/core/logging/domain/entities/log_entry.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_library/core/logging/domain/repositories/logging_repository.dart';
import 'package:flutter_library/core/logging/domain/usecases/sync_logs.dart';
import 'package:flutter_library/core/usecase/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggingRepository extends Mock implements LoggingRepository {}

void main() {
  late SyncLogs useCase;
  late MockLoggingRepository mockRepository;

  setUp(() {
    mockRepository = MockLoggingRepository();
    useCase = SyncLogs(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(<LogEntry>[]);
  });

  group('SyncLogs', () {
    const tConfig = LogConfig(
      enabled: true,
      remoteLoggingEnabled: true,
    );

    final tLogs = [
      LogEntry(
        id: '1',
        timestamp: DateTime.now(),
        level: LogLevel.info,
        message: 'Test 1',
      ),
      LogEntry(
        id: '2',
        timestamp: DateTime.now(),
        level: LogLevel.error,
        message: 'Test 2',
      ),
    ];

    test('should sync logs and clear local storage when successful', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.getLocalLogs())
          .thenAnswer((_) async => Right(tLogs));
      when(() => mockRepository.syncLogsToServer(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.clearLocalLogs())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verify(() => mockRepository.getLocalLogs()).called(1);
      verify(() => mockRepository.syncLogsToServer(tLogs)).called(1);
      verify(() => mockRepository.clearLocalLogs()).called(1);
    });

    test('should not sync when logging is disabled', () async {
      // arrange
      const disabledConfig = LogConfig(enabled: false);
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(disabledConfig));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.getLocalLogs());
      verifyNever(() => mockRepository.syncLogsToServer(any()));
    });

    test('should not sync when remote logging is disabled', () async {
      // arrange
      const config = LogConfig(
        enabled: true,
        remoteLoggingEnabled: false,
      );
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(config));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.getLocalLogs());
      verifyNever(() => mockRepository.syncLogsToServer(any()));
    });

    test('should not sync when no logs available', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.getLocalLogs())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verify(() => mockRepository.getLocalLogs()).called(1);
      verifyNever(() => mockRepository.syncLogsToServer(any()));
      verifyNever(() => mockRepository.clearLocalLogs());
    });

    test('should return failure when getting logs fails', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.getLocalLogs())
          .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Left(CacheFailure('Cache error')));
      verifyNever(() => mockRepository.syncLogsToServer(any()));
    });

    test('should return failure when sync fails', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.getLocalLogs())
          .thenAnswer((_) async => Right(tLogs));
      when(() => mockRepository.syncLogsToServer(any()))
          .thenAnswer((_) async => const Left(ServerFailure()));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Left(ServerFailure()));
      verifyNever(() => mockRepository.clearLocalLogs());
    });

    test('should return failure when config retrieval fails', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Left(CacheFailure('Config error')));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Left(CacheFailure('Config error')));
      verifyNever(() => mockRepository.getLocalLogs());
    });
  });
}
