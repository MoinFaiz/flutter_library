import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  group('Notifications Use Cases Tests', () {
    late MockNotificationsRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationsRepository();
    });

    final mockNotifications = [
      AppNotification(
        id: 'notif_1',
        title: 'New Book Available',
        message: 'A new book is available for rent.',
        timestamp: DateTime(2023, 6, 1),
        type: NotificationType.newBook,
        isRead: false,
      ),
      AppNotification(
        id: 'notif_2',
        title: 'Book Overdue',
        message: 'Your book is overdue. Please return it.',
        timestamp: DateTime(2023, 6, 2),
        type: NotificationType.overdue,
        isRead: true,
      ),
      AppNotification(
        id: 'notif_3',
        title: 'Book Request',
        message: 'Someone wants to borrow your book.',
        timestamp: DateTime(2023, 6, 3),
        type: NotificationType.bookRequest,
        isRead: false,
      ),
    ];

    group('GetNotificationsUseCase', () {
      late GetNotificationsUseCase useCase;

      setUp(() {
        useCase = GetNotificationsUseCase(mockRepository);
      });

      test('should return list of notifications when repository succeeds', () async {
        // Arrange
        when(() => mockRepository.getNotifications())
            .thenAnswer((_) async => Right(mockNotifications));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Right<Failure, List<AppNotification>>>());
        final notifications = result.fold((l) => null, (r) => r);
        expect(notifications, mockNotifications);
        expect(notifications?.length, 3);
        verify(() => mockRepository.getNotifications()).called(1);
      });

      test('should return failure when repository fails', () async {
        // Arrange
        when(() => mockRepository.getNotifications())
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Network error')));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ServerFailure>());
        expect(failure?.message, 'Network error');
        verify(() => mockRepository.getNotifications()).called(1);
      });

      test('should return empty list when no notifications exist', () async {
        // Arrange
        when(() => mockRepository.getNotifications())
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Right<Failure, List<AppNotification>>>());
        final notifications = result.fold((l) => null, (r) => r);
        expect(notifications, isEmpty);
        verify(() => mockRepository.getNotifications()).called(1);
      });

      test('should handle network failure', () async {
        // Arrange
        when(() => mockRepository.getNotifications())
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<NetworkFailure>());
      });

      test('should handle cache failure', () async {
        // Arrange
        when(() => mockRepository.getNotifications())
            .thenAnswer((_) async => const Left(CacheFailure('Cache expired')));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Left<Failure, List<AppNotification>>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<CacheFailure>());
        expect(failure?.message, 'Cache expired');
      });
    });

    group('MarkNotificationAsReadUseCase', () {
      late MarkNotificationAsReadUseCase useCase;

      setUp(() {
        useCase = MarkNotificationAsReadUseCase(mockRepository);
      });

      test('should mark notification as read when repository succeeds', () async {
        // Arrange
        const notificationId = 'notif_1';
        when(() => mockRepository.markAsRead(notificationId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(notificationId);

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockRepository.markAsRead(notificationId)).called(1);
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const notificationId = 'notif_1';
        when(() => mockRepository.markAsRead(notificationId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Update failed')));

        // Act
        final result = await useCase(notificationId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ServerFailure>());
        expect(failure?.message, 'Update failed');
        verify(() => mockRepository.markAsRead(notificationId)).called(1);
      });

      test('should handle validation failure for invalid notification ID', () async {
        // Arrange
        const invalidId = '';
        when(() => mockRepository.markAsRead(invalidId))
            .thenAnswer((_) async => const Left(ValidationFailure('Invalid notification ID')));

        // Act
        final result = await useCase(invalidId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Invalid notification ID');
      });

      test('should handle notification not found scenario', () async {
        // Arrange
        const nonExistentId = 'non_existent_id';
        when(() => mockRepository.markAsRead(nonExistentId))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Notification not found')));

        // Act
        final result = await useCase(nonExistentId);

        // Assert
        expect(result, isA<Left<Failure, void>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure?.message, 'Notification not found');
      });

      test('should handle concurrent marking of same notification', () async {
        // Arrange
        const notificationId = 'notif_1';
        when(() => mockRepository.markAsRead(notificationId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final futures = List.generate(3, (_) => useCase(notificationId));
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, isA<Right<Failure, void>>());
        }
        verify(() => mockRepository.markAsRead(notificationId)).called(3);
      });
    });

    group('GetUnreadCountUseCase', () {
      late GetUnreadCountUseCase useCase;

      setUp(() {
        useCase = GetUnreadCountUseCase(mockRepository);
      });

      test('should return unread count when repository succeeds', () async {
        // Arrange
        const unreadCount = 5;
        when(() => mockRepository.getUnreadCount())
            .thenAnswer((_) async => const Right(unreadCount));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Right<Failure, int>>());
        final count = result.fold((l) => null, (r) => r);
        expect(count, unreadCount);
        verify(() => mockRepository.getUnreadCount()).called(1);
      });

      test('should return zero when no unread notifications exist', () async {
        // Arrange
        when(() => mockRepository.getUnreadCount())
            .thenAnswer((_) async => const Right(0));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Right<Failure, int>>());
        final count = result.fold((l) => null, (r) => r);
        expect(count, 0);
        verify(() => mockRepository.getUnreadCount()).called(1);
      });

      test('should return failure when repository fails', () async {
        // Arrange
        when(() => mockRepository.getUnreadCount())
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Database error')));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Left<Failure, int>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ServerFailure>());
        expect(failure?.message, 'Database error');
        verify(() => mockRepository.getUnreadCount()).called(1);
      });

      test('should handle cache failure gracefully', () async {
        // Arrange
        when(() => mockRepository.getUnreadCount())
            .thenAnswer((_) async => const Left(CacheFailure('Cache unavailable')));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Left<Failure, int>>());
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<CacheFailure>());
      });

      test('should handle large unread counts correctly', () async {
        // Arrange
        const largeCount = 999;
        when(() => mockRepository.getUnreadCount())
            .thenAnswer((_) async => const Right(largeCount));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Right<Failure, int>>());
        final count = result.fold((l) => null, (r) => r);
        expect(count, largeCount);
      });

      test('should handle rapid successive calls correctly', () async {
        // Arrange
        when(() => mockRepository.getUnreadCount())
            .thenAnswer((_) async => const Right(3));

        // Act
        final futures = List.generate(5, (_) => useCase());
        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, isA<Right<Failure, int>>());
          final count = result.fold((l) => null, (r) => r);
          expect(count, 3);
        }
        verify(() => mockRepository.getUnreadCount()).called(5);
      });
    });

    group('Integration Scenarios', () {
      late GetNotificationsUseCase getNotificationsUseCase;
      late MarkNotificationAsReadUseCase markAsReadUseCase;
      late GetUnreadCountUseCase getUnreadCountUseCase;

      setUp(() {
        getNotificationsUseCase = GetNotificationsUseCase(mockRepository);
        markAsReadUseCase = MarkNotificationAsReadUseCase(mockRepository);
        getUnreadCountUseCase = GetUnreadCountUseCase(mockRepository);
      });

      test('should handle workflow: get notifications, mark as read, check count', () async {
        // Arrange
        when(() => mockRepository.getNotifications())
            .thenAnswer((_) async => Right(mockNotifications));
        when(() => mockRepository.markAsRead('notif_1'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getUnreadCount())
            .thenAnswer((_) async => const Right(1)); // One less after marking as read

        // Act
        final notificationsResult = await getNotificationsUseCase();
        final markAsReadResult = await markAsReadUseCase('notif_1');
        final countResult = await getUnreadCountUseCase();

        // Assert
        expect(notificationsResult, isA<Right<Failure, List<AppNotification>>>());
        expect(markAsReadResult, isA<Right<Failure, void>>());
        expect(countResult, isA<Right<Failure, int>>());
        
        final count = countResult.fold((l) => null, (r) => r);
        expect(count, 1);
      });

      test('should handle error propagation across use cases', () async {
        // Arrange
        when(() => mockRepository.getNotifications())
            .thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => mockRepository.markAsRead(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => mockRepository.getUnreadCount())
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // Act
        final results = await Future.wait([
          getNotificationsUseCase(),
          markAsReadUseCase('notif_1'),
          getUnreadCountUseCase(),
        ]);

        // Assert
        for (final result in results) {
          expect(result.isLeft(), true);
          final failure = result.fold((l) => l, (r) => null);
          expect(failure, isA<NetworkFailure>());
        }
      });
    });
  });
}
