import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:flutter_library/features/notifications/data/models/notification_model.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:dio/dio.dart';

class MockNotificationsRemoteDataSource extends Mock implements NotificationsRemoteDataSource {}
class MockNotificationsLocalDataSource extends Mock implements NotificationsLocalDataSource {}

void main() {
  group('NotificationsRepositoryImpl', () {
    late NotificationsRepositoryImpl repository;
    late MockNotificationsRemoteDataSource mockRemoteDataSource;
    late MockNotificationsLocalDataSource mockLocalDataSource;

    setUpAll(() {
      registerFallbackValue(NotificationModel(
        id: 'test',
        title: 'test',
        message: 'test',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        data: const BookRequestData(
          bookId: 'test',
          bookTitle: 'Test Book',
          requesterId: 'requester',
          requesterName: 'Test User',
          requesterEmail: 'test@example.com',
          requestType: 'borrow',
          status: 'pending',
        ),
      ));
    });

    setUp(() {
      mockRemoteDataSource = MockNotificationsRemoteDataSource();
      mockLocalDataSource = MockNotificationsLocalDataSource();
      repository = NotificationsRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
      );
    });

    const tNotificationId = 'notification_1';
    const tUnreadCount = 3;

    final tNotificationModel = NotificationModel(
      id: 'notification_1',
      title: 'New Book Request',
      message: 'Someone wants to borrow your book',
      type: NotificationType.bookRequest,
      isRead: false,
      timestamp: DateTime(2023, 1, 1),
      data: const BookRequestData(
        bookId: 'book_1',
        bookTitle: 'Test Book',
        requesterId: 'user_1',
        requesterName: 'Test User',
        requesterEmail: 'test@example.com',
        requestType: 'borrow',
        status: 'pending',
      ),
    );

    final tNotificationModelList = [tNotificationModel];

    group('getNotifications', () {
      test('should return list of notifications when successful', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);
        when(() => mockRemoteDataSource.getNotifications())
            .thenAnswer((_) async => tNotificationModelList);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.getNotifications();

        // assert
        verify(() => mockLocalDataSource.getCachedNotifications());
        verify(() => mockRemoteDataSource.getNotifications());
        verify(() => mockLocalDataSource.cacheNotifications(any()));
        expect(result, isA<Right<Failure, List<AppNotification>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (notifications) => expect(notifications.length, equals(1)),
        );
      });

      test('should return cached notifications when available', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => tNotificationModelList);
        when(() => mockRemoteDataSource.getNotifications())
            .thenAnswer((_) async => tNotificationModelList);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.getNotifications();

        // assert
        verify(() => mockLocalDataSource.getCachedNotifications());
        verify(() => mockRemoteDataSource.getNotifications());
        expect(result, isA<Right<Failure, List<AppNotification>>>());
      });

      test('should return NetworkFailure when remote call fails', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/notifications'),
              response: Response(
                requestOptions: RequestOptions(path: '/notifications'),
                statusCode: 500,
              ),
            ));

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (notifications) => fail('Expected failure'),
        );
      });
    });

    group('getUnreadCount', () {
      test('should return unread count when successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getUnreadCount())
            .thenAnswer((_) async => tUnreadCount);

        // act
        final result = await repository.getUnreadCount();

        // assert
        verify(() => mockRemoteDataSource.getUnreadCount());
        expect(result, isA<Right<Failure, int>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (count) => expect(count, equals(tUnreadCount)),
        );
      });

      test('should return NetworkFailure when remote call fails', () async {
        // arrange
        when(() => mockRemoteDataSource.getUnreadCount())
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/notifications/unread-count'),
              response: Response(
                requestOptions: RequestOptions(path: '/notifications/unread-count'),
                statusCode: 500,
              ),
            ));

        // act
        final result = await repository.getUnreadCount();

        // assert
        expect(result, isA<Left<Failure, int>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (count) => fail('Expected failure'),
        );
      });
    });

    group('markAsRead', () {
      test('should mark notification as read successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.markAsRead(tNotificationId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.markAsReadInCache(tNotificationId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => tNotificationModelList);

        // act
        final result = await repository.markAsRead(tNotificationId);

        // assert
        verify(() => mockRemoteDataSource.markAsRead(tNotificationId));
        verify(() => mockLocalDataSource.markAsReadInCache(tNotificationId));
        verify(() => mockLocalDataSource.getCachedNotifications());
        expect(result, isA<Right<Failure, void>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (_) => {}, // void result doesn't need any check
        );
      });

      test('should return NetworkFailure when remote call fails', () async {
        // arrange
        when(() => mockRemoteDataSource.markAsRead(tNotificationId))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/notifications/$tNotificationId/read'),
              response: Response(
                requestOptions: RequestOptions(path: '/notifications/$tNotificationId/read'),
                statusCode: 500,
              ),
            ));

        // act
        final result = await repository.markAsRead(tNotificationId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('markAllAsRead', () {
      test('should mark all notifications as read successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.markAllAsRead())
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => tNotificationModelList);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.markAllAsRead();

        // assert
        verify(() => mockRemoteDataSource.markAllAsRead());
        verify(() => mockLocalDataSource.getCachedNotifications());
        verify(() => mockLocalDataSource.cacheNotifications(any()));
        expect(result, isA<Right<Failure, void>>());
      });
    });

    group('deleteNotification', () {
      test('should delete notification successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteNotification(tNotificationId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.removeNotificationFromCache(tNotificationId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => tNotificationModelList);

        // act
        final result = await repository.deleteNotification(tNotificationId);

        // assert
        verify(() => mockRemoteDataSource.deleteNotification(tNotificationId));
        verify(() => mockLocalDataSource.removeNotificationFromCache(tNotificationId));
        verify(() => mockLocalDataSource.getCachedNotifications());
        expect(result, isA<Right<Failure, void>>());
      });
    });

    group('acceptBookRequest', () {
      test('should accept book request successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.acceptBookRequest(tNotificationId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => tNotificationModelList);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.acceptBookRequest(tNotificationId);

        // assert
        verify(() => mockRemoteDataSource.acceptBookRequest(tNotificationId));
        verify(() => mockLocalDataSource.getCachedNotifications());
        verify(() => mockLocalDataSource.cacheNotifications(any()));
        expect(result, isA<Right<Failure, void>>());
      });
    });

    group('rejectBookRequest', () {
      test('should reject book request successfully', () async {
        // arrange
        const reason = 'Book not available';
        when(() => mockRemoteDataSource.rejectBookRequest(tNotificationId, reason))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => tNotificationModelList);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.rejectBookRequest(tNotificationId, reason);

        // assert
        verify(() => mockRemoteDataSource.rejectBookRequest(tNotificationId, reason));
        verify(() => mockLocalDataSource.getCachedNotifications());
        verify(() => mockLocalDataSource.cacheNotifications(any()));
        expect(result, isA<Right<Failure, void>>());
      });

      test('should reject book request without reason', () async {
        // arrange
        when(() => mockRemoteDataSource.rejectBookRequest(tNotificationId, null))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => tNotificationModelList);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.rejectBookRequest(tNotificationId, null);

        // assert
        verify(() => mockRemoteDataSource.rejectBookRequest(tNotificationId, null));
        verify(() => mockLocalDataSource.getCachedNotifications());
        verify(() => mockLocalDataSource.cacheNotifications(any()));
        expect(result, isA<Right<Failure, void>>());
      });

      test('should update BookRequestNotificationModel status in cache when rejecting', () async {
        // arrange
        const reason = 'Not interested';
        final bookRequestNotification = BookRequestNotificationModel(
          id: 'request_1',
          title: 'Book Request',
          message: 'Request message',
          type: NotificationType.bookRequest,
          isRead: false,
          timestamp: DateTime(2023, 1, 1),
          bookRequestData: const BookRequestData(
            bookId: 'book_1',
            bookTitle: 'Test Book',
            requesterId: 'user_1',
            requesterName: 'Test User',
            requesterEmail: 'test@example.com',
            requestType: 'rent',
            status: 'pending',
          ),
        );

        when(() => mockRemoteDataSource.rejectBookRequest('request_1', reason))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => [bookRequestNotification]);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.rejectBookRequest('request_1', reason);

        // assert
        verify(() => mockLocalDataSource.cacheNotifications(any())).called(1);
        expect(result, isA<Right<Failure, void>>());
      });
    });

    group('getNotifications - Exception Handling', () {
      test('should return UnknownFailure when non-DioException is thrown', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(Exception('Unexpected error'));

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect((failure as UnknownFailure).message, contains('Failed to get notifications'));
          },
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    group('watchNotifications', () {
      test('should return stream of notifications', () async {
        // arrange
        final streamController = repository.watchNotifications();

        // act & assert
        expect(streamController, isA<Stream<List<AppNotification>>>());
      });

      test('should emit notifications when getNotifications is called', () async {
        // arrange
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);
        when(() => mockRemoteDataSource.getNotifications())
            .thenAnswer((_) async => tNotificationModelList);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        final stream = repository.watchNotifications();
        
        // act & assert - Use expectLater first to listen, then trigger the action
        final expectation = expectLater(
          stream.take(1), // Take only the first emission to avoid timeout
          emits(isA<List<AppNotification>>()),
        );
        
        // Now trigger the action that should cause emission
        await repository.getNotifications();
        
        // Wait for the expectation to complete
        await expectation;
      });
    });

    group('_handleDioError', () {
      test('should handle connection timeout', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(dioError);
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (notifications) => fail('Expected Left but got Right'),
        );
      });

      test('should handle send timeout', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.sendTimeout,
        );
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(dioError);
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (notifications) => fail('Expected Left but got Right'),
        );
      });

      test('should handle receive timeout', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        );
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(dioError);
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (notifications) => fail('Expected Left but got Right'),
        );
      });

      test('should handle 404 bad response', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 404,
            statusMessage: 'Not Found',
          ),
        );
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(dioError);
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect((failure as ServerFailure).message, contains('not found'));
          },
          (notifications) => fail('Expected Left but got Right'),
        );
      });

      test('should handle 401 bad response', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
            statusMessage: 'Unauthorized',
          ),
        );
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(dioError);
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect((failure as ServerFailure).message, contains('Unauthorized'));
          },
          (notifications) => fail('Expected Left but got Right'),
        );
      });

      test('should handle other bad response status codes', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
            statusMessage: 'Internal Server Error',
          ),
        );
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(dioError);
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect((failure as ServerFailure).message, contains('Server error'));
          },
          (notifications) => fail('Expected Left but got Right'),
        );
      });

      test('should handle request cancelled', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.cancel,
        );
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(dioError);
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (notifications) => fail('Expected Left but got Right'),
        );
      });

      test('should handle unknown dio error', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.unknown,
        );
        when(() => mockRemoteDataSource.getNotifications())
            .thenThrow(dioError);
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getNotifications();

        // assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (notifications) => fail('Expected Left but got Right'),
        );
      });
    });

    group('Error Handling in Different Methods', () {
      test('should handle DioException in getUnreadCount', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        when(() => mockRemoteDataSource.getUnreadCount())
            .thenThrow(dioError);

        // act
        final result = await repository.getUnreadCount();

        // assert
        expect(result, isA<Left<Failure, int>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (count) => fail('Expected Left but got Right'),
        );
      });

      test('should handle generic exception in getUnreadCount', () async {
        // arrange
        when(() => mockRemoteDataSource.getUnreadCount())
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.getUnreadCount();

        // assert
        expect(result, isA<Left<Failure, int>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (count) => fail('Expected Left but got Right'),
        );
      });

      test('should handle DioException in markAsRead', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        when(() => mockRemoteDataSource.markAsRead(tNotificationId))
            .thenThrow(dioError);

        // act
        final result = await repository.markAsRead(tNotificationId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle generic exception in markAsRead', () async {
        // arrange
        when(() => mockRemoteDataSource.markAsRead(tNotificationId))
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.markAsRead(tNotificationId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle DioException in markAllAsRead', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        when(() => mockRemoteDataSource.markAllAsRead())
            .thenThrow(dioError);

        // act
        final result = await repository.markAllAsRead();

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle generic exception in markAllAsRead', () async {
        // arrange
        when(() => mockRemoteDataSource.markAllAsRead())
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.markAllAsRead();

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle DioException in deleteNotification', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        when(() => mockRemoteDataSource.deleteNotification(tNotificationId))
            .thenThrow(dioError);

        // act
        final result = await repository.deleteNotification(tNotificationId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle generic exception in deleteNotification', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteNotification(tNotificationId))
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.deleteNotification(tNotificationId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle DioException in acceptBookRequest', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        when(() => mockRemoteDataSource.acceptBookRequest(tNotificationId))
            .thenThrow(dioError);

        // act
        final result = await repository.acceptBookRequest(tNotificationId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle generic exception in acceptBookRequest', () async {
        // arrange
        when(() => mockRemoteDataSource.acceptBookRequest(tNotificationId))
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.acceptBookRequest(tNotificationId);

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle DioException in rejectBookRequest', () async {
        // arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        when(() => mockRemoteDataSource.rejectBookRequest(tNotificationId, any()))
            .thenThrow(dioError);

        // act
        final result = await repository.rejectBookRequest(tNotificationId, 'reason');

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });

      test('should handle generic exception in rejectBookRequest', () async {
        // arrange
        when(() => mockRemoteDataSource.rejectBookRequest(tNotificationId, any()))
            .thenThrow(Exception('Generic error'));

        // act
        final result = await repository.rejectBookRequest(tNotificationId, 'reason');

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    group('acceptBookRequest with BookRequestNotificationModel', () {
      test('should update BookRequestNotificationModel data correctly', () async {
        // arrange
        final bookRequestNotificationModel = BookRequestNotificationModel(
          id: tNotificationId,
          title: 'Book Request',
          message: 'Someone wants to borrow your book',
          type: NotificationType.bookRequest,
          isRead: false,
          timestamp: DateTime.now(),
          bookRequestData: const BookRequestData(
            bookId: 'book_1',
            bookTitle: 'Test Book',
            requesterId: 'user_1',
            requesterName: 'Test User',
            requesterEmail: 'test@example.com',
            requestType: 'borrow',
            status: 'pending',
          ),
        );

        when(() => mockRemoteDataSource.acceptBookRequest(tNotificationId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => [bookRequestNotificationModel]);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.acceptBookRequest(tNotificationId);

        // assert
        verify(() => mockRemoteDataSource.acceptBookRequest(tNotificationId));
        verify(() => mockLocalDataSource.getCachedNotifications());
        verify(() => mockLocalDataSource.cacheNotifications(any()));
        expect(result, isA<Right<Failure, void>>());
      });

      test('should handle notification with null data in acceptBookRequest', () async {
        // arrange
        final notificationWithNullData = BookRequestNotificationModel(
          id: tNotificationId,
          title: 'Book Request',
          message: 'Someone wants to borrow your book',
          type: NotificationType.bookRequest,
          isRead: false,
          timestamp: DateTime.now(),
          bookRequestData: null,
        );

        when(() => mockRemoteDataSource.acceptBookRequest(tNotificationId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.getCachedNotifications())
            .thenAnswer((_) async => [notificationWithNullData]);
        when(() => mockLocalDataSource.cacheNotifications(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.acceptBookRequest(tNotificationId);

        // assert
        verify(() => mockRemoteDataSource.acceptBookRequest(tNotificationId));
        verify(() => mockLocalDataSource.getCachedNotifications());
        verify(() => mockLocalDataSource.cacheNotifications(any()));
        expect(result, isA<Right<Failure, void>>());
      });
    });

    group('dispose', () {
      test('should close the stream controller', () {
        // act
        repository.dispose();

        // assert - no exceptions should be thrown
        expect(() => repository.dispose(), returnsNormally);
      });
    });
  });
}
