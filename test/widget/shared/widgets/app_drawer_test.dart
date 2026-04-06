import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/app_drawer.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/injection/injection_container.dart';

// Mock NavigationService
class MockNavigationService extends NavigationService {
  @override
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) async {
    return null;
  }

  @override
  Future<T?> navigateToAndReplace<T>(String routeName, {Object? arguments}) async {
    return null;
  }

  @override
  Future<T?> navigateToAndClearStack<T>(String routeName, {Object? arguments}) async {
    return null;
  }

  @override
  void goBack<T>([T? result]) {}

  @override
  bool canGoBack() => true;

  @override
  String? getCurrentRouteName() => null;

  @override
  Future<T?> showDialogCustom<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    return null;
  }

  @override
  Future<T?> showBottomSheetCustom<T>({
    required Widget child,
    bool isScrollControlled = false,
  }) async {
    return null;
  }
}

void main() {
  group('AppDrawer Widget Tests', () {
    late MockNavigationService mockNavigationService;

    setUp(() {
      mockNavigationService = MockNavigationService();
      // Register the mock navigation service
      if (sl.isRegistered<NavigationService>()) {
        sl.unregister<NavigationService>();
      }
      sl.registerSingleton<NavigationService>(mockNavigationService);
    });

    tearDown(() {
      if (sl.isRegistered<NavigationService>()) {
        sl.unregister<NavigationService>();
      }
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(title: const Text('Test')),
          body: const Text('Main Content'),
        ),
      );
    }

    testWidgets('should display drawer header with app info', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Flutter Library'), findsOneWidget);
      expect(find.text('Your digital book companion'), findsOneWidget);
      expect(find.byIcon(Icons.library_books), findsOneWidget);
    });

    testWidgets('should display all main navigation items', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);
    });

    testWidgets('should display policy section items', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Scroll down to see policy section
      await tester.drag(find.byType(Drawer), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Policies & Legal'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Shipping & Delivery Policy'), findsOneWidget);
      expect(find.text('Cancellation & Refund Policy'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('should display app version', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Scroll down to see version
      await tester.drag(find.byType(Drawer), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('should display proper icons for each menu item', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert - Check visible icons
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.feedback_outlined), findsOneWidget);

      // Scroll down to see policy icons
      await tester.drag(find.byType(Drawer), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
      expect(find.byIcon(Icons.assignment_return_outlined), findsOneWidget);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });

    testWidgets('should display subtitles for menu items', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Track your orders and history'), findsOneWidget);
      expect(find.text('Manage your profile information'), findsOneWidget);
      expect(find.text('App preferences and account'), findsOneWidget);
      expect(find.text('Share your thoughts with us'), findsOneWidget);
    });

    testWidgets('should have proper gradient in drawer header', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DrawerHeader), findsOneWidget);
      
      final drawerHeader = tester.widget<DrawerHeader>(find.byType(DrawerHeader));
      expect(drawerHeader.decoration, isA<BoxDecoration>());
      
      final decoration = drawerHeader.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('should display divider between sections', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('should display circular avatar with library icon', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircleAvatar), findsOneWidget);
      
      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, equals(20));
      final context = tester.element(find.byType(CircleAvatar));
      expect(circleAvatar.backgroundColor, equals(Theme.of(context).colorScheme.surface));
    });

    testWidgets('should have proper content padding for list tiles', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final listTile in listTiles) {
        expect(listTile.contentPadding, isNotNull);
      }
    });

    testWidgets('should use ListView with proper configuration', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, equals(EdgeInsets.zero));
    });

    testWidgets('should properly style section header', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Policies & Legal'), findsOneWidget);
      
      final headerText = tester.widget<Text>(find.text('Policies & Legal'));
      expect(headerText.style, isNotNull);
    });

    testWidgets('should have proper spacing and layout', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
    });

    testWidgets('should display all required ListTile widgets', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert - Check initial visible ListTiles
      expect(find.byType(ListTile), findsAtLeastNWidgets(4));

      // Scroll down to load more items
      await tester.drag(find.byType(Drawer), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Should now have more ListTiles visible (8 total exist)
      expect(find.byType(ListTile), findsAtLeastNWidgets(6));
    });

    testWidgets('should maintain consistent styling for all items', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert - All list tiles should have icons, titles, and subtitles
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final listTile in listTiles) {
        expect(listTile.leading, isNotNull);
        expect(listTile.title, isNotNull);
        expect(listTile.subtitle, isNotNull);
        expect(listTile.onTap, isNotNull);
      }
    });

    testWidgets('should handle drawer opening and closing', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Initially drawer should be closed
      expect(find.text('Flutter Library'), findsNothing);

      // Act - Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Assert - Drawer should be open
      expect(find.text('Flutter Library'), findsOneWidget);

      // Act - Close drawer by tapping outside
      await tester.tapAt(const Offset(400, 300)); // Tap on main content area
      await tester.pumpAndSettle();

      // Assert - Drawer should be closed
      expect(find.text('Flutter Library'), findsNothing);
    });
  });
}
