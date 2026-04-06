import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/accept_book_request_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/reject_book_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_cart_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_cart_request_usecase.dart';

class MockGetNotificationsUseCase extends Mock implements GetNotificationsUseCase {}
class MockGetUnreadCountUseCase extends Mock implements GetUnreadCountUseCase {}
class MockMarkNotificationAsReadUseCase extends Mock implements MarkNotificationAsReadUseCase {}
class MockMarkAllNotificationsAsReadUseCase extends Mock implements MarkAllNotificationsAsReadUseCase {}
class MockDeleteNotificationUseCase extends Mock implements DeleteNotificationUseCase {}
class MockWatchNotificationsUseCase extends Mock implements WatchNotificationsUseCase {}
class MockAcceptBookRequestUseCase extends Mock implements AcceptBookRequestUseCase {}
class MockRejectBookRequestUseCase extends Mock implements RejectBookRequestUseCase {}
class MockAcceptCartRequestUseCase extends Mock implements AcceptCartRequestUseCase {}
class MockRejectCartRequestUseCase extends Mock implements RejectCartRequestUseCase {}

void main() {
  late NotificationsBloc bloc;
  late MockGetNotificationsUseCase mockGetNotificationsUseCase;
  late MockGetUnreadCountUseCase mockGetUnreadCountUseCase;
  late MockMarkNotificationAsReadUseCase mockMarkNotificationAsReadUseCase;
  late MockMarkAllNotificationsAsReadUseCase mockMarkAllNotificationsAsReadUseCase;
  late MockDeleteNotificationUseCase mockDeleteNotificationUseCase;
  late MockWatchNotificationsUseCase mockWatchNotificationsUseCase;
  late MockAcceptBookRequestUseCase mockAcceptBookRequestUseCase;
  late MockRejectBookRequestUseCase mockRejectBookRequestUseCase;
  late MockAcceptCartRequestUseCase mockAcceptCartRequestUseCase;
  late MockRejectCartRequestUseCase mockRejectCartRequestUseCase;

  setUp(() {
    mockGetNotificationsUseCase = MockGetNotificationsUseCase();
    mockGetUnreadCountUseCase = MockGetUnreadCountUseCase();
    mockMarkNotificationAsReadUseCase = MockMarkNotificationAsReadUseCase();
    mockMarkAllNotificationsAsReadUseCase = MockMarkAllNotificationsAsReadUseCase();
    mockDeleteNotificationUseCase = MockDeleteNotificationUseCase();
    mockWatchNotificationsUseCase = MockWatchNotificationsUseCase();
    mockAcceptBookRequestUseCase = MockAcceptBookRequestUseCase();
    mockRejectBookRequestUseCase = MockRejectBookRequestUseCase();
    mockAcceptCartRequestUseCase = MockAcceptCartRequestUseCase();
    mockRejectCartRequestUseCase = MockRejectCartRequestUseCase();

    when(() => mockWatchNotificationsUseCase())
        .thenAnswer((_) => Stream.value([]));
    when(() => mockMarkAllNotificationsAsReadUseCase())
      .thenAnswer((_) async => const Right(null));
    when(() => mockDeleteNotificationUseCase(any()))
      .thenAnswer((_) async => const Right(null));

    bloc = NotificationsBloc(
      getNotificationsUseCase: mockGetNotificationsUseCase,
      getUnreadCountUseCase: mockGetUnreadCountUseCase,
      markNotificationAsReadUseCase: mockMarkNotificationAsReadUseCase,
      markAllNotificationsAsReadUseCase: mockMarkAllNotificationsAsReadUseCase,
      deleteNotificationUseCase: mockDeleteNotificationUseCase,
      watchNotificationsUseCase: mockWatchNotificationsUseCase,
      acceptBookRequestUseCase: mockAcceptBookRequestUseCase,
      rejectBookRequestUseCase: mockRejectBookRequestUseCase,
      acceptCartRequestUseCase: mockAcceptCartRequestUseCase,
      rejectCartRequestUseCase: mockRejectCartRequestUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('AcceptCartRequest Event Tests', () {
    final testNotification = AppNotification(
      id: 'notif123',
      title: 'Cart Request',
      message: 'Someone wants to rent your book',
      timestamp: DateTime.now(),
      type: NotificationType.cartRequestReceived,
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'should emit action loading and success states when accepting cart request',
      build: () {
        when(() => mockGetNotificationsUseCase.call())
            .thenAnswer((_) async => Right([testNotification]));
        when(() => mockGetUnreadCountUseCase.call())
            .thenAnswer((_) async => const Right(1));
        when(() => mockAcceptCartRequestUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) {
        // First load notifications
        bloc.add(const LoadNotifications());
        return bloc.stream.firstWhere((state) => state is NotificationsLoaded).then((_) {
          // Then accept cart request
          bloc.add(const AcceptCartRequest(notificationId: 'notif123'));
        });
      },
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const NotificationsLoading(),
        isA<NotificationsLoaded>(),
        isA<NotificationActionLoading>(),
        isA<NotificationActionSuccess>()
            .having(
              (state) => state.message,
              'message',
              'Cart request accepted successfully',
            ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'should not accept cart request when not in loaded state',
      build: () => bloc,
      act: (bloc) => bloc.add(const AcceptCartRequest(notificationId: 'notif123')),
      expect: () => [],
    );
  });

  group('RejectCartRequest Event Tests', () {
    final testNotification = AppNotification(
      id: 'notif123',
      title: 'Cart Request',
      message: 'Someone wants to buy your book',
      timestamp: DateTime.now(),
      type: NotificationType.cartRequestReceived,
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'should emit action loading and success states when rejecting cart request',
      build: () {
        when(() => mockGetNotificationsUseCase.call())
            .thenAnswer((_) async => Right([testNotification]));
        when(() => mockGetUnreadCountUseCase.call())
            .thenAnswer((_) async => const Right(1));
        when(() => mockRejectCartRequestUseCase.call(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) {
        // First load notifications
        bloc.add(const LoadNotifications());
        return bloc.stream.firstWhere((state) => state is NotificationsLoaded).then((_) {
          // Then reject cart request
          bloc.add(const RejectCartRequest(
            notificationId: 'notif123',
            reason: 'Book not available',
          ));
        });
      },
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const NotificationsLoading(),
        isA<NotificationsLoaded>(),
        isA<NotificationActionLoading>(),
        isA<NotificationActionSuccess>()
            .having(
              (state) => state.message,
              'message',
              'Cart request rejected successfully',
            ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'should handle rejection without reason',
      build: () {
        when(() => mockGetNotificationsUseCase.call())
            .thenAnswer((_) async => Right([testNotification]));
        when(() => mockGetUnreadCountUseCase.call())
            .thenAnswer((_) async => const Right(1));
        when(() => mockRejectCartRequestUseCase.call(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) {
        bloc.add(const LoadNotifications());
        return bloc.stream.firstWhere((state) => state is NotificationsLoaded).then((_) {
          bloc.add(const RejectCartRequest(notificationId: 'notif123'));
        });
      },
      wait: const Duration(milliseconds: 300),
      expect: () => [
        const NotificationsLoading(),
        isA<NotificationsLoaded>(),
        isA<NotificationActionLoading>(),
        isA<NotificationActionSuccess>(),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'should not reject cart request when not in loaded state',
      build: () => bloc,
      act: (bloc) => bloc.add(const RejectCartRequest(notificationId: 'notif123')),
      expect: () => [],
    );
  });

  group('Cart Request Event Props Tests', () {
    test('AcceptCartRequest should have correct props', () {
      const event = AcceptCartRequest(notificationId: 'notif123');
      expect(event.props, ['notif123']);
    });

    test('RejectCartRequest should have correct props with reason', () {
      const event = RejectCartRequest(
        notificationId: 'notif123',
        reason: 'Not available',
      );
      expect(event.props, ['notif123', 'Not available']);
    });

    test('RejectCartRequest should have correct props without reason', () {
      const event = RejectCartRequest(notificationId: 'notif123');
      expect(event.props, ['notif123', null]);
    });

    test('AcceptCartRequest events with same id should be equal', () {
      const event1 = AcceptCartRequest(notificationId: 'notif123');
      const event2 = AcceptCartRequest(notificationId: 'notif123');
      expect(event1, equals(event2));
    });

    test('RejectCartRequest events with same id and reason should be equal', () {
      const event1 = RejectCartRequest(
        notificationId: 'notif123',
        reason: 'Test reason',
      );
      const event2 = RejectCartRequest(
        notificationId: 'notif123',
        reason: 'Test reason',
      );
      expect(event1, equals(event2));
    });
  });
}
