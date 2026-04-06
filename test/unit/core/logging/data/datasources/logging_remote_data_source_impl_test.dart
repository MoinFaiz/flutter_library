import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/core/logging/data/datasources/logging_remote_data_source_impl.dart';
import 'package:flutter_library/core/logging/data/models/log_config_model.dart';
import 'package:flutter_library/core/logging/data/models/log_entry_model.dart';
import 'package:flutter_library/core/logging/data/models/audit_event_model.dart';
import 'package:flutter_library/core/error/exceptions.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late LoggingRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = LoggingRemoteDataSourceImpl(dio: mockDio);
  });

  group('LoggingRemoteDataSourceImpl', () {
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
    );

    final testAuditEvent = AuditEventModel(
      id: 'audit-1',
      timestamp: '2024-01-01T12:00:00.000',
      feature: 'test',
      action: 'test-action',
      success: true,
    );

    group('fetchConfig', () {
      test('should return config on successful response', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: testConfig.toJson(),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/config'),
          ),
        );

        // Act
        final result = await dataSource.fetchConfig();

        // Assert
        expect(result.enabled, equals(true));
        expect(result.globalLevel, equals('info'));
        verify(() => mockDio.get('/logging/config')).called(1);
      });

      test('should throw ServerException on DioException (4xx)', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: '/logging/config'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchConfig(),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException on DioException (5xx)', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            message: 'Http status error [500]',
            requestOptions: RequestOptions(path: '/logging/config'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchConfig(),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to fetch logging config'),
          )),
        );
      });

      test('should throw ServerException on connection error', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/logging/config'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchConfig(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('sendLogs', () {
      test('should send logs successfully', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/logs'),
          ),
        );

        // Act
        await dataSource.sendLogs([testLogEntry]);

        // Assert
        verify(() => mockDio.post('/logging/logs', data: any(named: 'data'))).called(1);
      });

      test('should send multiple logs', () async {
        // Arrange
        final logs = [
          testLogEntry,
          LogEntryModel(
            id: 'log-2',
            timestamp: '2024-01-01T12:01:00.000',
            level: 'debug',
            message: 'Another log',
          ),
        ];
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/logs'),
          ),
        );

        // Act
        await dataSource.sendLogs(logs);

        // Assert
        final captured = verify(() => mockDio.post(
              any(),
              data: captureAny(named: 'data'),
            )).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body['logs'].length, equals(2));
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            message: 'Http status error [400]',
            requestOptions: RequestOptions(path: '/logging/logs'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.sendLogs([testLogEntry]),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException with message on 500', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            message: 'Http status error [500]',
            requestOptions: RequestOptions(path: '/logging/logs'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.sendLogs([testLogEntry]),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to send logs'),
          )),
        );
      });

      test('should encode logs correctly', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/logs'),
          ),
        );

        // Act
        await dataSource.sendLogs([testLogEntry]);

        // Assert
        final captured = verify(() => mockDio.post(
              any(),
              data: captureAny(named: 'data'),
            )).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body['logs'], isA<List>());
        expect(body['logs'][0]['id'], equals('log-1'));
      });

      test('should send empty list of logs', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/logs'),
          ),
        );

        // Act
        await dataSource.sendLogs([]);

        // Assert
        final captured = verify(() => mockDio.post(
              any(),
              data: captureAny(named: 'data'),
            )).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body['logs'], isEmpty);
      });
    });

    group('sendAuditEvents', () {
      test('should send audit events successfully', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/audit'),
          ),
        );

        // Act
        await dataSource.sendAuditEvents([testAuditEvent]);

        // Assert
        verify(() => mockDio.post('/logging/audit', data: any(named: 'data'))).called(1);
      });

      test('should send multiple audit events', () async {
        // Arrange
        final events = [
          testAuditEvent,
          AuditEventModel(
            id: 'audit-2',
            timestamp: '2024-01-01T12:01:00.000',
            feature: 'test',
            action: 'another-action',
            success: true,
          ),
        ];
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/audit'),
          ),
        );

        // Act
        await dataSource.sendAuditEvents(events);

        // Assert
        final captured = verify(() => mockDio.post(
              any(),
              data: captureAny(named: 'data'),
            )).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body['events'].length, equals(2));
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            message: 'Http status error [400]',
            requestOptions: RequestOptions(path: '/logging/audit'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.sendAuditEvents([testAuditEvent]),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException with message on 500', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            message: 'Http status error [500]',
            requestOptions: RequestOptions(path: '/logging/audit'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.sendAuditEvents([testAuditEvent]),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Failed to send audit events'),
          )),
        );
      });

      test('should encode audit events correctly', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/audit'),
          ),
        );

        // Act
        await dataSource.sendAuditEvents([testAuditEvent]);

        // Assert
        final captured = verify(() => mockDio.post(
              any(),
              data: captureAny(named: 'data'),
            )).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body['events'], isA<List>());
        expect(body['events'][0]['id'], equals('audit-1'));
      });

      test('should send empty list of events', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/logging/audit'),
          ),
        );

        // Act
        await dataSource.sendAuditEvents([]);

        // Assert
        final captured = verify(() => mockDio.post(
              any(),
              data: captureAny(named: 'data'),
            )).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body['events'], isEmpty);
      });
    });
  });
}
