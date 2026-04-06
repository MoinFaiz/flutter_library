import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/navigation/navigation_service_impl.dart';

void main() {
  group('NavigationServiceImpl Tests', () {
    late NavigationServiceImpl navigationService;

    setUp(() {
      navigationService = NavigationServiceImpl();
    });

    group('Static NavigatorKey', () {
      test('should provide consistent navigator key', () {
        // Act
        final key1 = NavigationServiceImpl.navigatorKey;
        final key2 = NavigationServiceImpl.navigatorKey;

        // Assert
        expect(key1, equals(key2));
        expect(key1, isA<GlobalKey<NavigatorState>>());
      });
    });

    group('Navigation Methods with No Navigator', () {
      test('navigateTo should return null when no navigator is available', () async {
        // Act
        final result = await navigationService.navigateTo('/test');

        // Assert
        expect(result, isNull);
      });

      test('navigateToAndReplace should return null when no navigator is available', () async {
        // Act
        final result = await navigationService.navigateToAndReplace('/test');

        // Assert
        expect(result, isNull);
      });

      test('navigateToAndClearStack should return null when no navigator is available', () async {
        // Act
        final result = await navigationService.navigateToAndClearStack('/test');

        // Assert
        expect(result, isNull);
      });

      test('goBack should not throw when no navigator is available', () {
        // Act & Assert
        expect(() => navigationService.goBack(), returnsNormally);
      });

      test('canGoBack should return false when no navigator is available', () {
        // Act
        final result = navigationService.canGoBack();

        // Assert
        expect(result, isFalse);
      });

      test('getCurrentRouteName should return null when no navigator is available', () {
        // Act
        final result = navigationService.getCurrentRouteName();

        // Assert
        expect(result, isNull);
      });
    });

    group('Navigation Methods with Arguments', () {
      test('navigateTo should handle arguments parameter', () async {
        // Arrange
        const testArguments = {'key': 'value'};

        // Act
        final result = await navigationService.navigateTo('/test', arguments: testArguments);

        // Assert
        expect(result, isNull); // Since no navigator is available
      });

      test('navigateToAndReplace should handle arguments parameter', () async {
        // Arrange
        const testArguments = {'data': 'test'};

        // Act
        final result = await navigationService.navigateToAndReplace('/test', arguments: testArguments);

        // Assert
        expect(result, isNull); // Since no navigator is available
      });

      test('navigateToAndClearStack should handle arguments parameter', () async {
        // Arrange
        const testArguments = {'clear': true};

        // Act
        final result = await navigationService.navigateToAndClearStack('/test', arguments: testArguments);

        // Assert
        expect(result, isNull); // Since no navigator is available
      });
    });

    group('Type Safety', () {
      test('navigateTo should handle generic type parameter', () async {
        // Act
        final result = await navigationService.navigateTo<String>('/test');

        // Assert
        expect(result, isNull);
      });

      test('navigateToAndReplace should handle generic type parameter', () async {
        // Act
        final result = await navigationService.navigateToAndReplace<int>('/test');

        // Assert
        expect(result, isNull);
      });

      test('navigateToAndClearStack should handle generic type parameter', () async {
        // Act
        final result = await navigationService.navigateToAndClearStack<bool>('/test');

        // Assert
        expect(result, isNull);
      });

      test('goBack should handle generic type parameter and result', () {
        // Act & Assert
        expect(() => navigationService.goBack<String>('test_result'), returnsNormally);
      });
    });

    group('Route Names', () {
      test('should handle empty route name', () async {
        // Act
        final result = await navigationService.navigateTo('');

        // Assert
        expect(result, isNull);
      });

      test('should handle route name with special characters', () async {
        // Act
        final result = await navigationService.navigateTo('/test/route-with_special.characters');

        // Assert
        expect(result, isNull);
      });
    });
  });

  group('NavigationServiceImpl Integration Tests', () {
    testWidgets('should work with actual Navigator when MaterialApp is present', (WidgetTester tester) async {
      // Arrange
      final navigationService = NavigationServiceImpl();
      bool route1Visited = false;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: NavigationServiceImpl.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home')),
            '/route1': (context) {
              route1Visited = true;
              return const Scaffold(body: Text('Route 1'));
            },
            '/route2': (context) {
              return const Scaffold(body: Text('Route 2'));
            },
          },
        ),
      );

      // Act - Test navigation
      navigationService.navigateTo('/route1');
      await tester.pumpAndSettle();

      // Assert
      expect(route1Visited, isTrue);
      expect(find.text('Route 1'), findsOneWidget);

      // Act - Test canGoBack
      final canGoBack = navigationService.canGoBack();

      // Assert
      expect(canGoBack, isTrue);

      // Act - Test goBack
      navigationService.goBack();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should handle navigateToAndReplace correctly', (WidgetTester tester) async {
      // Arrange
      final navigationService = NavigationServiceImpl();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: NavigationServiceImpl.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home')),
            '/route1': (context) => const Scaffold(body: Text('Route 1')),
            '/route2': (context) => const Scaffold(body: Text('Route 2')),
          },
        ),
      );

      // Act - Navigate to route1
      navigationService.navigateTo('/route1');
      await tester.pumpAndSettle();

      // Act - Replace with route2
      navigationService.navigateToAndReplace('/route2');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Route 2'), findsOneWidget);

      // Act - Go back should go to home (route1 was replaced)
      navigationService.goBack();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should handle navigateToAndClearStack correctly', (WidgetTester tester) async {
      // Arrange
      final navigationService = NavigationServiceImpl();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: NavigationServiceImpl.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home')),
            '/route1': (context) => const Scaffold(body: Text('Route 1')),
            '/route2': (context) => const Scaffold(body: Text('Route 2')),
          },
        ),
      );

      // Act - Navigate through multiple routes
      navigationService.navigateTo('/route1');
      await tester.pumpAndSettle();

      navigationService.navigateTo('/route2');
      await tester.pumpAndSettle();

      // Act - Clear stack and navigate to home
      navigationService.navigateToAndClearStack('/');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Home'), findsOneWidget);
      expect(navigationService.canGoBack(), isFalse);
    });
  });
}
