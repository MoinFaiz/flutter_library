import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/book_request_card.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

void main() {
  group('BookRequestCard Widget Tests', () {
    late BookRequestNotification testBookRequestNotification;

    setUp(() {
      testBookRequestNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          requestMessage: 'Can I borrow this book please?',
          status: 'pending',
          offerPrice: 10.0,
          pickupLocation: 'Campus Library',
        ),
      );
    });

    Widget createTestWidget({
      required BookRequestNotification notification,
      VoidCallback? onTap,
      VoidCallback? onMarkAsRead,
      VoidCallback? onDelete,
      VoidCallback? onAccept,
      Function(String?)? onReject,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookRequestCard(
            notification: notification,
            onTap: onTap,
            onMarkAsRead: onMarkAsRead,
            onDelete: onDelete,
            onAccept: onAccept,
            onReject: onReject,
          ),
        ),
      );
    }

    testWidgets('displays book request information correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testBookRequestNotification));

      // Assert
      expect(find.text('Book Request'), findsOneWidget);
      expect(find.textContaining('Test Book Title'), findsOneWidget);
      expect(find.textContaining('John Doe'), findsOneWidget);
    });

    testWidgets('shows unread styling for unread notifications', (WidgetTester tester) async {
      // Arrange
      final unreadNotification = testBookRequestNotification.copyWith(isRead: false);

      // Act
      await tester.pumpWidget(createTestWidget(notification: unreadNotification));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 3);

      // Check for unread indicator (blue dot)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows read styling for read notifications', (WidgetTester tester) async {
      // Arrange
      final readNotification = testBookRequestNotification.copyWith(isRead: true);

      // Act
      await tester.pumpWidget(createTestWidget(notification: readNotification));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
    });

    testWidgets('displays book request details in info section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testBookRequestNotification));

      // Assert
      expect(find.textContaining('Book: Test Book Title'), findsOneWidget);
      expect(find.textContaining('Requested by: John Doe'), findsOneWidget);
    });

    testWidgets('shows accept and reject buttons for pending requests', (WidgetTester tester) async {
      // Arrange
      final pendingNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          requestMessage: 'Can I borrow this book please?',
          status: 'pending',
          offerPrice: 10.0,
          pickupLocation: 'Campus Library',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: pendingNotification,
        onAccept: () {},
        onReject: (reason) {},
      ));

      // Assert
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('hides action buttons for accepted requests', (WidgetTester tester) async {
      // Arrange
      final acceptedNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Request was accepted',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'accepted',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: acceptedNotification));

      // Assert
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });

    testWidgets('hides action buttons for rejected requests', (WidgetTester tester) async {
      // Arrange
      final rejectedNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Request was rejected',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'rejected',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: rejectedNotification));

      // Assert
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });

    testWidgets('displays correct status chip for pending requests', (WidgetTester tester) async {
      // Arrange
      final pendingNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'pending',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: pendingNotification));

      // Assert
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('displays correct status chip for accepted requests', (WidgetTester tester) async {
      // Arrange
      final acceptedNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Request was accepted',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'accepted',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: acceptedNotification));

      // Assert
      expect(find.text('Accepted'), findsOneWidget);
    });

    testWidgets('displays correct status chip for rejected requests', (WidgetTester tester) async {
      // Arrange
      final rejectedNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Request was rejected',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'rejected',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: rejectedNotification));

      // Assert
      expect(find.text('Rejected'), findsOneWidget);
    });

    testWidgets('handles accept callback correctly', (WidgetTester tester) async {
      // Arrange
      bool accepted = false;
      final pendingNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'pending',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: pendingNotification,
        onAccept: () => accepted = true,
        onReject: (reason) {},
      ));

      await tester.tap(find.text('Accept'));

      // Assert
      expect(accepted, isTrue);
    });

    testWidgets('handles reject callback with dialog', (WidgetTester tester) async {
      // Arrange
      String? rejectionReason;
      final pendingNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'pending',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: pendingNotification,
        onAccept: () {},
        onReject: (reason) => rejectionReason = reason,
      ));

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      // Should show reject dialog
      expect(find.text('Reject Request'), findsOneWidget);
      expect(find.text('Reason (optional)'), findsOneWidget);
      
      // Enter a reason and confirm
      await tester.enterText(find.byType(TextField), 'Not available');
      await tester.tap(find.text('Reject').last); // The button in the dialog
      await tester.pumpAndSettle();

      // Assert
      expect(rejectionReason, equals('Not available'));
    });

    testWidgets('handles reject without reason', (WidgetTester tester) async {
      // Arrange
      String? rejectionReason;
      final pendingNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'pending',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: pendingNotification,
        onAccept: () {},
        onReject: (reason) => rejectionReason = reason,
      ));

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      // Confirm rejection without entering reason
      await tester.tap(find.text('Reject').last); // The button in the dialog
      await tester.pumpAndSettle();

      // Assert - Should be null since no reason was provided
      expect(rejectionReason, isNull);
    });

    testWidgets('cancels reject dialog when cancel is tapped', (WidgetTester tester) async {
      // Arrange
      bool rejected = false;
      final pendingNotification = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'borrow',
          status: 'pending',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: pendingNotification,
        onAccept: () {},
        onReject: (reason) => rejected = true,
      ));

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      // Cancel the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(rejected, isFalse);
      expect(find.text('Reject Request'), findsNothing); // Dialog should be closed
    });

    testWidgets('displays offer price when available', (WidgetTester tester) async {
      // Arrange
      final notificationWithPrice = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to buy your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: const BookRequestData(
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          requesterId: 'user1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'buy',
          status: 'pending',
          offerPrice: 25.99,
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: notificationWithPrice));

      // Assert
      expect(find.textContaining('Offer: \$25.99'), findsOneWidget);
    });

    testWidgets('displays pickup location when available', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testBookRequestNotification));

      // Assert
      expect(find.textContaining('Location: Campus Library'), findsOneWidget);
    });

    testWidgets('displays request message when available', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testBookRequestNotification));

      // Assert
      expect(find.textContaining('Can I borrow this book please?'), findsOneWidget);
    });

    testWidgets('handles missing book data gracefully', (WidgetTester tester) async {
      // Arrange
      final notificationWithoutData = BookRequestNotification(
        id: '1',
        title: 'Book Request',
        message: 'Someone wants to borrow your book',
        type: NotificationType.bookRequest,
        isRead: false,
        timestamp: DateTime.now(),
        bookRequestData: null,
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: notificationWithoutData));

      // Assert
      expect(find.text('Book Request'), findsOneWidget);
      expect(find.textContaining('Book: Unknown'), findsOneWidget); // Should show "Unknown" for missing data
    });

    testWidgets('handles tap callback correctly', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: testBookRequestNotification,
        onTap: () => tapped = true,
      ));

      // Find the main card InkWell (first one)
      await tester.tap(find.byType(InkWell).first);

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('calls mark as read for unread notifications on tap', (WidgetTester tester) async {
      // Arrange
      bool markedAsRead = false;
      final unreadNotification = testBookRequestNotification.copyWith(isRead: false);

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: unreadNotification,
        onMarkAsRead: () => markedAsRead = true,
      ));

      await tester.tap(find.byType(InkWell).first);

      // Assert
      expect(markedAsRead, isTrue);
    });

    testWidgets('does not call mark as read for already read notifications on tap', (WidgetTester tester) async {
      // Arrange
      bool markedAsRead = false;
      final readNotification = testBookRequestNotification.copyWith(isRead: true);

      // Act
      await tester.pumpWidget(createTestWidget(
        notification: readNotification,
        onMarkAsRead: () => markedAsRead = true,
      ));

      await tester.tap(find.byType(InkWell).first);

      // Assert
      expect(markedAsRead, isFalse);
    });

    testWidgets('displays proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testBookRequestNotification));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets); // Multiple InkWell widgets expected
      expect(find.byType(Column), findsWidgets); // Multiple columns expected
      expect(find.byType(Row), findsWidgets); // Multiple rows expected
    });

    testWidgets('applies correct theme colors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(notification: testBookRequestNotification));

      // Assert - Check that widgets are rendered without exceptions
      expect(find.byType(BookRequestCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('formats timestamp correctly', (WidgetTester tester) async {
      // Arrange
      final recentNotification = testBookRequestNotification.copyWith(
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      );

      // Act
      await tester.pumpWidget(createTestWidget(notification: recentNotification));

      // Assert
      expect(find.textContaining('15m ago'), findsOneWidget);
    });
  });
}
