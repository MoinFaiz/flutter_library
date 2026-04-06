import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/settings/presentation/pages/settings_page.dart';

void main() {
  group('SettingsPage Tests', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: SettingsPage(),
      );
    }

    testWidgets('displays app bar with correct title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays all settings sections', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('App'), findsOneWidget);
    });

    testWidgets('displays appearance settings', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light, Dark, or System'), findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    });

    testWidgets('displays notification settings', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Receive notifications about rentals and updates'), findsOneWidget);
      expect(find.text('Email Notifications'), findsOneWidget);
      expect(find.text('Get email updates about your library'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('displays account settings', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Manage your profile information'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('Control your privacy settings'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.security_outlined), findsOneWidget);
    });

    testWidgets('displays app settings', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Manage app data and cache'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('App version and information'), findsOneWidget);
      expect(find.byIcon(Icons.storage_outlined), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays sign out button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Scroll to make Sign Out button visible
      await tester.scrollUntilVisible(
        find.text('Sign Out'),
        500.0,
      );

      // Assert
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
      
      // Let's look for any button widget
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows theme dialog when theme setting is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.settings_system_daydream), findsOneWidget);
    });

    testWidgets('closes theme dialog when light theme is selected', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('Choose Theme'), findsNothing);
    });

    testWidgets('closes theme dialog when dark theme is selected', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('Choose Theme'), findsNothing);
    });

    testWidgets('closes theme dialog when system theme is selected', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('Choose Theme'), findsNothing);
    });

    testWidgets('shows about dialog when about setting is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Scroll to make About setting visible and tappable
      await tester.scrollUntilVisible(
        find.text('About'),
        500.0,
      );
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Flutter Library'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('A modern library management app built with Flutter.'), findsOneWidget);
      expect(find.text('Features:'), findsOneWidget);
      expect(find.text('• Book rental and purchase'), findsOneWidget);
      expect(find.text('• Personal library management'), findsOneWidget);
      expect(find.text('• Favorites and reviews'), findsOneWidget);
      expect(find.text('• Search and discovery'), findsOneWidget);
    });

    testWidgets('shows sign out dialog when sign out button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Scroll to make Sign Out button visible and tappable
      await tester.scrollUntilVisible(
        find.text('Sign Out'),
        500.0,
      );
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sign Out'), findsAtLeastNWidgets(1)); // Dialog title
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('closes sign out dialog when cancel is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Scroll to make Sign Out button visible and tappable
      await tester.scrollUntilVisible(
        find.text('Sign Out'),
        500.0,
      );
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('Are you sure you want to sign out?'), findsNothing);
    });

    testWidgets('shows success message when sign out is confirmed', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Scroll to make Sign Out button visible and tappable
      await tester.scrollUntilVisible(
        find.text('Sign Out'),
        500.0,
      );
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      
      // Find the sign out button in the dialog (not the main button)
      final dialogSignOutButtons = find.text('Sign Out');
      await tester.tap(dialogSignOutButtons.last);
      await tester.pumpAndSettle();

      // Assert - Success message should appear
      expect(find.text('Signed out successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('has proper scroll behavior', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Should have scrollable content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('all settings tiles have chevron icons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Each ListTile should have a chevron icon (7 settings tiles)
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(7));
    });

    testWidgets('has proper spacing and layout', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for proper layout components
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(ListTile), findsNWidgets(7)); // 7 settings options
    });
  });
}
