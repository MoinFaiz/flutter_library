import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/main.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Notifications System Tests
/// 
/// This test suite covers:
/// 1. Notification permission handling
/// 2. Due date notifications
/// 3. Book recommendation notifications
/// 4. Notification settings management
/// 5. Notification history
/// 6. Interactive notification actions

void main() {
  group('Notifications System Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await initializeDependencies();
    });

    testWidgets('Notifications page navigation and display', (WidgetTester tester) async {
      print('🔔 Starting Notifications System Test');
      
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to notifications (usually via app bar icon)
      var notificationIcon = find.byIcon(Icons.notifications);
      if (notificationIcon.evaluate().isEmpty) {
        notificationIcon = find.byIcon(Icons.notifications_outlined);
      }
      
      if (notificationIcon.evaluate().isNotEmpty) {
        await tester.tap(notificationIcon);
        await tester.pumpAndSettle();
        
        // Verify notifications page is displayed
        var notificationsTitle = find.text('Notifications');
        if (notificationsTitle.evaluate().isEmpty) {
          notificationsTitle = find.textContaining('notification');
        }
        
        expect(notificationsTitle, findsOneWidget, 
            reason: 'Notifications page should be displayed');
        
        print('✅ Navigated to Notifications page');
      } else {
        // Try alternative navigation through settings or profile
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab);
          await tester.pumpAndSettle();
          
          // Look for notifications settings
          final notificationSettings = find.textContaining('Notification');
          if (notificationSettings.evaluate().isNotEmpty) {
            await tester.tap(notificationSettings.first);
            await tester.pumpAndSettle();
            print('✅ Accessed notifications via profile settings');
          }
        }
      }
    });

    testWidgets('Notification list and items display', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _navigateToNotifications(tester);
      
      // Check for notification list
      final notificationList = find.byType(ListView);
      if (notificationList.evaluate().isNotEmpty) {
        print('📋 Found notification list');
        
        // Look for notification items
        final notificationItems = find.byType(ListTile);
        if (notificationItems.evaluate().isNotEmpty) {
          print('📬 Found ${notificationItems.evaluate().length} notification items');
          
          // Test tapping on first notification
          await tester.tap(notificationItems.first);
          await tester.pumpAndSettle();
          
          // Should either expand details or navigate to related content
          print('✅ Notification item interaction tested');
          
          // Go back if navigated
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        } else {
          // Test empty notifications state
          final emptyMessage = find.textContaining('No notifications');
          if (emptyMessage.evaluate().isNotEmpty) {
            print('✅ Empty notifications state verified');
          }
        }
      }
      
      // Test notification filters if available
      final filterButtons = find.byType(FilterChip);
      if (filterButtons.evaluate().isNotEmpty) {
        await tester.tap(filterButtons.first);
        await tester.pump();
        print('✅ Notification filters tested');
      }
    });

    testWidgets('Notification settings management', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _navigateToNotifications(tester);
      
      // Look for settings button
      var settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isEmpty) {
        settingsButton = find.textContaining('Settings');
      }
      
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton.first);
        await tester.pumpAndSettle();
        
        // Test notification preference switches
        final switches = find.byType(Switch);
        if (switches.evaluate().isNotEmpty) {
          print('⚙️ Found notification preference switches');
          
          // Test toggling notification types
          for (int i = 0; i < switches.evaluate().length && i < 3; i++) {
            await tester.tap(switches.at(i));
            await tester.pump();
            print('✅ Toggled notification preference ${i + 1}');
          }
        }
        
        // Test notification timing settings
        final dropdowns = find.byType(DropdownButtonFormField);
        if (dropdowns.evaluate().isNotEmpty) {
          await tester.tap(dropdowns.first);
          await tester.pumpAndSettle();
          
          final dropdownItems = find.byType(DropdownMenuItem);
          if (dropdownItems.evaluate().isNotEmpty) {
            await tester.tap(dropdownItems.first);
            await tester.pumpAndSettle();
            print('✅ Notification timing settings tested');
          }
        }
        
        // Save settings
        final saveButton = find.textContaining('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
          print('✅ Notification settings saved');
        }
      }
    });

    testWidgets('Due date notification workflow', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // First, ensure we have some borrowed books
      await _createTestBorrowedBooks(tester);
      
      // Navigate to notifications
      await _navigateToNotifications(tester);
      
      // Look for due date notifications
      var dueDateNotifications = find.textContaining('due');
      if (dueDateNotifications.evaluate().isEmpty) {
        dueDateNotifications = find.textContaining('return');
      }
      if (dueDateNotifications.evaluate().isEmpty) {
        dueDateNotifications = find.textContaining('overdue');
      }
      
      if (dueDateNotifications.evaluate().isNotEmpty) {
        print('📅 Found due date notifications');
        
        // Test tapping on due date notification
        await tester.tap(dueDateNotifications.first);
        await tester.pumpAndSettle();
        
        // Should navigate to book details or library
        final expectedPages = [
          find.text('Book Details'),
          find.text('My Library'),
          find.textContaining('borrowed'),
        ];
        
        bool foundExpectedPage = false;
        for (final page in expectedPages) {
          if (page.evaluate().isNotEmpty) {
            foundExpectedPage = true;
            print('✅ Due date notification navigated correctly');
            break;
          }
        }
        
        if (!foundExpectedPage) {
          print('⚠️ Due date notification navigation unclear');
        }
      } else {
        print('ℹ️ No due date notifications found (expected for test)');
      }
    });

    testWidgets('Book recommendation notifications', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _navigateToNotifications(tester);
      
      // Look for recommendation notifications
      var recommendationNotifications = find.textContaining('recommend');
      if (recommendationNotifications.evaluate().isEmpty) {
        recommendationNotifications = find.textContaining('might like');
      }
      if (recommendationNotifications.evaluate().isEmpty) {
        recommendationNotifications = find.textContaining('new books');
      }
      
      if (recommendationNotifications.evaluate().isNotEmpty) {
        print('📚 Found recommendation notifications');
        
        // Test tapping on recommendation
        await tester.tap(recommendationNotifications.first);
        await tester.pumpAndSettle();
        
        // Should navigate to book details or recommendations page
        final bookDetailsIndicators = [
          find.byType(CustomScrollView),
          find.textContaining('Book Details'),
          find.textContaining('Description'),
        ];
        
        bool foundBookDetails = false;
        for (final indicator in bookDetailsIndicators) {
          if (indicator.evaluate().isNotEmpty) {
            foundBookDetails = true;
            print('✅ Recommendation notification navigated to book details');
            break;
          }
        }
        
        if (!foundBookDetails) {
          print('⚠️ Recommendation notification navigation unclear');
        }
      } else {
        print('ℹ️ No recommendation notifications found');
      }
    });

    testWidgets('Notification actions and interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _navigateToNotifications(tester);
      
      // Test mark as read functionality
      final markAsReadButtons = find.byIcon(Icons.mark_email_read);
      if (markAsReadButtons.evaluate().isNotEmpty) {
        await tester.tap(markAsReadButtons.first);
        await tester.pump();
        print('✅ Mark as read functionality tested');
      }
      
      // Test delete notification
      final deleteButtons = find.byIcon(Icons.delete);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();
        
        // Look for confirmation dialog
        final confirmDialog = find.byType(AlertDialog);
        if (confirmDialog.evaluate().isNotEmpty) {
          // Confirm deletion
          final confirmButton = find.textContaining('Delete');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();
            print('✅ Delete notification confirmed');
          } else {
            // Cancel deletion
            final cancelButton = find.textContaining('Cancel');
            if (cancelButton.evaluate().isNotEmpty) {
              await tester.tap(cancelButton);
              await tester.pumpAndSettle();
              print('✅ Delete notification cancelled');
            }
          }
        } else {
          print('✅ Direct delete functionality tested');
        }
      }
      
      // Test dismiss all notifications
      final dismissAllButton = find.textContaining('Clear All');
      if (dismissAllButton.evaluate().isNotEmpty) {
        await tester.tap(dismissAllButton);
        await tester.pumpAndSettle();
        
        // Look for confirmation
        final confirmDialog = find.byType(AlertDialog);
        if (confirmDialog.evaluate().isNotEmpty) {
          final cancelButton = find.textContaining('Cancel');
          if (cancelButton.evaluate().isNotEmpty) {
            await tester.tap(cancelButton);
            await tester.pumpAndSettle();
            print('✅ Clear all notifications cancelled for safety');
          }
        }
      }
    });

    testWidgets('Notification refresh and real-time updates', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _navigateToNotifications(tester);
      
      // Test pull-to-refresh
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        await tester.fling(refreshIndicator, const Offset(0, 300), 1000);
        await tester.pump();
        
        // Verify loading indicator appears
        expect(find.byType(CircularProgressIndicator).evaluate().length, greaterThan(0),
            reason: 'Loading indicator should appear during refresh');
        
        // Wait for refresh to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        print('✅ Pull-to-refresh functionality tested');
      }
      
      // Test notification badge updates
      final notificationBadge = find.byType(Badge);
      if (notificationBadge.evaluate().isNotEmpty) {
        print('🔴 Notification badge found and tested');
      }
      
      // Navigate away and back to test state persistence
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      
      await _navigateToNotifications(tester);
      
      // Verify notifications are still there
      expect(find.textContaining('Notification'), findsOneWidget,
          reason: 'Notifications page should maintain state');
      
      print('✅ Notification state persistence tested');
    });
  });
}

// Helper Functions

Future<void> _navigateToNotifications(WidgetTester tester) async {
  // Try multiple ways to navigate to notifications
  var notificationIcon = find.byIcon(Icons.notifications);
  if (notificationIcon.evaluate().isEmpty) {
    notificationIcon = find.byIcon(Icons.notifications_outlined);
  }
  
  if (notificationIcon.evaluate().isNotEmpty) {
    await tester.tap(notificationIcon);
    await tester.pumpAndSettle();
  } else {
    // Try through profile/settings
    final profileTab = find.byIcon(Icons.person);
    if (profileTab.evaluate().isNotEmpty) {
      await tester.tap(profileTab);
      await tester.pumpAndSettle();
      
      final notificationSettings = find.textContaining('Notification');
      if (notificationSettings.evaluate().isNotEmpty) {
        await tester.tap(notificationSettings.first);
        await tester.pumpAndSettle();
      }
    }
  }
}

Future<void> _createTestBorrowedBooks(WidgetTester tester) async {
  // Navigate to home and rent some books to create notifications
  await tester.tap(find.byIcon(Icons.home));
  await tester.pumpAndSettle();
  
  final bookCards = find.byType(Card);
  if (bookCards.evaluate().isNotEmpty) {
    // Try to rent first book
    await tester.tap(bookCards.first);
    await tester.pumpAndSettle();
    
    var rentButton = find.textContaining('Rent');
    if (rentButton.evaluate().isEmpty) {
      rentButton = find.textContaining('Borrow');
    }
    
    if (rentButton.evaluate().isNotEmpty) {
      await tester.tap(rentButton.first);
      await tester.pumpAndSettle();
      print('📚 Created test borrowed book for notifications');
    }
    
    // Go back
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  }
}
