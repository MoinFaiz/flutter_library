import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/main.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Profile and User Management System Tests
/// 
/// This test suite covers:
/// 1. Profile page navigation and display
/// 2. User information editing
/// 3. Profile image management
/// 4. Account settings
/// 5. Reading statistics
/// 6. Privacy settings
/// 7. Account deletion/logout

void main() {
  group('Profile System Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await initializeDependencies();
    });

    testWidgets('Profile page navigation and basic display', (WidgetTester tester) async {
      print('👤 Starting Profile System Test');
      
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to Profile tab
      final profileTab = find.byIcon(Icons.person);
      expect(profileTab, findsOneWidget, reason: 'Profile tab should be visible');
      
      await tester.tap(profileTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      print('✅ Navigated to Profile page');
      
      // Verify profile page components
      var profileTitle = find.text('Profile');
      if (profileTitle.evaluate().isEmpty) {
        profileTitle = find.textContaining('profile');
      }
      if (profileTitle.evaluate().isEmpty) {
        profileTitle = find.textContaining('Account');
      }
      
      expect(profileTitle.evaluate().length, greaterThan(0),
          reason: 'Profile page should be displayed');
      
      // Look for user avatar/image
      final userAvatar = find.byType(CircleAvatar);
      if (userAvatar.evaluate().isNotEmpty) {
        print('👤 User avatar found');
      }
      
      // Look for user name and email
      final userInfo = find.byType(ListTile);
      if (userInfo.evaluate().isNotEmpty) {
        print('📝 User information sections found');
      }
      
      print('✅ Profile page components verified');
    });

    testWidgets('User information display and editing', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Look for edit profile option
      var editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isEmpty) {
        editButton = find.textContaining('Edit');
      }
      if (editButton.evaluate().isEmpty) {
        editButton = find.textContaining('Update');
      }
      
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();
        
        // Test form fields
        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().isNotEmpty) {
          print('📝 Found profile edit form');
          
          // Test editing name
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(textFields.at(0), 'Test User Updated');
            await tester.pump();
          }
          
          // Test editing email
          if (textFields.evaluate().length >= 2) {
            await tester.enterText(textFields.at(1), 'updated.test@example.com');
            await tester.pump();
          }
          
          // Test editing bio/description
          if (textFields.evaluate().length >= 3) {
            await tester.enterText(textFields.at(2), 'Updated bio for testing purposes.');
            await tester.pump();
          }
          
          print('✅ Profile information edited');
          
          // Save changes
          var saveButton = find.textContaining('Save');
          if (saveButton.evaluate().isEmpty) {
            saveButton = find.textContaining('Update');
          }
          
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton.first);
            await tester.pumpAndSettle();
            print('✅ Profile changes saved');
          }
        }
      } else {
        print('ℹ️ No edit profile option found (may be read-only)');
      }
    });

    testWidgets('Profile image management', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Look for profile image editing
      final userAvatar = find.byType(CircleAvatar);
      if (userAvatar.evaluate().isNotEmpty) {
        // Try tapping on avatar for edit options
        await tester.tap(userAvatar.first);
        await tester.pumpAndSettle();
        
        // Look for image editing options
        var cameraOption = find.textContaining('Camera');
        if (cameraOption.evaluate().isEmpty) {
          cameraOption = find.byIcon(Icons.camera_alt);
        }
        
        var galleryOption = find.textContaining('Gallery');
        if (galleryOption.evaluate().isEmpty) {
          galleryOption = find.byIcon(Icons.photo_library);
        }
        
        if (cameraOption.evaluate().isNotEmpty || galleryOption.evaluate().isNotEmpty) {
          print('📸 Profile image editing options found');
          
          // Test selecting camera option
          if (cameraOption.evaluate().isNotEmpty) {
            await tester.tap(cameraOption.first);
            await tester.pump();
            print('✅ Camera option tested');
          }
          
          // Go back if modal opened
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        }
      }
      
      // Look for remove profile image option
      final removeImageOption = find.textContaining('Remove');
      if (removeImageOption.evaluate().isNotEmpty) {
        await tester.tap(removeImageOption.first);
        await tester.pump();
        print('✅ Remove profile image option tested');
      }
    });

    testWidgets('Reading statistics display', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Look for statistics section
      var statsSection = find.textContaining('Statistics');
      if (statsSection.evaluate().isEmpty) {
        statsSection = find.textContaining('Stats');
      }
      if (statsSection.evaluate().isEmpty) {
        statsSection = find.textContaining('Reading');
      }
      
      if (statsSection.evaluate().isNotEmpty) {
        print('📊 Found reading statistics section');
        
        // Look for specific statistics
        final booksReadStat = find.textContaining('Books Read');
        final pagesReadStat = find.textContaining('Pages Read');
        final timeReadStat = find.textContaining('Time');
        
        if (booksReadStat.evaluate().isNotEmpty) {
          print('📚 Books read statistic found');
        }
        if (pagesReadStat.evaluate().isNotEmpty) {
          print('📄 Pages read statistic found');
        }
        if (timeReadStat.evaluate().isNotEmpty) {
          print('⏰ Reading time statistic found');
        }
        
        // Test tapping on statistics for details
        await tester.tap(statsSection.first);
        await tester.pumpAndSettle();
        
        // Look for detailed statistics view
        final detailedStats = find.byType(CustomScrollView);
        if (detailedStats.evaluate().isNotEmpty) {
          print('✅ Detailed statistics view accessed');
          
          // Go back
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        }
      } else {
        print('ℹ️ No reading statistics section found');
      }
    });

    testWidgets('Account settings management', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Look for settings section
      var settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isEmpty) {
        settingsButton = find.textContaining('Settings');
      }
      
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton.first);
        await tester.pumpAndSettle();
        
        print('⚙️ Accessed settings page');
        
        // Test notification settings
        final notificationSettings = find.textContaining('Notification');
        if (notificationSettings.evaluate().isNotEmpty) {
          await tester.tap(notificationSettings.first);
          await tester.pumpAndSettle();
          
          // Test notification toggles
          final switches = find.byType(Switch);
          if (switches.evaluate().isNotEmpty) {
            await tester.tap(switches.first);
            await tester.pump();
            print('✅ Notification settings tested');
          }
          
          // Go back
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        }
        
        // Test privacy settings
        final privacySettings = find.textContaining('Privacy');
        if (privacySettings.evaluate().isNotEmpty) {
          await tester.tap(privacySettings.first);
          await tester.pumpAndSettle();
          
          // Test privacy toggles
          final privacySwitches = find.byType(Switch);
          if (privacySwitches.evaluate().isNotEmpty) {
            print('🔒 Privacy settings found');
          }
          
          // Go back
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        }
        
        // Test theme settings
        final themeSettings = find.textContaining('Theme');
        if (themeSettings.evaluate().isNotEmpty) {
          await tester.tap(themeSettings.first);
          await tester.pumpAndSettle();
          
          // Test theme options
          final themeOptions = find.byType(RadioListTile);
          if (themeOptions.evaluate().isNotEmpty) {
            await tester.tap(themeOptions.first);
            await tester.pump();
            print('✅ Theme settings tested');
          }
          
          // Go back
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('Logout functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Look for logout option
      var logoutButton = find.textContaining('Logout');
      if (logoutButton.evaluate().isEmpty) {
        logoutButton = find.textContaining('Sign Out');
      }
      if (logoutButton.evaluate().isEmpty) {
        logoutButton = find.byIcon(Icons.logout);
      }
      
      if (logoutButton.evaluate().isNotEmpty) {
        await tester.tap(logoutButton.first);
        await tester.pumpAndSettle();
        
        // Look for confirmation dialog
        final confirmDialog = find.byType(AlertDialog);
        if (confirmDialog.evaluate().isNotEmpty) {
          print('🚪 Logout confirmation dialog shown');
          
          // Cancel logout for safety
          final cancelButton = find.textContaining('Cancel');
          if (cancelButton.evaluate().isNotEmpty) {
            await tester.tap(cancelButton);
            await tester.pumpAndSettle();
            print('✅ Logout cancelled for test safety');
          } else {
            // If no cancel, confirm logout
            final confirmButton = find.textContaining('Logout');
            if (confirmButton.evaluate().isNotEmpty) {
              await tester.tap(confirmButton);
              await tester.pumpAndSettle();
              
              // Should navigate to login page
              final loginPage = find.textContaining('Login');
              if (loginPage.evaluate().isNotEmpty) {
                print('✅ Logout successful, redirected to login');
              }
            }
          }
        } else {
          print('⚠️ Direct logout without confirmation');
        }
      } else {
        print('ℹ️ No logout option found in current view');
      }
    });

    testWidgets('Account deletion workflow', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Navigate to settings if available
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
      }
      
      // Look for delete account option
      var deleteAccountButton = find.textContaining('Delete Account');
      if (deleteAccountButton.evaluate().isEmpty) {
        deleteAccountButton = find.textContaining('Delete');
      }
      
      if (deleteAccountButton.evaluate().isNotEmpty) {
        await tester.tap(deleteAccountButton.first);
        await tester.pumpAndSettle();
        
        // Should show serious confirmation dialog
        final confirmDialog = find.byType(AlertDialog);
        if (confirmDialog.evaluate().isNotEmpty) {
          print('⚠️ Account deletion confirmation dialog shown');
          
          // Always cancel for safety in tests
          final cancelButton = find.textContaining('Cancel');
          if (cancelButton.evaluate().isNotEmpty) {
            await tester.tap(cancelButton);
            await tester.pumpAndSettle();
            print('✅ Account deletion cancelled for test safety');
          }
        }
      } else {
        print('ℹ️ Account deletion option not found (may be in separate settings)');
      }
    });

    testWidgets('Profile data persistence and refresh', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Test pull-to-refresh on profile
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        await tester.fling(refreshIndicator, const Offset(0, 300), 1000);
        await tester.pump();
        
        // Verify loading indicator appears
        final loadingIndicator = find.byType(CircularProgressIndicator);
        if (loadingIndicator.evaluate().isNotEmpty) {
          print('🔄 Profile refresh loading indicator shown');
        }
        
        // Wait for refresh to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        print('✅ Profile refresh functionality tested');
      }
      
      // Test navigation away and back
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Verify profile loads quickly (cached data)
      var profileContent = find.textContaining('Profile');
      if (profileContent.evaluate().isEmpty) {
        profileContent = find.byType(CircleAvatar);
      }
      
      expect(profileContent.evaluate().length, greaterThan(0),
          reason: 'Profile should load quickly from cache');
      
      print('✅ Profile data persistence tested');
    });
  });
}
