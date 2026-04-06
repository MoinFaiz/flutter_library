import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_notifications_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_unread_notifications_count_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_event.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_state.dart';

class MockGetCartNotificationsUseCase extends Mock implements GetCartNotificationsUseCase {}
class MockGetUnreadNotificationsCountUseCase extends Mock implements GetUnreadNotificationsCountUseCase {}
class MockMarkNotificationAsReadUseCase extends Mock implements MarkNotificationAsReadUseCase {}

void main() {
  late CartNotificationBloc bloc;
  late MockGetCartNotificationsUseCase mockGetCartNotificationsUseCase;
  late MockGetUnreadNotificationsCountUseCase mockGetUnreadNotificationsCountUseCase;
  late MockMarkNotificationAsReadUseCase mockMarkNotificationAsReadUseCase;

  setUp(() {
    mockGetCartNotificationsUseCase = MockGetCartNotificationsUseCase();
    mockGetUnreadNotificationsCountUseCase = MockGetUnreadNotificationsCountUseCase();
    mockMarkNotificationAsReadUseCase = MockMarkNotificationAsReadUseCase();

    bloc = CartNotificationBloc(
      getCartNotificationsUseCase: mockGetCartNotificationsUseCase,
      getUnreadNotificationsCountUseCase: mockGetUnreadNotificationsCountUseCase,
      markNotificationAsReadUseCase: mockMarkNotificationAsReadUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CartNotificationBloc', () {
    final mockNotifications = [
      CartNotification(
        id: 'notif1',
        requestId: 'req1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: '',
        type: NotificationType.requestAccepted,
        requestType: CartItemType.rent,
        message: 'Your request was accepted',
        isRead: false,
        createdAt: DateTime(2025, 1, 1),
      ),
      CartNotification(
        id: 'notif2',
        requestId: 'req2',
        bookId: 'book2',
        bookTitle: 'Test Book 2',
        bookAuthor: 'Test Author 2',
        bookImageUrl: '',
        type: NotificationType.requestSent,
        requestType: CartItemType.purchase,
        message: 'Your request was sent',
        isRead: true,
        createdAt: DateTime(2025, 1, 2),
      ),
    ];

    test('initial state should be CartNotificationInitial', () {
      expect(bloc.state, equals(CartNotificationInitial()));
    });

    group('LoadCartNotifications', () {
      blocTest<CartNotificationBloc, CartNotificationState>(
        'emits [CartNotificationLoading, CartNotificationLoaded] when LoadCartNotifications succeeds',
        build: () {
          when(() => mockGetCartNotificationsUseCase())
              .thenAnswer((_) async => Right(mockNotifications));
          when(() => mockGetUnreadNotificationsCountUseCase())
              .thenAnswer((_) async => const Right(1));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCartNotifications()),
        expect: () => [
          CartNotificationLoading(),
          CartNotificationLoaded(notifications: mockNotifications, unreadCount: 1),
        ],
        verify: (_) {
          verify(() => mockGetCartNotificationsUseCase()).called(1);
          verify(() => mockGetUnreadNotificationsCountUseCase()).called(1);
        },
      );

      blocTest<CartNotificationBloc, CartNotificationState>(
        'emits [CartNotificationLoading, CartNotificationLoaded] with unreadCount 0 when count usecase fails',
        build: () {
          when(() => mockGetCartNotificationsUseCase())
              .thenAnswer((_) async => Right(mockNotifications));
          when(() => mockGetUnreadNotificationsCountUseCase())
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Count error')));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCartNotifications()),
        expect: () => [
          CartNotificationLoading(),
          CartNotificationLoaded(notifications: mockNotifications, unreadCount: 0),
        ],
      );

      blocTest<CartNotificationBloc, CartNotificationState>(
        'emits [CartNotificationLoading, CartNotificationError] when LoadCartNotifications fails',
        build: () {
          when(() => mockGetCartNotificationsUseCase())
              .thenAnswer((_) async => const Left(NetworkFailure(message: 'Network error')));
          when(() => mockGetUnreadNotificationsCountUseCase())
              .thenAnswer((_) async => const Right(0));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCartNotifications()),
        expect: () => [
          CartNotificationLoading(),
          const CartNotificationError('Network error'),
        ],
      );

      blocTest<CartNotificationBloc, CartNotificationState>(
        'emits loaded state with empty list when notifications are empty',
        build: () {
          when(() => mockGetCartNotificationsUseCase())
              .thenAnswer((_) async => const Right([]));
          when(() => mockGetUnreadNotificationsCountUseCase())
              .thenAnswer((_) async => const Right(0));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCartNotifications()),
        expect: () => [
          CartNotificationLoading(),
          const CartNotificationLoaded(notifications: [], unreadCount: 0),
        ],
      );
    });

    group('MarkCartNotificationAsRead', () {
      final loadedState = CartNotificationLoaded(
        notifications: mockNotifications,
        unreadCount: 1,
      );

      blocTest<CartNotificationBloc, CartNotificationState>(
        'updates notification and decrements unreadCount when marking as read succeeds',
        build: () {
          when(() => mockMarkNotificationAsReadUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => loadedState,
        act: (bloc) => bloc.add(const MarkCartNotificationAsRead('notif1')),
        expect: () {
          final updatedNotifications = [
            mockNotifications[0].copyWith(isRead: true),
            mockNotifications[1],
          ];
          return [
            CartNotificationLoaded(notifications: updatedNotifications, unreadCount: 0),
          ];
        },
        verify: (_) {
          verify(() => mockMarkNotificationAsReadUseCase('notif1')).called(1);
        },
      );

      blocTest<CartNotificationBloc, CartNotificationState>(
        'does not decrement unreadCount below 0',
        build: () {
          when(() => mockMarkNotificationAsReadUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => CartNotificationLoaded(notifications: mockNotifications, unreadCount: 0),
        act: (bloc) => bloc.add(const MarkCartNotificationAsRead('notif1')),
        expect: () {
          final updatedNotifications = [
            mockNotifications[0].copyWith(isRead: true),
            mockNotifications[1],
          ];
          return [
            CartNotificationLoaded(notifications: updatedNotifications, unreadCount: 0),
          ];
        },
      );

      blocTest<CartNotificationBloc, CartNotificationState>(
        'emits error and returns to previous state when marking as read fails',
        build: () {
          when(() => mockMarkNotificationAsReadUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to mark as read')));
          return bloc;
        },
        seed: () => loadedState,
        act: (bloc) => bloc.add(const MarkCartNotificationAsRead('notif1')),
        expect: () => [
          const CartNotificationError('Failed to mark as read'),
          loadedState,
        ],
      );

      blocTest<CartNotificationBloc, CartNotificationState>(
        'does nothing when current state is not CartNotificationLoaded',
        build: () => bloc,
        seed: () => CartNotificationInitial(),
        act: (bloc) => bloc.add(const MarkCartNotificationAsRead('notif1')),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockMarkNotificationAsReadUseCase(any()));
        },
      );

      blocTest<CartNotificationBloc, CartNotificationState>(
        'handles notification not found in list',
        build: () {
          when(() => mockMarkNotificationAsReadUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => loadedState,
        act: (bloc) => bloc.add(const MarkCartNotificationAsRead('nonexistent')),
        expect: () => [
          CartNotificationLoaded(notifications: mockNotifications, unreadCount: 0),
        ],
      );
    });

    group('RefreshCartNotifications', () {
      blocTest<CartNotificationBloc, CartNotificationState>(
        'triggers LoadCartNotifications',
        build: () {
          when(() => mockGetCartNotificationsUseCase())
              .thenAnswer((_) async => Right(mockNotifications));
          when(() => mockGetUnreadNotificationsCountUseCase())
              .thenAnswer((_) async => const Right(2));
          return bloc;
        },
        act: (bloc) => bloc.add(RefreshCartNotifications()),
        expect: () => [
          CartNotificationLoading(),
          CartNotificationLoaded(notifications: mockNotifications, unreadCount: 2),
        ],
        verify: (_) {
          verify(() => mockGetCartNotificationsUseCase()).called(1);
          verify(() => mockGetUnreadNotificationsCountUseCase()).called(1);
        },
      );
    });
  });
}
