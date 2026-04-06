import 'package:dio/dio.dart';
import 'package:flutter_library/core/constants/app_constants.dart';

/// Central HTTP client for all API communication.
///
/// Configures [Dio] with [AppConstants.baseUrl] and shared interceptors.
/// Register as a singleton via the DI container and inject wherever
/// network calls are needed. Individual datasources never need to know
/// about the base URL — they use relative paths (e.g. `/books`).
class ApiClient {
  final Dio dio;

  /// Creates an [ApiClient].
  ///
  /// Pass a pre-configured [dio] instance only in tests.
  ApiClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.baseUrl,
                connectTimeout:
                    const Duration(milliseconds: AppConstants.requestTimeout),
                receiveTimeout:
                    const Duration(milliseconds: AppConstants.requestTimeout),
              ),
            ) {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    dio.interceptors.addAll([
      LoggingInterceptor(),
      // Add auth, retry, or other interceptors here when the backend is ready
    ]);
  }
}

/// Logging interceptor for API requests
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Debug logging - consider using a proper logging framework in production
    // print('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Debug logging - consider using a proper logging framework in production
    // print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Debug logging - consider using a proper logging framework in production
    // print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}
