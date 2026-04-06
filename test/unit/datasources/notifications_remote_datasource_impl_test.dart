import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_remote_datasource_impl.dart';
import 'package:flutter_library/features/notifications/data/models/notification_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('NotificationsRemoteDataSourceImpl', () {
    late NotificationsRemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = NotificationsRemoteDataSourceImpl(dio: mockDio);
    });

    group('getNotifications', () {
      test('should return list of NotificationModel from API when successful', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'notifications': [
              {
                'id': '1',
                'title': 'Test Notification',
                'message': 'Test Message',
                'timestamp': '2024-01-15T10:30:00.000',
                'type': 'reminder',
                'isRead': false,
              },
              {
                'id': '2',
                'title': 'Book Request',
                'message': 'New book request',
                'timestamp': '2024-01-14T10:30:00.000',
                'type': 'bookRequest',
                'isRead': true,
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result, isA<List<NotificationModel>>());
        expect(result.length, equals(2));
        expect(result[0].id, equals('1'));
        expect(result[0].title, equals('Test Notification'));
        expect(result[1], isA<BookRequestNotificationModel>());
        verify(() => mockDio.get('/notifications')).called(1);
      });

      test('should return BookRequestNotificationModel for bookRequest type', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'notifications': [
              {
                'id': '1',
                'title': 'Book Request',
                'message': 'Request for book',
                'timestamp': '2024-01-15T10:30:00.000',
                'type': 'bookRequest',
                'isRead': false,
                'data': {
                  'bookId': 'book_1',
                  'bookTitle': 'Test Book',
                  'requesterId': 'user_1',
                  'requesterName': 'John Doe',
                  'requesterEmail': 'john@example.com',
                  'requestType': 'rent',
                  'pickupDate': '2024-01-20T10:00:00.000',
                  'pickupLocation': 'Library',
                  'requestMessage': 'I want to rent this book',
                  'status': 'pending',
                }
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result[0], isA<BookRequestNotificationModel>());
        final bookRequestNotification = result[0] as BookRequestNotificationModel;
        expect(bookRequestNotification.bookData?.bookId, equals('book_1'));
      });

      test('should return mock data when API call fails', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result, isA<List<NotificationModel>>());
        expect(result.isNotEmpty, isTrue);
        verify(() => mockDio.get('/notifications')).called(1);
      });
    });

    group('getUnreadCount', () {
      test('should return unread count from API when successful', () async {
        // Arrange
        final mockResponse = Response(
          data: {'count': 5},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getUnreadCount();

        // Assert
        expect(result, equals(5));
        verify(() => mockDio.get('/notifications/unread-count')).called(1);
      });

      test('should return 3 when API call fails', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.getUnreadCount();

        // Assert
        expect(result, equals(3));
        verify(() => mockDio.get('/notifications/unread-count')).called(1);
      });
    });

    group('markAsRead', () {
      test('should call API with correct notification ID when successful', () async {
        // Arrange
        const notificationId = 'notification_123';
        final mockResponse = Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.patch(any())).thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.markAsRead(notificationId);

        // Assert
        verify(() => mockDio.patch('/notifications/$notificationId/read')).called(1);
      });

      test('should complete without error when API call fails', () async {
        // Arrange
        const notificationId = 'notification_123';
        when(() => mockDio.patch(any())).thenThrow(Exception('Network error'));

        // Act
        await dataSource.markAsRead(notificationId);

        // Assert
        verify(() => mockDio.patch('/notifications/$notificationId/read')).called(1);
      });
    });

    group('markAllAsRead', () {
      test('should call API endpoint when successful', () async {
        // Arrange
        final mockResponse = Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.patch(any())).thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.markAllAsRead();

        // Assert
        verify(() => mockDio.patch('/notifications/mark-all-read')).called(1);
      });

      test('should complete without error when API call fails', () async {
        // Arrange
        when(() => mockDio.patch(any())).thenThrow(Exception('Network error'));

        // Act
        await dataSource.markAllAsRead();

        // Assert
        verify(() => mockDio.patch('/notifications/mark-all-read')).called(1);
      });
    });

    group('deleteNotification', () {
      test('should call API with correct notification ID when successful', () async {
        // Arrange
        const notificationId = 'notification_456';
        final mockResponse = Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.delete(any())).thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.deleteNotification(notificationId);

        // Assert
        verify(() => mockDio.delete('/notifications/$notificationId')).called(1);
      });

      test('should complete without error when API call fails', () async {
        // Arrange
        const notificationId = 'notification_456';
        when(() => mockDio.delete(any())).thenThrow(Exception('Network error'));

        // Act
        await dataSource.deleteNotification(notificationId);

        // Assert
        verify(() => mockDio.delete('/notifications/$notificationId')).called(1);
      });
    });

    group('acceptBookRequest', () {
      test('should call API with correct notification ID when successful', () async {
        // Arrange
        const notificationId = 'request_789';
        final mockResponse = Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.post(any())).thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.acceptBookRequest(notificationId);

        // Assert
        verify(() => mockDio.post('/book-requests/$notificationId/accept')).called(1);
      });

      test('should complete without error when API call fails', () async {
        // Arrange
        const notificationId = 'request_789';
        when(() => mockDio.post(any())).thenThrow(Exception('Network error'));

        // Act
        await dataSource.acceptBookRequest(notificationId);

        // Assert
        verify(() => mockDio.post('/book-requests/$notificationId/accept')).called(1);
      });
    });

    group('rejectBookRequest', () {
      test('should call API with correct notification ID and reason when successful', () async {
        // Arrange
        const notificationId = 'request_101';
        const reason = 'Book not available';
        final mockResponse = Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.rejectBookRequest(notificationId, reason);

        // Assert
        verify(() => mockDio.post(
          '/book-requests/$notificationId/reject',
          data: {'reason': reason},
        )).called(1);
      });

      test('should call API with null reason when reason is not provided', () async {
        // Arrange
        const notificationId = 'request_102';
        final mockResponse = Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => mockResponse);

        // Act
        await dataSource.rejectBookRequest(notificationId, null);

        // Assert
        verify(() => mockDio.post(
          '/book-requests/$notificationId/reject',
          data: {'reason': null},
        )).called(1);
      });

      test('should complete without error when API call fails', () async {
        // Arrange
        const notificationId = 'request_103';
        const reason = 'Not interested';
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(Exception('Network error'));

        // Act
        await dataSource.rejectBookRequest(notificationId, reason);

        // Assert
        verify(() => mockDio.post(
          '/book-requests/$notificationId/reject',
          data: {'reason': reason},
        )).called(1);
      });
    });
  });
}
