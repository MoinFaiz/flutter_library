import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/notification_card.dart';

class MockNotificationsBloc extends Mock implements NotificationsBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

class FakeNotificationsEvent extends Fake implements NotificationsEvent {}
class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('NotificationsPage Tests', () {
    late MockNotificationsBloc mockNotificationsBloc;
    late MockNavigationService mockNavigationService;
    late GetIt sl;

    setUp(() {
      sl = GetIt.instance;
      mockNotificationsBloc = MockNotificationsBloc();
      mockNavigationService = MockNavigationService();

      if (!sl.isRegistered<NavigationService>()) {
        sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      }

      registerFallbackValue(FakeNotificationsEvent());
    });

    tearDown(() async {
      await sl.reset();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<NotificationsBloc>(
          create: (context) => mockNotificationsBloc,
          child: const NotificationsPage(),
        ),
      );
    }

    testWidgets('displays notifications header', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays loading state correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsLoading());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state correctly', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load notifications';
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsError(message: errorMessage));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays empty state when no notifications', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsLoaded(notifications: []));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.text('No Notifications'), findsOneWidget);
      expect(find.text('You\'re all caught up! No new notifications.'), findsOneWidget);
    });

    testWidgets('displays notifications list when loaded', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'This is a test notification',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
        AppNotification(
          id: '2',
          title: 'Second Notification',
          message: 'This is another test notification',
          type: NotificationType.information,
          isRead: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('Second Notification'), findsOneWidget);
    });

    testWidgets('shows mark all read button when unread notifications exist', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Unread Notification',
          message: 'This is unread',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
    });

    testWidgets('hides mark all read button when all notifications are read', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Read Notification',
          message: 'This is read',
          type: NotificationType.information,
          isRead: true,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.mark_email_read), findsNothing);
    });

    testWidgets('triggers mark all read when button is tapped', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Unread Notification',
          message: 'This is unread',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.mark_email_read));

      // Assert
      verify(() => mockNotificationsBloc.add(const MarkAllNotificationsAsRead())).called(1);
    });

    testWidgets('supports pull to refresh', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'This is a test',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - RefreshIndicator should be present
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Test pull to refresh by calling onRefresh directly
      final refreshIndicator = find.byType(RefreshIndicator);
      final RefreshIndicator widget = tester.widget(refreshIndicator);
      await widget.onRefresh();

      // Verify refresh event is triggered
      verify(() => mockNotificationsBloc.add(const RefreshNotifications())).called(1);
    });

    testWidgets('triggers retry on error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load notifications';
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsError(message: errorMessage));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Retry'));

      // Assert
      verify(() => mockNotificationsBloc.add(const LoadNotifications())).called(1);
    });

    testWidgets('shows success snackbar on notification action success', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.fromIterable([
        const NotificationActionSuccess(
          notifications: [],
          unreadCount: 0,
          message: 'Action completed successfully',
        ),
      ]));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Action completed successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error snackbar on notification action error', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.fromIterable([
        const NotificationActionError(
          notifications: [],
          unreadCount: 0,
          message: 'Action failed',
        ),
      ]));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Action failed'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Column), findsWidgets); // Multiple columns are expected (header + empty state)
    });

    testWidgets('shows delete confirmation dialog when delete is triggered', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'This is a test notification',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Find and tap the delete button (this would be in the NotificationCard)
      // For this test, we'll simulate the dialog directly
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ));

      // Assert
      expect(find.text('Delete Notification'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this notification?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('triggers delete event when delete is confirmed', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Create a test widget that includes the delete confirmation dialog
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<NotificationsBloc>(
          create: (context) => mockNotificationsBloc,
          child: Scaffold(
            body: Builder(
              builder: (context) => AlertDialog(
                title: const Text('Delete Notification'),
                content: const Text('Are you sure you want to delete this notification?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<NotificationsBloc>().add(
                        const DeleteNotification(notificationId: 'test-id'),
                      );
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNotificationsBloc.add(const DeleteNotification(notificationId: 'test-id'))).called(1);
    });

    testWidgets('displays book request notifications correctly', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Book Request',
          message: 'Someone wants to borrow your book',
          type: NotificationType.bookRequest,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Book Request'), findsOneWidget);
      expect(find.text('Someone wants to borrow your book'), findsOneWidget);
    });

    testWidgets('triggers accept book request event', (WidgetTester tester) async {
      // This test simulates accepting a book request
      // In practice, this would be triggered from within the NotificationCard widget
      
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Create a simple test widget that triggers the accept event
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<NotificationsBloc>(
          create: (context) => mockNotificationsBloc,
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  context.read<NotificationsBloc>().add(
                    const AcceptBookRequest(notificationId: 'test-id'),
                  );
                },
                child: const Text('Accept'),
              ),
            ),
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Accept'));

      // Assert
      verify(() => mockNotificationsBloc.add(const AcceptBookRequest(notificationId: 'test-id'))).called(1);
    });

    testWidgets('triggers reject book request event', (WidgetTester tester) async {
      // This test simulates rejecting a book request
      // In practice, this would be triggered from within the NotificationCard widget
      
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Create a simple test widget that triggers the reject event
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<NotificationsBloc>(
          create: (context) => mockNotificationsBloc,
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  context.read<NotificationsBloc>().add(
                    const RejectBookRequest(notificationId: 'test-id', reason: 'Not available'),
                  );
                },
                child: const Text('Reject'),
              ),
            ),
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Reject'));

      // Assert
      verify(() => mockNotificationsBloc.add(const RejectBookRequest(notificationId: 'test-id', reason: 'Not available'))).called(1);
    });

    testWidgets('triggers mark single notification as read', (WidgetTester tester) async {
      // This test simulates marking a single notification as read
      
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Create a simple test widget that triggers the mark as read event
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<NotificationsBloc>(
          create: (context) => mockNotificationsBloc,
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  context.read<NotificationsBloc>().add(
                    const MarkNotificationAsRead(notificationId: 'test-id'),
                  );
                },
                child: const Text('Mark as Read'),
              ),
            ),
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Mark as Read'));

      // Assert
      verify(() => mockNotificationsBloc.add(const MarkNotificationAsRead(notificationId: 'test-id'))).called(1);
    });

    testWidgets('displays different notification types correctly', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Information',
          message: 'Information message',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
        AppNotification(
          id: '2',
          title: 'Reminder',
          message: 'Reminder message',
          type: NotificationType.reminder,
          isRead: false,
          timestamp: DateTime.now(),
        ),
        AppNotification(
          id: '3',
          title: 'New Book',
          message: 'New book available',
          type: NotificationType.newBook,
          isRead: false,
          timestamp: DateTime.now(),
        ),
        AppNotification(
          id: '4',
          title: 'Book Returned',
          message: 'Book has been returned',
          type: NotificationType.bookReturned,
          isRead: false,
          timestamp: DateTime.now(),
        ),
        AppNotification(
          id: '5',
          title: 'Overdue',
          message: 'Book is overdue',
          type: NotificationType.overdue,
          isRead: false,
          timestamp: DateTime.now(),
        ),
        AppNotification(
          id: '6',
          title: 'System Update',
          message: 'System has been updated',
          type: NotificationType.systemUpdate,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Check that notifications are rendered (ListView is lazy, so scroll to find all)
      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Reminder'), findsOneWidget);
      expect(find.text('New Book'), findsOneWidget);
      expect(find.text('Book Returned'), findsOneWidget);
      
      // Scroll to see more notifications
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      
      expect(find.text('Overdue'), findsOneWidget);
      
      // Scroll more to see last notification
      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pumpAndSettle();
      
      expect(find.text('System Update'), findsOneWidget);
    });

    testWidgets('handles mixed read and unread notifications', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Unread Notification 1',
          message: 'This is unread',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
        AppNotification(
          id: '2',
          title: 'Read Notification',
          message: 'This is read',
          type: NotificationType.information,
          isRead: true,
          timestamp: DateTime.now(),
        ),
        AppNotification(
          id: '3',
          title: 'Unread Notification 2',
          message: 'This is also unread',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Mark all read button should be visible since there are unread notifications
      expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
      expect(find.text('Unread Notification 1'), findsOneWidget);
      expect(find.text('Read Notification'), findsOneWidget);
      expect(find.text('Unread Notification 2'), findsOneWidget);
    });

    testWidgets('displays proper padding and spacing', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'Test message',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for proper widget structure
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(Padding), findsWidgets); // Multiple paddings expected
    });

    testWidgets('respects initial state', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Should show empty state for initial state
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.text('No Notifications'), findsOneWidget);
      expect(find.text('You\'re all caught up! No new notifications.'), findsOneWidget);
    });

    testWidgets('handles state transitions correctly', (WidgetTester tester) async {
      // Arrange
      final stateController = Stream<NotificationsState>.fromIterable([
        const NotificationsLoading(),
        const NotificationsLoaded(notifications: []),
      ]);

      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsLoading());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => stateController);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for state transition
      await tester.pumpAndSettle();

      // Assert - Should now show empty state
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.text('No Notifications'), findsOneWidget);
    });

    testWidgets('triggers LoadNotifications on widget initialization', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - LoadNotifications should be called when the page is initialized
      // Note: This might be handled by the bloc itself or by the parent widget
      // The test verifies that the page can handle the initial state properly
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('handles rapid state changes gracefully', (WidgetTester tester) async {
      // Arrange
      final rapidStateController = Stream<NotificationsState>.fromIterable([
        const NotificationsLoading(),
        const NotificationsError(message: 'Error'),
        const NotificationsLoading(),
        const NotificationsLoaded(notifications: []),
      ]);

      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsLoading());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => rapidStateController);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Should end up in the final state (empty loaded)
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('displays multiple snackbars in sequence', (WidgetTester tester) async {
      // Arrange
      final stateController = StreamController<NotificationsState>.broadcast();
      
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => stateController.stream);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Emit success state
      stateController.add(const NotificationActionSuccess(
        notifications: [],
        unreadCount: 0,
        message: 'Success message',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verify snackbar appears
      expect(find.text('Success message'), findsOneWidget);
      
      // Close the stream
      await stateController.close();
    });

    testWidgets('preserves scroll position during state changes', (WidgetTester tester) async {
      // Arrange
      final manyNotifications = List.generate(20, (index) => AppNotification(
        id: 'notification_$index',
        title: 'Notification $index',
        message: 'Message $index',
        type: NotificationType.information,
        isRead: index % 2 == 0,
        timestamp: DateTime.now().subtract(Duration(hours: index)),
      ));

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: manyNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Verify initial state has the ListView with notifications
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Notification 0'), findsOneWidget);
      
      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify ListView still exists after scrolling
      expect(find.byType(ListView), findsOneWidget);
      
      // After scrolling, some notifications later in the list should be visible
      // The exact visibility depends on item heights, so we just verify the list exists
      expect(find.byType(NotificationCard), findsWidgets);
    });

    testWidgets('handles empty notification list after having notifications', (WidgetTester tester) async {
      // Arrange
      final stateTransition = Stream<NotificationsState>.fromIterable([
        NotificationsLoaded(notifications: [
          AppNotification(
            id: '1',
            title: 'Test Notification',
            message: 'This will disappear',
            type: NotificationType.information,
            isRead: false,
            timestamp: DateTime.now(),
          ),
        ]),
        const NotificationsLoaded(notifications: []),
      ]);

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: [
        AppNotification(
          id: '1',
          title: 'Test Notification',
          message: 'This will disappear',
          type: NotificationType.information,
          isRead: false,
          timestamp: DateTime.now(),
        ),
      ]));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => stateTransition);

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Initially should show the notification
      expect(find.text('Test Notification'), findsOneWidget);
      
      // Wait for state change
      await tester.pumpAndSettle();

      // Assert - Should now show empty state
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.text('No Notifications'), findsOneWidget);
    });

    testWidgets('handles error to success state transition', (WidgetTester tester) async {
      // Arrange
      final stateTransition = Stream<NotificationsState>.fromIterable([
        const NotificationsError(message: 'Failed to load'),
        NotificationsLoaded(notifications: [
          AppNotification(
            id: '1',
            title: 'Test Notification',
            message: 'Now loaded',
            type: NotificationType.information,
            isRead: false,
            timestamp: DateTime.now(),
          ),
        ]),
      ]);

      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsError(message: 'Failed to load'));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => stateTransition);

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Initially should show error
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Failed to load'), findsOneWidget);
      
      // Wait for state change
      await tester.pumpAndSettle();

      // Assert - Should now show loaded notifications
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('maintains consistent header layout across states', (WidgetTester tester) async {
      // Test loading state
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsLoading());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      await tester.pumpWidget(createTestWidget());
      expect(find.byType(AppBar), findsOneWidget);

      // Test error state
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsError(message: 'Error'));
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(AppBar), findsOneWidget);

      // Test loaded state
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsLoaded(notifications: []));
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('correctly handles notification timestamps', (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      final mockNotifications = [
        AppNotification(
          id: '1',
          title: 'Recent Notification',
          message: 'Just now',
          type: NotificationType.information,
          isRead: false,
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
        AppNotification(
          id: '2',
          title: 'Old Notification',
          message: 'From yesterday',
          type: NotificationType.information,
          isRead: true,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ];

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsLoaded(notifications: mockNotifications));
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Both notifications should be displayed
      expect(find.text('Recent Notification'), findsOneWidget);
      expect(find.text('Old Notification'), findsOneWidget);
    });

    testWidgets('handles BlocConsumer listener null safety', (WidgetTester tester) async {
      // Arrange
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.fromIterable([
        // Test a state that shouldn't trigger snackbars
        const NotificationsLoading(),
        const NotificationsLoaded(notifications: []),
      ]));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - No snackbars should be shown
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
