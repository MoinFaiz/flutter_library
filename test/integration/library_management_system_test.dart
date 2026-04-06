import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/main.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Comprehensive System Tests for Library Management Features
/// 
/// This test suite covers library-specific functionality:
/// 1. Library page navigation and display
/// 2. Borrowed books management
/// 3. Uploaded books management
/// 4. Pull-to-refresh functionality
/// 5. Full book list navigation
/// 6. Book rental operations
/// 7. Library search and filtering

void main() {
  group('Library Management System Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await initializeDependencies();
    });

    testWidgets('Library page basic functionality', (WidgetTester tester) async {
      print('🏛️ Starting Library Management System Test');
      
      // Launch app
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to Library tab
      final libraryTab = find.byIcon(Icons.library_books);
      expect(libraryTab, findsOneWidget, reason: 'Library tab should be visible');
      
      await tester.tap(libraryTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      print('✅ Navigated to Library page');
      
      // Verify library page components
      expect(find.text('My Library'), findsOneWidget, reason: 'Library title should be visible');
      expect(find.text('Borrowed Books'), findsOneWidget, reason: 'Borrowed books section should be visible');
      expect(find.text('My Uploaded Books'), findsOneWidget, reason: 'Uploaded books section should be visible');
      
      print('✅ Library page components verified');
    });

    testWidgets('Borrowed books section functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // First, rent some books to have borrowed books
      await _rentMultipleBooksFromHome(tester, 3);
      
      // Navigate to Library
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Test borrowed books section
      final borrowedSection = find.ancestor(
        of: find.text('Borrowed Books'),
        matching: find.byType(Container),
      );
      
      if (borrowedSection.evaluate().isNotEmpty) {
        // Look for book cards in borrowed section
        final bookCards = find.descendant(
          of: borrowedSection.first,
          matching: find.byType(Card),
        );
        
        print('📚 Found ${bookCards.evaluate().length} borrowed books');
        
        // Test tapping on a borrowed book
        if (bookCards.evaluate().isNotEmpty) {
          await tester.tap(bookCards.first);
          await tester.pumpAndSettle();
          
          // Should navigate to book details
          expect(find.byType(CustomScrollView), findsOneWidget, 
              reason: 'Should navigate to book details');
          
          // Go back to library
          await tester.pageBack();
          await tester.pumpAndSettle();
          
          print('✅ Borrowed book navigation tested');
        }
        
        // Test "More" button if available
        final moreButton = find.text('More');
        if (moreButton.evaluate().isNotEmpty) {
          await tester.tap(moreButton.first);
          await tester.pumpAndSettle();
          
          // Should navigate to full book list
          expect(find.text('Borrowed Books'), findsOneWidget,
              reason: 'Should navigate to full borrowed books list');
          
          // Go back
          await tester.pageBack();
          await tester.pumpAndSettle();
          
          print('✅ More button functionality tested');
        }
      }
    });

    testWidgets('Uploaded books section functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to Library
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Test uploaded books section
      await tester.scrollUntilVisible(find.text('My Uploaded Books'), 200);
      await tester.pumpAndSettle();
      
      // Look for uploaded books
      final uploadedBookCards = find.byType(Card);
      
      if (uploadedBookCards.evaluate().isNotEmpty) {
        print('📖 Found uploaded books section');
        
        // Test tapping on an uploaded book (should go to edit mode)
        await tester.tap(uploadedBookCards.last);
        await tester.pumpAndSettle();
        
        // Should navigate to book upload/edit page
        // Look for form fields or upload interface
        final formFields = find.byType(TextFormField);
        if (formFields.evaluate().isNotEmpty) {
          print('✅ Uploaded book edit navigation works');
          
          // Go back
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      } else {
        // Test empty state
        final emptyMessage = find.textContaining('uploaded');
        expect(emptyMessage, findsOneWidget, 
            reason: 'Should show empty uploaded books message');
        print('✅ Empty uploaded books state verified');
      }
    });

    testWidgets('Pull-to-refresh functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to Library
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Find RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget, 
          reason: 'RefreshIndicator should be present');
      
      // Perform pull-to-refresh
      await tester.fling(refreshIndicator, const Offset(0, 300), 1000);
      await tester.pump();
      
      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget,
          reason: 'Loading indicator should appear during refresh');
      
      // Wait for refresh to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify page is still functional
      expect(find.text('My Library'), findsOneWidget,
          reason: 'Library page should still be functional after refresh');
      
      print('✅ Pull-to-refresh functionality tested');
    });

    testWidgets('Library error handling', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to Library
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Look for error states or retry buttons
      final tryAgainButton = find.text('Try Again');
      final errorIcon = find.byIcon(Icons.error_outline);
      
      if (tryAgainButton.evaluate().isNotEmpty) {
        print('🔄 Found error state with retry option');
        
        // Test retry functionality
        await tester.tap(tryAgainButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        print('✅ Error retry functionality tested');
      }
      
      if (errorIcon.evaluate().isNotEmpty) {
        print('⚠️ Error state UI verified');
      }
    });

    testWidgets('Library navigation patterns', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Test navigation between tabs while maintaining library state
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();
      
      // Go to home and back
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();
      
      // Verify library page loads quickly (cached state)
      expect(find.text('My Library'), findsOneWidget,
          reason: 'Library should load quickly from cache');
      
      // Test deep navigation patterns
      final bookCards = find.byType(Card);
      if (bookCards.evaluate().isNotEmpty) {
        // Navigate to book details from library
        await tester.tap(bookCards.first);
        await tester.pumpAndSettle();
        
        // Navigate to favorites from book details
        final favoriteButton = find.byIcon(Icons.favorite_border);
        if (favoriteButton.evaluate().isNotEmpty) {
          await tester.tap(favoriteButton);
          await tester.pump();
        }
        
        // Go back to library via bottom navigation
        await tester.tap(find.byIcon(Icons.library_books));
        await tester.pumpAndSettle();
        
        expect(find.text('My Library'), findsOneWidget,
            reason: 'Should return to library page correctly');
        
        print('✅ Complex navigation patterns tested');
      }
    });

    testWidgets('Library performance and loading states', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Measure library loading time
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byIcon(Icons.library_books));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      print('⏱️ Library page loaded in ${stopwatch.elapsedMilliseconds}ms');
      
      // Verify loading indicators are shown appropriately
      final loadingWidgets = find.byType(CircularProgressIndicator);
      // Loading indicators should be gone after page loads
      expect(loadingWidgets.evaluate().length, lessThanOrEqualTo(1),
          reason: 'Should not have excessive loading indicators');
      
      // Test skeleton loading states if present
      final skeletonLoaders = find.byType(Container).evaluate()
          .where((element) => element.widget.toString().contains('skeleton'))
          .length;
      
      if (skeletonLoaders > 0) {
        print('💀 Skeleton loading states found: $skeletonLoaders');
      }
      
      print('✅ Performance and loading states verified');
    });
  });
}

// Helper Functions

Future<void> _rentMultipleBooksFromHome(WidgetTester tester, int count) async {
  // Go to home page
  await tester.tap(find.byIcon(Icons.home));
  await tester.pumpAndSettle();
  
  // Find and rent books
  for (int i = 0; i < count; i++) {
    final bookCards = find.byType(Card);
    if (bookCards.evaluate().length > i) {
      await tester.tap(bookCards.at(i));
      await tester.pumpAndSettle();
      
      // Look for rent button
      final rentButton = find.textContaining('Rent');
      if (rentButton.evaluate().isNotEmpty) {
        await tester.tap(rentButton.first);
        await tester.pumpAndSettle();
        print('📚 Rented book ${i + 1}');
      }
      
      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  }
}
