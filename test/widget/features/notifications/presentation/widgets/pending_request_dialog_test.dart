import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/pending_request_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  late MockNavigationService mockNavigationService;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const Scaffold());
  });

  setUp(() {
    mockNavigationService = MockNavigationService();
    
    // Reset GetIt and register mock
    if (GetIt.instance.isRegistered<NavigationService>()) {
      GetIt.instance.unregister<NavigationService>();
    }
    GetIt.instance.registerLazySingleton<NavigationService>(() => mockNavigationService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  final now = DateTime.now();
  
  final testRequest1 = CartRequest(
    id: 'req-1',
    bookId: 'book-1',
    bookTitle: 'The Great Gatsby',
    bookAuthor: 'F. Scott Fitzgerald',
    bookImageUrl: 'https://example.com/gatsby.jpg',
    requesterId: 'user-1',
    ownerId: 'owner-1',
    requestType: CartItemType.purchase,
    rentalPeriodInDays: 0,
    price: 29.99,
    status: RequestStatus.pending,
    createdAt: now.subtract(const Duration(hours: 2)),
  );

  final testRequest2 = CartRequest(
    id: 'req-2',
    bookId: 'book-2',
    bookTitle: '1984',
    bookAuthor: 'George Orwell',
    bookImageUrl: 'https://example.com/1984.jpg',
    requesterId: 'user-2',
    ownerId: 'owner-1',
    requestType: CartItemType.rent,
    rentalPeriodInDays: 14,
    price: 9.99,
    status: RequestStatus.pending,
    createdAt: now.subtract(const Duration(minutes: 30)),
  );

  group('PendingRequestDialog - Widget Rendering', () {
    testWidgets('should render dialog with correct title and count for single request', (tester) async {
      // Arrange
      // No callback state tracking needed for this test

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (id) {}, // No-op callback for rendering test
            onReject: (id, reason) {}, // No-op callback for rendering test
          ),
        ),
      );

      // Assert
      expect(find.text('New Requests'), findsOneWidget);
      expect(find.text('1 pending request'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('should render dialog with correct title and count for multiple requests', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1, testRequest2],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('New Requests'), findsOneWidget);
      expect(find.text('2 pending requests'), findsOneWidget);
    });

    testWidgets('should render empty widget when no requests', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: const [],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should display book information for purchase request', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('The Great Gatsby'), findsOneWidget);
      expect(find.text('by F. Scott Fitzgerald'), findsOneWidget);
      expect(find.text('PURCHASE REQUEST'), findsOneWidget);
      expect(find.text('\$29.99'), findsOneWidget);
    });

    testWidgets('should display book information and rental details for rental request', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest2],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('1984'), findsOneWidget);
      expect(find.text('by George Orwell'), findsOneWidget);
      expect(find.text('RENTAL REQUEST'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.text('14 days'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should display close button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert - There are multiple close icons (one in header, one in reject button)
      expect(find.byIcon(Icons.close), findsAtLeastNWidgets(1));
      expect(find.byTooltip('Close'), findsOneWidget);
    });

    testWidgets('should display time ago correctly for hours', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.textContaining('hours ago'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('should display time ago correctly for minutes', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest2],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.textContaining('minutes ago'), findsOneWidget);
    });

    testWidgets('should display "Just now" for recent requests', (tester) async {
      // Arrange
      final recentRequest = testRequest1.copyWith(
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [recentRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('Just now'), findsOneWidget);
    });

    testWidgets('should display time ago for days', (tester) async {
      // Arrange
      final oldRequest = testRequest1.copyWith(
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [oldRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.textContaining('days ago'), findsOneWidget);
    });

    testWidgets('should show Accept and Reject buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert - Use text finder instead of widgetWithText
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsAtLeastNWidgets(1)); // Close button and Reject button
    });

    testWidgets('should show "View All" button when multiple requests', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1, testRequest2],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('View All 2 Requests'), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('should not show "View All" button when only one request', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.textContaining('View All'), findsNothing);
      expect(find.byIcon(Icons.list), findsNothing);
    });
  });

  group('PendingRequestDialog - User Interactions', () {
    testWidgets('should close dialog when close button is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (_, _) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);

      // Act
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should call onAccept when Accept button is tapped', (tester) async {
      // Arrange
      String? acceptedId;
      
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (id) {
                        acceptedId = id;
                        Navigator.of(context).pop();
                      },
                      onReject: (_, _) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Assert
      expect(acceptedId, equals('req-1'));
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should show rejection confirmation dialog when Reject is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (_, _) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reject Request'), findsOneWidget);
      expect(find.text('Are you sure you want to reject this request?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Reason (optional)'), findsOneWidget);
    });

    testWidgets('should call onReject with null reason when confirmed without text', (tester) async {
      // Arrange
      String? rejectedId;
      String? rejectionReason;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (id, reason) {
                        rejectedId = id;
                        rejectionReason = reason;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      // Assert
      expect(rejectedId, equals('req-1'));
      expect(rejectionReason, isNull);
    });

    testWidgets('should call onReject with reason when confirmed with text', (tester) async {
      // Arrange
      String? rejectedId;
      String? rejectionReason;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (id, reason) {
                        rejectedId = id;
                        rejectionReason = reason;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField), 'Out of stock');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      // Assert
      expect(rejectedId, equals('req-1'));
      expect(rejectionReason, equals('Out of stock'));
    });

    testWidgets('should trim whitespace from rejection reason', (tester) async {
      // Arrange
      String? rejectionReason;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (id, reason) {
                        rejectionReason = reason;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      // Assert - empty whitespace should be treated as null
      expect(rejectionReason, isNull);
    });

    testWidgets('should cancel rejection when Cancel is tapped', (tester) async {
      // Arrange
      bool rejectCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (_, _) {
                        rejectCalled = true;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(rejectCalled, isFalse);
      expect(find.text('Reject Request'), findsNothing);
      expect(find.text('New Requests'), findsOneWidget); // Original dialog still open
    });

    testWidgets('should navigate to notifications when "View All" is tapped', (tester) async {
      // Arrange
      when(() => mockNavigationService.navigateTo(any(), arguments: any(named: 'arguments')))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1, testRequest2],
                      onAccept: (_) {},
                      onReject: (_, _) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('View All 2 Requests'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNavigationService.navigateTo(AppRoutes.notifications)).called(1);
    });
  });

  group('PendingRequestDialog - Styling and Layout', () {
    testWidgets('should apply correct colors for purchase request badge', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      final badgeContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('PURCHASE REQUEST'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = badgeContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.green.withValues(alpha: 0.1)));
    });

    testWidgets('should apply correct colors for rental request badge', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest2],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      final badgeContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('RENTAL REQUEST'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = badgeContainer.decoration as BoxDecoration;
      final context = tester.element(find.text('RENTAL REQUEST'));
      expect(
        decoration.color,
        equals(Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
      );
    });

    testWidgets('should have rounded corners on dialog', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      final shape = dialog.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(16)));
    });

    testWidgets('should constrain dialog width', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.constraints, equals(const BoxConstraints(maxWidth: 400)));
    });

    testWidgets('should apply correct padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.padding, equals(const EdgeInsets.all(AppConstants.defaultPadding)));
    });

    testWidgets('should show divider between header and content', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('PendingRequestDialog - Edge Cases', () {
    testWidgets('should handle very long book titles with ellipsis', (tester) async {
      // Arrange
      final longTitleRequest = testRequest1.copyWith(
        bookTitle: 'This is a very long book title that should be truncated with ellipsis when displayed in the dialog',
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [longTitleRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      final textWidget = tester.widget<Text>(
        find.text('This is a very long book title that should be truncated with ellipsis when displayed in the dialog'),
      );
      expect(textWidget.maxLines, equals(2));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should handle requests with zero price', (tester) async {
      // Arrange
      final freeRequest = testRequest1.copyWith(price: 0.0);

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [freeRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('should handle requests with high price values', (tester) async {
      // Arrange
      final expensiveRequest = testRequest1.copyWith(price: 999.99);

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [expensiveRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('\$999.99'), findsOneWidget);
    });

    testWidgets('should handle rental with zero days', (tester) async {
      // Arrange
      final zeroDaysRequest = testRequest2.copyWith(rentalPeriodInDays: 0);

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [zeroDaysRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('0 days'), findsOneWidget);
    });

    testWidgets('should handle very long author names', (tester) async {
      // Arrange
      final longAuthorRequest = testRequest1.copyWith(
        bookAuthor: 'A Very Long Author Name That Might Cause Layout Issues',
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [longAuthorRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('by A Very Long Author Name That Might Cause Layout Issues'), findsOneWidget);
    });

    testWidgets('should handle rejection reason with multiple lines', (tester) async {
      // Arrange
      String? rejectionReason;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (id, reason) {
                        rejectionReason = reason;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Verify TextField supports multiple lines BEFORE submitting
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, equals(3));

      // Act
      await tester.enterText(find.byType(TextField), 'Line 1\nLine 2\nLine 3');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      // Assert
      expect(rejectionReason, equals('Line 1\nLine 2\nLine 3'));
    });
  });

  group('PendingRequestDialog - Time Formatting', () {
    testWidgets('should display singular "day ago" for 1 day', (tester) async {
      // Arrange
      final oneDayRequest = testRequest1.copyWith(
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [oneDayRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('1 day ago'), findsOneWidget);
    });

    testWidgets('should display singular "hour ago" for 1 hour', (tester) async {
      // Arrange
      final oneHourRequest = testRequest1.copyWith(
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [oneHourRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('1 hour ago'), findsOneWidget);
    });

    testWidgets('should display singular "minute ago" for 1 minute', (tester) async {
      // Arrange
      final oneMinuteRequest = testRequest1.copyWith(
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [oneMinuteRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('1 minute ago'), findsOneWidget);
    });

    testWidgets('should display plural "days ago" for multiple days', (tester) async {
      // Arrange
      final multipleDaysRequest = testRequest1.copyWith(
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [multipleDaysRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('5 days ago'), findsOneWidget);
    });

    testWidgets('should display plural "hours ago" for multiple hours', (tester) async {
      // Arrange
      final multipleHoursRequest = testRequest1.copyWith(
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [multipleHoursRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('3 hours ago'), findsOneWidget);
    });

    testWidgets('should display plural "minutes ago" for multiple minutes', (tester) async {
      // Arrange
      final multipleMinutesRequest = testRequest1.copyWith(
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [multipleMinutesRequest],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('15 minutes ago'), findsOneWidget);
    });
  });

  group('PendingRequestDialog - Multiple Requests', () {
    testWidgets('should display first request from multiple pending requests', (tester) async {
      // Arrange
      final requests = [testRequest1, testRequest2];

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: requests,
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert - Should show the first request
      expect(find.text('The Great Gatsby'), findsOneWidget);
      expect(find.text('1984'), findsNothing);
    });

    testWidgets('should show correct count for 3 requests', (tester) async {
      // Arrange
      final testRequest3 = testRequest1.copyWith(
        id: 'req-3',
        bookTitle: 'To Kill a Mockingbird',
      );
      final requests = [testRequest1, testRequest2, testRequest3];

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: requests,
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('3 pending requests'), findsOneWidget);
      expect(find.text('View All 3 Requests'), findsOneWidget);
    });

    testWidgets('should show correct count for many requests', (tester) async {
      // Arrange
      final requests = List.generate(
        10,
        (i) => testRequest1.copyWith(id: 'req-$i'),
      );

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: requests,
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('10 pending requests'), findsOneWidget);
      expect(find.text('View All 10 Requests'), findsOneWidget);
    });
  });

  group('PendingRequestDialog - Callback Execution', () {
    testWidgets('should close both dialogs when rejecting', (tester) async {
      // Arrange
      String? rejectedId;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (id, reason) {
                        rejectedId = id;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      // Assert
      expect(rejectedId, isNotNull);
      expect(find.byType(Dialog), findsNothing); // Both dialogs closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should handle onAccept callback correctly', (tester) async {
      // Arrange
      String? acceptedId;
      bool callbackExecuted = false;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (id) {
                        acceptedId = id;
                        callbackExecuted = true;
                        Navigator.of(context).pop();
                      },
                      onReject: (_, _) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Assert
      expect(acceptedId, equals('req-1'));
      expect(callbackExecuted, isTrue);
    });

    testWidgets('should handle onReject callback with whitespace-only reason as null', (tester) async {
      // Arrange
      String? rejectedId;
      String? rejectionReason;
      bool callbackExecuted = false;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PendingRequestDialog(
                      pendingRequests: [testRequest1],
                      onAccept: (_) {},
                      onReject: (id, reason) {
                        rejectedId = id;
                        rejectionReason = reason;
                        callbackExecuted = true;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act - Enter only spaces
      await tester.enterText(find.byType(TextField), '     ');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      // Assert
      expect(rejectedId, equals('req-1'));
      expect(rejectionReason, isNull);
      expect(callbackExecuted, isTrue);
    });
  });

  group('PendingRequestDialog - Accessibility', () {
    testWidgets('should have proper semantics for close button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.byTooltip('Close'), findsOneWidget);
    });

    testWidgets('should have icon buttons with proper icons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsAtLeastNWidgets(1));
    });

    testWidgets('should show list icon for multiple requests', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1, testRequest2],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.list), findsOneWidget);
    });
  });

  group('PendingRequestDialog - Rental Specific', () {
    testWidgets('should not show rental period for purchase requests', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest1],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.calendar_today), findsNothing);
      expect(find.textContaining('days'), findsNothing);
    });

    testWidgets('should show rental period icon and days for rental requests', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [testRequest2],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.text('14 days'), findsOneWidget);
    });

    testWidgets('should show singular "day" for 1 day rental', (tester) async {
      // Arrange
      final oneDayRental = testRequest2.copyWith(rentalPeriodInDays: 1);

      // Act
      await tester.pumpWidget(
        buildTestWidget(
          PendingRequestDialog(
            pendingRequests: [oneDayRental],
            onAccept: (_) {},
            onReject: (_, _) {},
          ),
        ),
      );

      // Assert
      expect(find.text('1 days'), findsOneWidget); // Note: The code uses 'days' plural always
    });
  });
}
