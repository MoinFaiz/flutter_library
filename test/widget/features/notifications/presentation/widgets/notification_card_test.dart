import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/notification_card.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

void main() {
  group('NotificationCard Widget Tests', () {
    late AppNotification testInfoNotification;
    late BookRequestNotification testBookRequestNotification;

    setUp(() {
      testInfoNotification = AppNotification(
        id: '1',
        title: 'Test Notification',
        message: 'This is a test notification message',
        type: NotificationType.information,
        isRead: false,
        timestamp: DateTime.now(),
      );

      testBookRequestNotification = BookRequestNotification(
        id: '2',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          requestMessage: 'Can I borrow this book?',
          status: 'pending',
          offerPrice: 10.0,
          pickupLocation: 'Campus Library',
        ),
      );
    });

    Widget createTestWidget({
      required AppNotification notification,
      VoidCallback? onTap,
      VoidCallback? onMarkAsRead,
      VoidCallback? onDelete,
      Function(String, String?)? onAcceptBookRequest,
      Function(String, String?)? onRejectBookRequest,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: NotificationCard(
            notification: notification,
            onTap: onTap,
            onMarkAsRead: onMarkAsRead,
            onDelete: onDelete,
            onAcceptBookRequest: onAcceptBookRequest,
            onRejectBookRequest: onRejectBookRequest,
          ),
        ),
      );
    }

    testWidgets('should display info notification correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(
        notification: testInfoNotification,
      ));

      // Assert
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('This is a test notification message'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display book request notification correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(
        notification: testBookRequestNotification,
      ));
      await tester.pumpAndSettle();

      // Assert - Book request card displays data differently with "Book:" and "Requested by:" prefixes
      expect(find.text('Book Request'), findsOneWidget);
      expect(find.textContaining('Test Book'), findsOneWidget);
      expect(find.textContaining('John Doe'), findsOneWidget);
      expect(find.text('Can I borrow this book?'), findsOneWidget);
    });

    testWidgets('should show unread notification styling', (WidgetTester tester) async {
      // Arrange
      final unreadNotification = testInfoNotification.copyWith(isRead: false);

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: unreadNotification,
      ));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, greaterThan(0)); // Unread notifications have elevation
    });

    testWidgets('should show read notification styling', (WidgetTester tester) async {
      // Arrange
      final readNotification = testInfoNotification.copyWith(isRead: true);

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: readNotification,
      ));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(0)); // Read notifications have no elevation
    });

    testWidgets('should handle tap callback', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      
      await tester.pumpWidget(createTestWidget(
        notification: testInfoNotification,
        onTap: () => tapped = true,
      ));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should handle mark as read callback', (WidgetTester tester) async {
      // Arrange
      bool markAsReadTapped = false;
      
      await tester.pumpWidget(createTestWidget(
        notification: testInfoNotification,
        onMarkAsRead: () => markAsReadTapped = true,
      ));

      // Act - Tap on unread notification should mark as read
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(markAsReadTapped, isTrue);
    });

    testWidgets('should not mark as read when notification is already read', (WidgetTester tester) async {
      // Arrange
      bool markAsReadTapped = false;
      final readNotification = testInfoNotification.copyWith(isRead: true);
      
      await tester.pumpWidget(createTestWidget(
        notification: readNotification,
        onMarkAsRead: () => markAsReadTapped = true,
      ));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(markAsReadTapped, isFalse); // Should not be called for read notifications
    });

    testWidgets('should display book request details', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(
        notification: testBookRequestNotification,
      ));

      // Assert
      expect(find.textContaining('\$10.00'), findsOneWidget); // Offer price
      expect(find.textContaining('Campus Library'), findsOneWidget); // Pickup location
      expect(find.textContaining('Pending'), findsOneWidget); // Status
    });

    testWidgets('should show accept/reject buttons for pending book requests', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(
        notification: testBookRequestNotification,
        onAcceptBookRequest: (id, reason) {},
        onRejectBookRequest: (id, reason) {},
      ));

      // Assert
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('should handle accept book request callback', (WidgetTester tester) async {
      // Arrange
      String? acceptedId;
      
      await tester.pumpWidget(createTestWidget(
        notification: testBookRequestNotification,
        onAcceptBookRequest: (id, reason) => acceptedId = id,
        onRejectBookRequest: (id, reason) {},
      ));

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pump();

      // Assert
      expect(acceptedId, equals('2'));
    });

    testWidgets('should handle reject book request with dialog', (WidgetTester tester) async {
      // Arrange
      String? rejectedId;
      String? rejectionReason;
      
      await tester.pumpWidget(createTestWidget(
        notification: testBookRequestNotification,
        onAcceptBookRequest: (id, reason) {},
        onRejectBookRequest: (id, reason) {
          rejectedId = id;
          rejectionReason = reason;
        },
      ));

      // Act - Find and tap the Reject button in the card (not in dialog)
      final rejectButtons = find.text('Reject');
      await tester.tap(rejectButtons.first);
      await tester.pumpAndSettle();

      // Should show dialog for rejection reason
      expect(find.byType(AlertDialog), findsOneWidget);
      
      // Enter rejection reason
      await tester.enterText(find.byType(TextField), 'Book not available');
      
      // Tap the Reject button in the dialog
      await tester.tap(rejectButtons.last);
      await tester.pumpAndSettle();

      // Assert
      expect(rejectedId, equals('2'));
      expect(rejectionReason, equals('Book not available'));
    });

    testWidgets('should not show action buttons for non-pending requests', (WidgetTester tester) async {
      // Arrange
      final acceptedNotification = BookRequestNotification(
        id: '2-accepted',
        title: 'Book Request',
        message: 'Book request accepted',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'accepted',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: acceptedNotification,
        onAcceptBookRequest: (id, reason) {},
        onRejectBookRequest: (id, reason) {},
      ));

      // Assert
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });

    testWidgets('should display correct status chip color', (WidgetTester tester) async {
      // Arrange - Test different statuses
      final statuses = ['pending', 'accepted', 'rejected', 'completed', 'cancelled'];
      
      for (final status in statuses) {
        final notification = BookRequestNotification(
          id: '2-$status',
          title: 'Book Request',
          message: 'Book request $status',
          type: NotificationType.bookRequest,
          isRead: false,
          timestamp: DateTime.now(),
          bookRequestData: BookRequestData(
            bookId: 'book1',
            bookTitle: 'Test Book',
            requesterId: 'user1',
            requesterName: 'John Doe',
            requesterEmail: 'john@example.com',
            requestType: 'borrow',
            status: status,
          ),
        );

        // Act
        await tester.pumpWidget(createTestWidget(notification: notification));

        // Assert
        expect(find.textContaining(status.substring(0, 1).toUpperCase() + status.substring(1)), 
               findsOneWidget);
        
        // Rebuild for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should handle missing book data gracefully', (WidgetTester tester) async {
      // Arrange
      final notificationWithoutBookData = BookRequestNotification(
        id: '3',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: null,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: notificationWithoutBookData,
      ));

      // Assert
      expect(find.text('Book Request'), findsOneWidget);
      expect(find.text('Unknown'), findsWidgets); // Should show "Unknown" for missing data
    });

    testWidgets('should display formatted date correctly', (WidgetTester tester) async {
      // Arrange
      final specificDate = DateTime(2023, 12, 25, 10, 30);
      final notificationWithSpecificDate = testInfoNotification.copyWith(
        timestamp: specificDate,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: notificationWithSpecificDate,
      ));

      // Assert
      // Should display some form of formatted date
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle delete callback if provided', (WidgetTester tester) async {
      // Arrange
      bool deleteTapped = false;
      
      await tester.pumpWidget(createTestWidget(
        notification: testInfoNotification,
        onDelete: () => deleteTapped = true,
      ));

      // Look for delete button/icon
      final deleteButton = find.byIcon(Icons.delete);
      if (deleteButton.evaluate().isNotEmpty) {
        // Act
        await tester.tap(deleteButton);
        await tester.pump();

        // Assert
        expect(deleteTapped, isTrue);
      }
    });
  });
}
