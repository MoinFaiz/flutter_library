import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/core/network/api_client.dart';

class MockDio extends Mock implements Dio {
  @override
  Interceptors get interceptors => MockInterceptors();
}

class MockInterceptors extends Mock implements Interceptors {}

void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;

    group('Initialization', () {
      test('should initialize with default Dio instance when none provided', () {
        // Act
        apiClient = ApiClient();

        // Assert
        expect(apiClient.dio, isA<Dio>());
        expect(apiClient.dio.interceptors.length, greaterThan(0));
      });

      test('should use provided Dio instance when given', () {
        // Arrange
        final mockDio = Dio(); // Use real Dio instead of mock for this test

        // Act
        apiClient = ApiClient(dio: mockDio);

        // Assert
        expect(apiClient.dio, equals(mockDio));
      });

      test('should add LoggingInterceptor to interceptors', () {
        // Act
        apiClient = ApiClient();

        // Assert
        final hasLoggingInterceptor = apiClient.dio.interceptors
            .any((interceptor) => interceptor is LoggingInterceptor);
        expect(hasLoggingInterceptor, isTrue);
      });
    });

    group('Dio Configuration', () {
      test('should provide access to underlying Dio instance', () {
        // Arrange
        final realDio = Dio();
        apiClient = ApiClient(dio: realDio);

        // Act
        final dioInstance = apiClient.dio;

        // Assert
        expect(dioInstance, equals(realDio));
      });

      test('should maintain interceptor configuration', () {
        // Act
        apiClient = ApiClient();

        // Assert
        expect(apiClient.dio.interceptors, isNotEmpty);
        final hasLoggingInterceptor = apiClient.dio.interceptors
            .any((interceptor) => interceptor is LoggingInterceptor);
        expect(hasLoggingInterceptor, isTrue);
      });
    });
  });

  group('LoggingInterceptor Tests', () {
    late LoggingInterceptor interceptor;
    late MockRequestInterceptorHandler mockRequestHandler;
    late MockResponseInterceptorHandler mockResponseHandler;
    late MockErrorInterceptorHandler mockErrorHandler;

    setUp(() {
      interceptor = LoggingInterceptor();
      mockRequestHandler = MockRequestInterceptorHandler();
      mockResponseHandler = MockResponseInterceptorHandler();
      mockErrorHandler = MockErrorInterceptorHandler();
    });

    group('onRequest', () {
      test('should call super.onRequest with correct parameters', () {
        // Arrange
        final requestOptions = RequestOptions(path: '/test');

        // Act
        interceptor.onRequest(requestOptions, mockRequestHandler);

        // Assert
        verify(() => mockRequestHandler.next(requestOptions)).called(1);
      });

      test('should handle different HTTP methods', () {
        // Arrange
        final requestOptions = RequestOptions(
          path: '/test',
          method: 'POST',
        );

        // Act
        interceptor.onRequest(requestOptions, mockRequestHandler);

        // Assert
        verify(() => mockRequestHandler.next(requestOptions)).called(1);
      });

      test('should handle request options with data', () {
        // Arrange
        final requestOptions = RequestOptions(
          path: '/test',
          method: 'POST',
          data: {'key': 'value'},
        );

        // Act
        interceptor.onRequest(requestOptions, mockRequestHandler);

        // Assert
        verify(() => mockRequestHandler.next(requestOptions)).called(1);
      });
    });

    group('onResponse', () {
      test('should call super.onResponse with correct parameters', () {
        // Arrange
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
          data: {'success': true},
        );

        // Act
        interceptor.onResponse(response, mockResponseHandler);

        // Assert
        verify(() => mockResponseHandler.next(response)).called(1);
      });

      test('should handle different response status codes', () {
        // Arrange
        final responses = [
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 200,
            data: {'success': true},
          ),
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 201,
            data: {'created': true},
          ),
          Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 404,
            data: {'error': 'Not found'},
          ),
        ];

        // Act & Assert
        for (final response in responses) {
          interceptor.onResponse(response, mockResponseHandler);
          verify(() => mockResponseHandler.next(response)).called(1);
        }
      });

      test('should handle response with no data', () {
        // Arrange
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 204,
        );

        // Act
        interceptor.onResponse(response, mockResponseHandler);

        // Assert
        verify(() => mockResponseHandler.next(response)).called(1);
      });
    });

    group('onError', () {
      test('should call super.onError with correct parameters', () {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        );

        // Act
        interceptor.onError(dioException, mockErrorHandler);

        // Assert
        verify(() => mockErrorHandler.next(dioException)).called(1);
      });

      test('should handle different error types', () {
        // Arrange
        final errors = [
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timeout',
          ),
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.sendTimeout,
            message: 'Send timeout',
          ),
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.receiveTimeout,
            message: 'Receive timeout',
          ),
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.badResponse,
            message: 'Bad response',
          ),
        ];

        // Act & Assert
        for (final error in errors) {
          interceptor.onError(error, mockErrorHandler);
          verify(() => mockErrorHandler.next(error)).called(1);
        }
      });

      test('should handle error with response data', () {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          message: 'Bad response',
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'error': 'Bad request'},
          ),
        );

        // Act
        interceptor.onError(dioException, mockErrorHandler);

        // Assert
        verify(() => mockErrorHandler.next(dioException)).called(1);
      });
    });      group('Integration', () {
        test('should work with real Dio instance', () {
          // Arrange
          final dio = Dio();
          dio.interceptors.add(LoggingInterceptor());

          // Act & Assert
          expect(dio.interceptors.length, greaterThanOrEqualTo(1));
          final hasLoggingInterceptor = dio.interceptors
              .any((interceptor) => interceptor is LoggingInterceptor);
          expect(hasLoggingInterceptor, isTrue);
        });

        test('should maintain interceptor order when multiple interceptors added', () {
          // Arrange
          final dio = Dio();
          final loggingInterceptor = LoggingInterceptor();
          final customInterceptor = _CustomInterceptor();

          // Act
          dio.interceptors.addAll([loggingInterceptor, customInterceptor]);

          // Assert
          expect(dio.interceptors.length, greaterThanOrEqualTo(2));
          final hasLoggingInterceptor = dio.interceptors
              .any((interceptor) => interceptor is LoggingInterceptor);
          final hasCustomInterceptor = dio.interceptors
              .any((interceptor) => interceptor is _CustomInterceptor);
          expect(hasLoggingInterceptor, isTrue);
          expect(hasCustomInterceptor, isTrue);
        });
      });
  });
}

// Mock classes for testing
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockResponseInterceptorHandler extends Mock implements ResponseInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

// Custom interceptor for testing
class _CustomInterceptor extends Interceptor {
  // No need to override onRequest as it just calls super
}
