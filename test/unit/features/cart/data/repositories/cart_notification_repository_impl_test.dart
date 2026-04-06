import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_local_datasource.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_remote_datasource.dart';
import 'package:flutter_library/features/cart/data/models/cart_notification_model.dart';
import 'package:flutter_library/features/cart/data/repositories/cart_notification_repository_impl.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartNotificationRemoteDataSource extends Mock
    implements CartNotificationRemoteDataSource {}

class MockCartNotificationLocalDataSource extends Mock
    implements CartNotificationLocalDataSource {}

void main() {
  late CartNotificationRepositoryImpl repository;
  late MockCartNotificationRemoteDataSource mockRemoteDataSource;
  late MockCartNotificationLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockCartNotificationRemoteDataSource();
    mockLocalDataSource = MockCartNotificationLocalDataSource();
    repository = CartNotificationRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final testNotification = CartNotificationModel(
    id: 'notif1',
    requestId: 'req1',
    bookId: 'book1',
    bookTitle: 'Test Book',
    bookAuthor: 'Test Author',
    bookImageUrl: 'https://example.com/image.jpg',
    message: 'Test notification',
    type: NotificationType.requestReceived,
    requestType: CartItemType.rent,
    isRead: false,
    createdAt: DateTime(2025, 10, 31),
  );

  group('getNotifications', () {
    test('should return notifications from remote datasource on success', () async {
      // Arrange
      when(() => mockRemoteDataSource.getNotifications())
          .thenAnswer((_) async => [testNotification]);
      when(() => mockLocalDataSource.cacheNotifications(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.getNotifications();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals([testNotification])),
      );
      verify(() => mockRemoteDataSource.getNotifications()).called(1);
      verify(() => mockLocalDataSource.cacheNotifications([testNotification])).called(1);
    });

    test('should return cached notifications when remote fails but cache has data', () async {
      // Arrange
      when(() => mockRemoteDataSource.getNotifications())
          .thenThrow(const ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedNotifications())
          .thenAnswer((_) async => [testNotification]);

      // Act
      final result = await repository.getNotifications();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals([testNotification])),
      );
      verify(() => mockRemoteDataSource.getNotifications()).called(1);
      verify(() => mockLocalDataSource.getCachedNotifications()).called(1);
    });

    test('should return ServerFailure when both remote and cache fail', () async {
      // Arrange
      when(() => mockRemoteDataSource.getNotifications())
          .thenThrow(const ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedNotifications())
          .thenThrow(Exception('Cache error'));

      // Act
      final result = await repository.getNotifications();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
    });

    test('should return ServerFailure when remote fails and cache is empty', () async {
      // Arrange
      when(() => mockRemoteDataSource.getNotifications())
          .thenThrow(const ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedNotifications())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getNotifications();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.getNotifications())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getNotifications();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getUnreadCount', () {
    test('should return unread count from remote datasource on success', () async {
      // Arrange
      when(() => mockRemoteDataSource.getUnreadCount())
          .thenAnswer((_) async => 5);
      when(() => mockLocalDataSource.cacheUnreadCount(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.getUnreadCount();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals(5)),
      );
      verify(() => mockRemoteDataSource.getUnreadCount()).called(1);
      verify(() => mockLocalDataSource.cacheUnreadCount(5)).called(1);
    });

    test('should return cached count when remote fails', () async {
      // Arrange
      when(() => mockRemoteDataSource.getUnreadCount())
          .thenThrow(const ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedUnreadCount())
          .thenAnswer((_) async => 3);

      // Act
      final result = await repository.getUnreadCount();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals(3)),
      );
      verify(() => mockRemoteDataSource.getUnreadCount()).called(1);
      verify(() => mockLocalDataSource.getCachedUnreadCount()).called(1);
    });

    test('should return ServerFailure when both remote and cache fail', () async {
      // Arrange
      when(() => mockRemoteDataSource.getUnreadCount())
          .thenThrow(const ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedUnreadCount())
          .thenThrow(Exception('Cache error'));

      // Act
      final result = await repository.getUnreadCount();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.getUnreadCount())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getUnreadCount();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('markAsRead', () {
    test('should return Right(null) when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.markAsRead(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.markAsRead('notif1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.markAsRead('notif1')).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.markAsRead(any()))
          .thenThrow(const ServerException('Failed to mark as read'));

      // Act
      final result = await repository.markAsRead('notif1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to mark as read'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.markAsRead(any()))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.markAsRead('notif1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('markAllAsRead', () {
    test('should return Right(null) when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.markAllAsRead())
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.markAllAsRead();

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.markAllAsRead()).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.markAllAsRead())
          .thenThrow(const ServerException('Failed to mark all as read'));

      // Act
      final result = await repository.markAllAsRead();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to mark all as read'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.markAllAsRead())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.markAllAsRead();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('deleteNotification', () {
    test('should return Right(null) when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteNotification(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.deleteNotification('notif1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.deleteNotification('notif1')).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteNotification(any()))
          .thenThrow(const ServerException('Failed to delete'));

      // Act
      final result = await repository.deleteNotification('notif1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to delete'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteNotification(any()))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.deleteNotification('notif1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('watchNotifications', () {
    test('should return stream from remote datasource', () {
      // Arrange
      final testStream = Stream.value([testNotification]);
      when(() => mockRemoteDataSource.watchNotifications())
          .thenAnswer((_) => testStream);

      // Act
      final result = repository.watchNotifications();

      // Assert
      expect(result, equals(testStream));
      verify(() => mockRemoteDataSource.watchNotifications()).called(1);
    });
  });
}
