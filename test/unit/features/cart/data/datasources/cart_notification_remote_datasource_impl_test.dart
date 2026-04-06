import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_remote_datasource_impl.dart';
import 'package:flutter_library/features/cart/data/models/cart_notification_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late CartNotificationRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    dataSource = CartNotificationRemoteDataSourceImpl(dio: mockDio);
  });

  group('CartNotificationRemoteDataSourceImpl', () {
    final testNotification = CartNotificationModel(
      id: 'notif1',
      requestId: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      type: NotificationType.requestReceived,
      requestType: CartItemType.rent,
      message: 'New request',
      isRead: false,
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );

    group('getNotifications', () {
      test('should return list of notifications on success', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'data': [testNotification.toJson()]},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result, isA<List<CartNotificationModel>>());
        verify(() => mockDio.get('${AppConstants.baseUrl}/cart/notifications')).called(1);
      });

      test('should throw ServerException on non-200 status', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {},
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.getNotifications(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        // Act & Assert
        expect(() => dataSource.getNotifications(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(Exception('Generic error'));

        // Act & Assert
        expect(() => dataSource.getNotifications(), throwsA(isA<ServerException>()));
      });
    });

    group('getUnreadCount', () {
      test('should return unread count on success', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'count': 5},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await dataSource.getUnreadCount();

        // Assert
        expect(result, equals(5));
      });

      test('should throw ServerException on error', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(() => dataSource.getUnreadCount(), throwsA(isA<ServerException>()));
      });
    });

    group('markAsRead', () {
      test('should complete successfully on 200', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.markAsRead('notif1'), returnsNormally);
      });

      test('should complete successfully on 204', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              statusCode: 204,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.markAsRead('notif1'), returnsNormally);
      });

      test('should throw ServerException on non-success status', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              statusCode: 400,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.markAsRead('notif1'), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.post(any())).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(() => dataSource.markAsRead('notif1'), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.post(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.markAsRead('notif1'), throwsA(isA<ServerException>()));
      });
    });

    group('markAllAsRead', () {
      test('should complete successfully', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.markAllAsRead(), returnsNormally);
      });

      test('should throw ServerException on error', () async {
        // Arrange
        when(() => mockDio.post(any())).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(() => dataSource.markAllAsRead(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.post(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.markAllAsRead(), throwsA(isA<ServerException>()));
      });
    });

    group('deleteNotification', () {
      test('should complete successfully', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.deleteNotification('notif1'), returnsNormally);
      });

      test('should throw ServerException on error', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(() => dataSource.deleteNotification('notif1'), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.deleteNotification('notif1'), throwsA(isA<ServerException>()));
      });
    });

    group('watchNotifications', () {
      test('should provide a stream', () {
        // Act
        final stream = dataSource.watchNotifications();

        // Assert
        expect(stream, isA<Stream<List<CartNotificationModel>>>());
      });
    });
  });
}
