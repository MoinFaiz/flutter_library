import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/logging/domain/entities/log_config.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_library/core/logging/domain/repositories/logging_repository.dart';
import 'package:flutter_library/core/logging/domain/usecases/fetch_logging_config.dart';
import 'package:flutter_library/core/usecase/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggingRepository extends Mock implements LoggingRepository {}

void main() {
  late FetchLoggingConfig useCase;
  late MockLoggingRepository mockRepository;

  setUp(() {
    mockRepository = MockLoggingRepository();
    useCase = FetchLoggingConfig(mockRepository);
  });

  group('FetchLoggingConfig', () {
    final tConfig = LogConfig(
      enabled: true,
      globalLevel: LogLevel.info,
      featureLevels: {'books': LogLevel.debug},
      remoteLoggingEnabled: true,
      localLoggingEnabled: true,
      performanceTrackingEnabled: true,
      auditTrackingEnabled: true,
      performanceThreshold: 100.0,
      tracingEnabledForUsers: ['user1', 'user2'],
      maxLocalEntries: 1000,
      syncIntervalSeconds: 300,
    );

    test('should fetch config from repository', () async {
      // arrange
      when(() => mockRepository.fetchRemoteConfig())
          .thenAnswer((_) async => Right(tConfig));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, Right(tConfig));
      verify(() => mockRepository.fetchRemoteConfig()).called(1);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(() => mockRepository.fetchRemoteConfig())
          .thenAnswer((_) async => const Left(ServerFailure()));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Left(ServerFailure()));
      verify(() => mockRepository.fetchRemoteConfig()).called(1);
    });

    test('should handle network failure', () async {
      // arrange
      when(() => mockRepository.fetchRemoteConfig())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      // act
      final result = await useCase(const NoParams());

      // assert
      expect(result, const Left(NetworkFailure()));
    });
  });
}
