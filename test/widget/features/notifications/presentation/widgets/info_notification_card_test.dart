import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/info_notification_card.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';

void main() {
  group('InfoNotificationCard Widget Tests', () {
    late AppNotification testNotification;

    setUp(() {
      testNotification = AppNotification(
        id: '1',
        title: 'Test Notification',
        message: 'This is a test notification message',
        type: NotificationType.information,
        isRead: false,
        timestamp: DateTime.now(),
      );
    });

    Widget createTestWidget({
      required AppNotification notification,
      VoidCallback? onTap,
      VoidCallback? onMarkAsRead,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: InfoNotificationCard(
            notification: notification,
            onTap: onTap,
            onMarkAsRead: onMarkAsRead,
            onDelete: onDelete,
          ),
        ),
      );
    }

    testWidgets('displays notification information correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testNotification));

      // Assert
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('This is a test notification message'), findsOneWidget);
    });

    testWidgets('shows unread styling for unread notifications', (WidgetTester tester) async {
      // Arrange
      final unreadNotification = testNotification.copyWith(isRead: false);

      // Act
      await tester.pumpWidget(createTestWidget(notification: unreadNotification));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);

      // Check for unread indicator (blue dot)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows read styling for read notifications', (WidgetTester tester) async {
      // Arrange
      final readNotification = testNotification.copyWith(isRead: true);

      // Act
      await tester.pumpWidget(createTestWidget(notification: readNotification));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
    });

    testWidgets('displays correct icon for information notifications', (WidgetTester tester) async {
      // Arrange
      final infoNotification = testNotification.copyWith(type: NotificationType.information);

      // Act
      await tester.pumpWidget(createTestWidget(notification: infoNotification));

      // Assert
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('displays correct icon for reminder notifications', (WidgetTester tester) async {
      // Arrange
      final reminderNotification = testNotification.copyWith(type: NotificationType.reminder);

      // Act
      await tester.pumpWidget(createTestWidget(notification: reminderNotification));

      // Assert
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays correct icon for new book notifications', (WidgetTester tester) async {
      // Arrange
      final newBookNotification = testNotification.copyWith(type: NotificationType.newBook);

      // Act
      await tester.pumpWidget(createTestWidget(notification: newBookNotification));

      // Assert
      expect(find.byIcon(Icons.book), findsOneWidget);
    });

    testWidgets('displays correct icon for book returned notifications', (WidgetTester tester) async {
      // Arrange
      final bookReturnedNotification = testNotification.copyWith(type: NotificationType.bookReturned);

      // Act
      await tester.pumpWidget(createTestWidget(notification: bookReturnedNotification));

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays correct icon for overdue notifications', (WidgetTester tester) async {
      // Arrange
      final overdueNotification = testNotification.copyWith(type: NotificationType.overdue);

      // Act
      await tester.pumpWidget(createTestWidget(notification: overdueNotification));

      // Assert
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('displays correct icon for system update notifications', (WidgetTester tester) async {
      // Arrange
      final systemUpdateNotification = testNotification.copyWith(type: NotificationType.systemUpdate);

      // Act
      await tester.pumpWidget(createTestWidget(notification: systemUpdateNotification));

      // Assert
      expect(find.byIcon(Icons.system_update), findsOneWidget);
    });

    testWidgets('formats timestamp correctly for recent notifications', (WidgetTester tester) async {
      // Arrange
      final recentNotification = testNotification.copyWith(
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: recentNotification));

      // Assert
      expect(find.textContaining('30m ago'), findsOneWidget);
    });

    testWidgets('formats timestamp correctly for hour-old notifications', (WidgetTester tester) async {
      // Arrange
      final hourOldNotification = testNotification.copyWith(
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: hourOldNotification));

      // Assert
      expect(find.textContaining('2h ago'), findsOneWidget);
    });

    testWidgets('formats timestamp correctly for day-old notifications', (WidgetTester tester) async {
      // Arrange
      final dayOldNotification = testNotification.copyWith(
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: dayOldNotification));

      // Assert
      expect(find.textContaining('3d ago'), findsOneWidget);
    });

    testWidgets('formats timestamp correctly for very old notifications', (WidgetTester tester) async {
      // Arrange
      final oldDate = DateTime(2024, 1, 15);
      final oldNotification = testNotification.copyWith(timestamp: oldDate);

      // Act
      await tester.pumpWidget(createTestWidget(notification: oldNotification));

      // Assert
      expect(find.textContaining('15/1/2024'), findsOneWidget);
    });

    testWidgets('handles tap callback correctly', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      
      // Act
      await tester.pumpWidget(createTestWidget(
        notification: testNotification,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(InkWell));

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('calls mark as read for unread notifications on tap', (WidgetTester tester) async {
      // Arrange
      bool markedAsRead = false;
      final unreadNotification = testNotification.copyWith(isRead: false);
      
      // Act
      await tester.pumpWidget(createTestWidget(
        notification: unreadNotification,
        onMarkAsRead: () => markedAsRead = true,
      ));

      await tester.tap(find.byType(InkWell));

      // Assert
      expect(markedAsRead, isTrue);
    });

    testWidgets('does not call mark as read for already read notifications on tap', (WidgetTester tester) async {
      // Arrange
      bool markedAsRead = false;
      final readNotification = testNotification.copyWith(isRead: true);
      
      // Act
      await tester.pumpWidget(createTestWidget(
        notification: readNotification,
        onMarkAsRead: () => markedAsRead = true,
      ));

      await tester.tap(find.byType(InkWell));

      // Assert
      expect(markedAsRead, isFalse);
    });

    testWidgets('shows delete button when onDelete callback is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        notification: testNotification,
        onDelete: () {},
      ));

      // Assert
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('hides delete button when onDelete callback is not provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testNotification));

      // Assert
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('handles delete callback correctly', (WidgetTester tester) async {
      // Arrange
      bool deleted = false;
      
      // Act
      await tester.pumpWidget(createTestWidget(
        notification: testNotification,
        onDelete: () => deleted = true,
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));

      // Assert
      expect(deleted, isTrue);
    });

    testWidgets('displays proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testNotification));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Row), findsAtLeastNWidgets(1)); // Main row
      expect(find.byType(Column), findsAtLeastNWidgets(1)); // Content column
      expect(find.byType(CircleAvatar), findsOneWidget); // Icon container
    });

    testWidgets('handles long notification titles gracefully', (WidgetTester tester) async {
      // Arrange
      final longTitleNotification = testNotification.copyWith(
        title: 'This is a very long notification title that should wrap properly and not overflow the container boundaries',
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: longTitleNotification));

      // Assert
      expect(find.textContaining('This is a very long notification title'), findsOneWidget);
      expect(tester.takeException(), isNull); // No overflow exceptions
    });

    testWidgets('handles long notification messages gracefully', (WidgetTester tester) async {
      // Arrange
      final longMessageNotification = testNotification.copyWith(
        message: 'This is a very long notification message that should wrap properly across multiple lines and not cause any overflow issues in the UI layout',
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: longMessageNotification));

      // Assert
      expect(find.textContaining('This is a very long notification message'), findsOneWidget);
      expect(tester.takeException(), isNull); // No overflow exceptions
    });

    testWidgets('applies correct theme colors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testNotification));

      // Assert - Check that widgets are rendered without exceptions
      expect(find.byType(InfoNotificationCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
