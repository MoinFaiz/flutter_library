import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/logging/domain/entities/audit_event.dart';
import 'package:flutter_library/core/logging/domain/entities/log_config.dart';
import 'package:flutter_library/core/logging/domain/repositories/logging_repository.dart';
import 'package:flutter_library/core/logging/domain/usecases/track_audit_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggingRepository extends Mock implements LoggingRepository {}

void main() {
  late TrackAuditEvent useCase;
  late MockLoggingRepository mockRepository;

  setUp(() {
    mockRepository = MockLoggingRepository();
    useCase = TrackAuditEvent(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(AuditEvent(
      id: '1',
      timestamp: DateTime.now(),
      feature: 'test',
      action: 'test',
    ));
  });

  group('TrackAuditEvent', () {
    const tConfig = LogConfig(
      enabled: true,
      auditTrackingEnabled: true,
    );

    const tParams = TrackAuditEventParams(
      feature: 'books',
      action: 'search',
      parameters: {'query': 'flutter'},
      success: true,
    );

    test('should save audit event when tracking is enabled', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.saveAuditEvent(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verify(() => mockRepository.saveAuditEvent(any())).called(1);
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
      verifyNever(() => mockRepository.saveAuditEvent(any()));
    });

    test('should not track when audit tracking is disabled', () async {
      // arrange
      const config = LogConfig(
        enabled: true,
        auditTrackingEnabled: false,
      );
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(config));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getConfig()).called(1);
      verifyNever(() => mockRepository.saveAuditEvent(any()));
    });

    test('should include userId and sessionId in audit event', () async {
      // arrange
      const params = TrackAuditEventParams(
        feature: 'cart',
        action: 'checkout',
        userId: 'user123',
        sessionId: 'session456',
      );
      AuditEvent? capturedEvent;

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.saveAuditEvent(any())).thenAnswer((invocation) async {
        capturedEvent = invocation.positionalArguments[0] as AuditEvent;
        return const Right(null);
      });

      // act
      await useCase(params);

      // assert
      expect(capturedEvent?.userId, 'user123');
      expect(capturedEvent?.sessionId, 'session456');
      expect(capturedEvent?.feature, 'cart');
      expect(capturedEvent?.action, 'checkout');
    });

    test('should track failure events', () async {
      // arrange
      const params = TrackAuditEventParams(
        feature: 'books',
        action: 'load',
        success: false,
      );
      AuditEvent? capturedEvent;

      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockRepository.saveAuditEvent(any())).thenAnswer((invocation) async {
        capturedEvent = invocation.positionalArguments[0] as AuditEvent;
        return const Right(null);
      });

      // act
      await useCase(params);

      // assert
      expect(capturedEvent?.success, false);
    });

    test('should return failure when config retrieval fails', () async {
      // arrange
      when(() => mockRepository.getConfig())
          .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Left(CacheFailure('Cache error')));
      verifyNever(() => mockRepository.saveAuditEvent(any()));
    });
  });
}
