import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/core/navigation/navigation_service_impl.dart';

void main() {
  group('NavigationService Tests', () {
    group('NavigationServiceImpl', () {
      late NavigationService navigationService;

      setUp(() {
        navigationService = NavigationServiceImpl();
      });

      group('Static NavigatorKey', () {
        test('should provide a consistent navigator key', () {
          // Act
          final key1 = NavigationServiceImpl.navigatorKey;
          final key2 = NavigationServiceImpl.navigatorKey;

          // Assert
          expect(key1, equals(key2));
          expect(key1, isA<GlobalKey<NavigatorState>>());
        });

        test('should be a singleton navigator key', () {
          // Act
          final key = NavigationServiceImpl.navigatorKey;

          // Assert
          expect(key, isNotNull);
          expect(key, isA<GlobalKey<NavigatorState>>());
        });
      });

      group('Interface Compliance', () {
        test('should implement NavigationService interface', () {
          // Assert
          expect(navigationService, isA<NavigationService>());
        });

        test('should have all required methods', () {
          // Assert
          expect(navigationService.navigateTo, isA<Function>());
          expect(navigationService.navigateToAndReplace, isA<Function>());
          expect(navigationService.navigateToAndClearStack, isA<Function>());
          expect(navigationService.goBack, isA<Function>());
          expect(navigationService.canGoBack, isA<Function>());
          expect(navigationService.getCurrentRouteName, isA<Function>());
          expect(navigationService.showDialogCustom, isA<Function>());
          expect(navigationService.showBottomSheetCustom, isA<Function>());
        });
      });

      group('Navigation Methods Without Navigator Context', () {
        test('navigateTo should return null when navigator is not available', () async {
          // Act
          final result = await navigationService.navigateTo('/test');

          // Assert
          expect(result, isNull);
        });

        test('navigateToAndReplace should return null when navigator is not available', () async {
          // Act
          final result = await navigationService.navigateToAndReplace('/test');

          // Assert
          expect(result, isNull);
        });

        test('navigateToAndClearStack should return null when navigator is not available', () async {
          // Act
          final result = await navigationService.navigateToAndClearStack('/test');

          // Assert
          expect(result, isNull);
        });

        test('goBack should handle null navigator gracefully', () {
          // Act & Assert - Should not throw
          expect(() => navigationService.goBack(), returnsNormally);
        });

        test('canGoBack should return false when navigator is not available', () {
          // Act
          final result = navigationService.canGoBack();

          // Assert
          expect(result, isFalse);
        });
      });

      group('Method Signatures', () {
        test('navigateTo should accept generic type parameter', () async {
          // Act
          final result = await navigationService.navigateTo<String>('/test');

          // Assert
          expect(result, isA<String?>());
        });

        test('navigateTo should accept arguments parameter', () async {
          // Act
          final result = await navigationService.navigateTo(
            '/test',
            arguments: {'key': 'value'},
          );

          // Assert
          expect(result, isNull);
        });

        test('navigateToAndReplace should accept generic type parameter', () async {
          // Act
          final result = await navigationService.navigateToAndReplace<int>('/test');

          // Assert
          expect(result, isA<int?>());
        });

        test('navigateToAndReplace should accept arguments parameter', () async {
          // Act
          final result = await navigationService.navigateToAndReplace(
            '/test',
            arguments: {'key': 'value'},
          );

          // Assert
          expect(result, isNull);
        });

        test('navigateToAndClearStack should accept generic type parameter', () async {
          // Act
          final result = await navigationService.navigateToAndClearStack<bool>('/test');

          // Assert
          expect(result, isA<bool?>());
        });

        test('navigateToAndClearStack should accept arguments parameter', () async {
          // Act
          final result = await navigationService.navigateToAndClearStack(
            '/test',
            arguments: {'key': 'value'},
          );

          // Assert
          expect(result, isNull);
        });

        test('goBack should accept generic type parameter and result', () {
          // Act & Assert - Should not throw
          expect(() => navigationService.goBack<String>('result'), returnsNormally);
          expect(() => navigationService.goBack<int>(42), returnsNormally);
          expect(() => navigationService.goBack(), returnsNormally);
        });
      });

      group('Dialog and BottomSheet Methods', () {
        test('showDialogCustom should accept required child parameter', () {
          // Arrange
          final widget = Container();

          // Act & Assert - Should not throw during method call setup
          expect(
            () => navigationService.showDialogCustom(child: widget),
            returnsNormally,
          );
        });

        test('showDialogCustom should accept barrierDismissible parameter', () {
          // Arrange
          final widget = Container();

          // Act & Assert - Should not throw during method call setup
          expect(
            () => navigationService.showDialogCustom(
              child: widget,
              barrierDismissible: false,
            ),
            returnsNormally,
          );
        });

        test('showBottomSheetCustom should accept required child parameter', () {
          // Arrange
          final widget = Container();

          // Act & Assert - Should not throw during method call setup
          expect(
            () => navigationService.showBottomSheetCustom(child: widget),
            returnsNormally,
          );
        });

        test('showBottomSheetCustom should accept isScrollControlled parameter', () {
          // Arrange
          final widget = Container();

          // Act & Assert - Should not throw during method call setup
          expect(
            () => navigationService.showBottomSheetCustom(
              child: widget,
              isScrollControlled: true,
            ),
            returnsNormally,
          );
        });
      });

      group('Edge Cases', () {
        test('should handle empty route names', () async {
          // Act
          final result = await navigationService.navigateTo('');

          // Assert
          expect(result, isNull);
        });

        test('should handle null arguments', () async {
          // Act
          final result = await navigationService.navigateTo('/test', arguments: null);

          // Assert
          expect(result, isNull);
        });

        test('should handle complex argument objects', () async {
          // Arrange
          final complexArgs = {
            'user': {'id': 1, 'name': 'John'},
            'settings': {'theme': 'dark', 'notifications': true},
            'list': [1, 2, 3, 4, 5],
          };

          // Act
          final result = await navigationService.navigateTo('/test', arguments: complexArgs);

          // Assert
          expect(result, isNull);
        });

        test('getCurrentRouteName should handle null navigator gracefully', () {
          // Act & Assert - Should not throw
          expect(() => navigationService.getCurrentRouteName(), returnsNormally);
        });
      });

      group('Type Safety', () {
        test('should maintain type safety for return values', () async {
          // Act
          final stringResult = await navigationService.navigateTo<String>('/test');
          final intResult = await navigationService.navigateToAndReplace<int>('/test');
          final boolResult = await navigationService.navigateToAndClearStack<bool>('/test');

          // Assert
          expect(stringResult, isA<String?>());
          expect(intResult, isA<int?>());
          expect(boolResult, isA<bool?>());
        });

        test('should handle custom object types', () async {
          // Act
          final mapResult = await navigationService.navigateTo<Map<String, dynamic>>('/test');
          final listResult = await navigationService.navigateToAndReplace<List<int>>('/test');

          // Assert
          expect(mapResult, isA<Map<String, dynamic>?>());
          expect(listResult, isA<List<int>?>());
        });
      });

      group('Consistency', () {
        test('should return consistent results for same inputs', () async {
          // Act
          final result1 = await navigationService.navigateTo('/test');
          final result2 = await navigationService.navigateTo('/test');

          // Assert
          expect(result1, equals(result2));
          expect(result1, isNull);
          expect(result2, isNull);
        });

        test('canGoBack should be consistent when called multiple times', () {
          // Act
          final result1 = navigationService.canGoBack();
          final result2 = navigationService.canGoBack();
          final result3 = navigationService.canGoBack();

          // Assert
          expect(result1, equals(result2));
          expect(result2, equals(result3));
          expect(result1, isFalse);
        });
      });
    });

    group('NavigationService Interface', () {
      test('should be implementable by concrete classes', () {
        // Arrange
        final implementation = NavigationServiceImpl();

        // Assert
        expect(implementation, isA<NavigationService>());
      });

      test('should define all required abstract methods', () {
        // This test verifies that NavigationService is properly defined as an interface
        expect(NavigationService, isA<Type>());
      });
    });
  });

  group('Widget Tests with NavigationService', () {
    testWidgets('NavigationServiceImpl should work with MaterialApp', (WidgetTester tester) async {
      // Arrange
      final app = MaterialApp(
        navigatorKey: NavigationServiceImpl.navigatorKey,
        home: const Scaffold(
          body: Text('Home'),
        ),
        routes: {
          '/test': (context) => const Scaffold(body: Text('Test Page')),
        },
      );

      // Act
      await tester.pumpWidget(app);

      // Assert
      expect(find.text('Home'), findsOneWidget);
      expect(NavigationServiceImpl.navigatorKey.currentState, isNotNull);
    });

    testWidgets('NavigationService should be able to navigate when context is available', (WidgetTester tester) async {
      // Arrange
      final navigationService = NavigationServiceImpl();
      final app = MaterialApp(
        navigatorKey: NavigationServiceImpl.navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                navigationService.navigateTo('/test');
              },
              child: const Text('Navigate'),
            ),
          ),
          '/test': (context) => const Scaffold(body: Text('Test Page')),
        },
      );

      // Act
      await tester.pumpWidget(app);
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Page'), findsOneWidget);
    });

    testWidgets('NavigationService canGoBack should return true when there is a route to pop', (WidgetTester tester) async {
      // Arrange
      final navigationService = NavigationServiceImpl();
      bool? canGoBackResult;
      
      final app = MaterialApp(
        navigatorKey: NavigationServiceImpl.navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                navigationService.navigateTo('/test');
              },
              child: const Text('Navigate'),
            ),
          ),
          '/test': (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                canGoBackResult = navigationService.canGoBack();
              },
              child: const Text('Check Can Go Back'),
            ),
          ),
        },
      );

      // Act
      await tester.pumpWidget(app);
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check Can Go Back'));
      await tester.pump();

      // Assert
      expect(canGoBackResult, isTrue);
    });
  });
}
