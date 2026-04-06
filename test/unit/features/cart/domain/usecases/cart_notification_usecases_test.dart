import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_notification_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_notifications_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_unread_notifications_count_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartNotificationRepository extends Mock implements CartNotificationRepository {}

void main() {
  late MockCartNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockCartNotificationRepository();
  });

  final testNotification = CartNotification(
    id: 'notif1',
    requestId: 'req1',
    bookId: 'book1',
    bookTitle: 'Test Book',
    bookAuthor: 'Test Author',
    bookImageUrl: 'url',
    type: NotificationType.requestReceived,
    requestType: CartItemType.rent,
    message: 'New rental request',
    isRead: false,
    createdAt: DateTime(2025, 10, 31),
  );

  group('GetCartNotificationsUseCase', () {
    late GetCartNotificationsUseCase usecase;

    setUp(() {
      usecase = GetCartNotificationsUseCase(repository: mockRepository);
    });

    test('should get cart notifications successfully', () async {
      // Arrange
      final notifications = [testNotification];
      when(() => mockRepository.getNotifications())
          .thenAnswer((_) async => Right(notifications));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(notifications));
      verify(() => mockRepository.getNotifications()).called(1);
    });

    test('should return empty list when no notifications', () async {
      // Arrange
      when(() => mockRepository.getNotifications())
          .thenAnswer((_) async => const Right(<CartNotification>[]));

      // Act
      final result = await usecase();

      // Assert
      result.fold(
        (l) => fail('Should return right'),
        (notifs) => expect(notifs, <CartNotification>[]),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to fetch notifications');
      when(() => mockRepository.getNotifications())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getNotifications()).called(1);
    });

    test('should handle multiple notifications', () async {
      // Arrange
      final notif2 = testNotification.copyWith(id: 'notif2', isRead: true);
      final notifications = [testNotification, notif2];
      when(() => mockRepository.getNotifications())
          .thenAnswer((_) async => Right(notifications));

      // Act
      final result = await usecase();

      // Assert
      result.fold(
        (l) => fail('Should return right'),
        (notifs) {
          expect(notifs.length, 2);
          expect(notifs[0].isRead, false);
          expect(notifs[1].isRead, true);
        },
      );
    });

    test('should handle cache failure', () async {
      // Arrange
      const failure = CacheFailure('Cache error');
      when(() => mockRepository.getNotifications())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
    });
  });

  group('GetUnreadNotificationsCountUseCase', () {
    late GetUnreadNotificationsCountUseCase usecase;

    setUp(() {
      usecase = GetUnreadNotificationsCountUseCase(repository: mockRepository);
    });

    test('should get unread count successfully', () async {
      // Arrange
      when(() => mockRepository.getUnreadCount())
          .thenAnswer((_) async => const Right(5));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(5));
      verify(() => mockRepository.getUnreadCount()).called(1);
    });

    test('should return zero when no unread notifications', () async {
      // Arrange
      when(() => mockRepository.getUnreadCount())
          .thenAnswer((_) async => const Right(0));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(0));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to get count');
      when(() => mockRepository.getUnreadCount())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getUnreadCount()).called(1);
    });

    test('should handle large unread count', () async {
      // Arrange
      when(() => mockRepository.getUnreadCount())
          .thenAnswer((_) async => const Right(999));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(999));
    });
  });

  group('MarkNotificationAsReadUseCase', () {
    late MarkNotificationAsReadUseCase usecase;

    setUp(() {
      usecase = MarkNotificationAsReadUseCase(repository: mockRepository);
    });

    test('should mark notification as read successfully', () async {
      // Arrange
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase('notif1');

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.markAsRead('notif1')).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to mark as read');
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('notif1');

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.markAsRead('notif1')).called(1);
    });

    test('should handle not found failure', () async {
      // Arrange
      const failure = NotFoundFailure(message: 'Notification not found');
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('notif1');

      // Assert
      expect(result, const Left(failure));
    });

    test('should handle empty notification ID', () async {
      // Arrange
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase('');

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.markAsRead('')).called(1);
    });

    test('should handle network failure', () async {
      // Arrange
      const failure = NetworkFailure();
      when(() => mockRepository.markAsRead(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('notif1');

      // Assert
      expect(result, const Left(failure));
    });
  });
}
