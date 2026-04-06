import 'package:flutter/material.dart';
import 'package:flutter_library/core/navigation/navigation_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationServiceImpl', () {
    late NavigationServiceImpl navigationService;

    setUp(() {
      navigationService = NavigationServiceImpl();
    });

    group('navigatorKey', () {
      test('should return a singleton GlobalKey', () {
        // Arrange & Act
        final key1 = NavigationServiceImpl.navigatorKey;
        final key2 = NavigationServiceImpl.navigatorKey;

        // Assert
        expect(key1, isNotNull);
        expect(key1, equals(key2));
        expect(key1, isA<GlobalKey<NavigatorState>>());
      });
    });

    group('navigateTo', () {
      testWidgets('should navigate to route when navigator is available', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            initialRoute: '/',
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/test': (context) => const Scaffold(body: Text('Test')),
            },
          ),
        );

        // Act
        final result = navigationService.navigateTo('/test');
        await tester.pumpAndSettle();

        // Assert
        expect(result, isA<Future>());
        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('should pass arguments when navigating', (tester) async {
        // Arrange
        const testArgs = 'test-args';
        String? receivedArgs;

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              if (settings.name == '/test') {
                receivedArgs = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (context) => const Scaffold(body: Text('Test')),
                );
              }
              return MaterialPageRoute(
                builder: (context) => const Scaffold(body: Text('Home')),
              );
            },
          ),
        );

        // Act
        navigationService.navigateTo('/test', arguments: testArgs);
        await tester.pumpAndSettle();

        // Assert
        expect(receivedArgs, equals(testArgs));
      });

      test('should return null when navigator is not available', () async {
        // Arrange & Act
        final result = await navigationService.navigateTo('/test');

        // Assert
        expect(result, isNull);
      });
    });

    group('navigateToAndReplace', () {
      testWidgets('should replace current route', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            initialRoute: '/',
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/test': (context) => const Scaffold(body: Text('Test')),
            },
          ),
        );

        // Act
        navigationService.navigateToAndReplace('/test');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test'), findsOneWidget);
        expect(find.text('Home'), findsNothing);
        expect(navigationService.canGoBack(), isFalse);
      });

      testWidgets('should pass arguments when replacing', (tester) async {
        // Arrange
        const testArgs = 42;
        int? receivedArgs;

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              if (settings.name == '/test') {
                receivedArgs = settings.arguments as int?;
                return MaterialPageRoute(
                  builder: (context) => const Scaffold(body: Text('Test')),
                );
              }
              return MaterialPageRoute(
                builder: (context) => const Scaffold(body: Text('Home')),
              );
            },
          ),
        );

        // Act
        navigationService.navigateToAndReplace('/test', arguments: testArgs);
        await tester.pumpAndSettle();

        // Assert
        expect(receivedArgs, equals(testArgs));
      });

      test('should return null when navigator is not available', () async {
        // Arrange & Act
        final result = await navigationService.navigateToAndReplace('/test');

        // Assert
        expect(result, isNull);
      });
    });

    group('navigateToAndClearStack', () {
      testWidgets('should clear navigation stack', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            initialRoute: '/',
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/middle': (context) => const Scaffold(body: Text('Middle')),
              '/final': (context) => const Scaffold(body: Text('Final')),
            },
          ),
        );

        // Navigate to middle first
        navigationService.navigateTo('/middle');
        await tester.pumpAndSettle();

        // Act - Clear stack and navigate to final
        navigationService.navigateToAndClearStack('/final');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Final'), findsOneWidget);
        expect(navigationService.canGoBack(), isFalse);
      });

      testWidgets('should pass arguments when clearing stack', (tester) async {
        // Arrange
        const testArgs = {'key': 'value'};
        Map<String, String>? receivedArgs;

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              if (settings.name == '/test') {
                receivedArgs = settings.arguments as Map<String, String>?;
                return MaterialPageRoute(
                  builder: (context) => const Scaffold(body: Text('Test')),
                );
              }
              return MaterialPageRoute(
                builder: (context) => const Scaffold(body: Text('Home')),
              );
            },
          ),
        );

        // Act
        navigationService.navigateToAndClearStack('/test', arguments: testArgs);
        await tester.pumpAndSettle();

        // Assert
        expect(receivedArgs, equals(testArgs));
      });

      test('should return null when navigator is not available', () async {
        // Arrange & Act
        final result = await navigationService.navigateToAndClearStack('/test');

        // Assert
        expect(result, isNull);
      });
    });

    group('goBack', () {
      testWidgets('should pop current route', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            initialRoute: '/',
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/test': (context) => const Scaffold(body: Text('Test')),
            },
          ),
        );

        navigationService.navigateTo('/test');
        await tester.pumpAndSettle();
        expect(find.text('Test'), findsOneWidget);

        // Act
        navigationService.goBack();
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Test'), findsNothing);
      });

      testWidgets('should pass result when going back', (tester) async {
        // Arrange
        const testResult = 'result-data';
        String? receivedResult;

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    receivedResult = await Navigator.of(context).pushNamed('/test') as String?;
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
            routes: {
              '/test': (context) => const Scaffold(body: Text('Test')),
            },
          ),
        );

        // Navigate to test page
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Act
        navigationService.goBack(testResult);
        await tester.pumpAndSettle();

        // Assert
        expect(receivedResult, equals(testResult));
      });

      test('should do nothing when navigator is not available', () {
        // Arrange & Act & Assert
        expect(() => navigationService.goBack(), returnsNormally);
      });
    });

    group('canGoBack', () {
      testWidgets('should return true when can pop', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            initialRoute: '/',
            routes: {
              '/': (context) => const Scaffold(body: Text('Home')),
              '/test': (context) => const Scaffold(body: Text('Test')),
            },
          ),
        );

        navigationService.navigateTo('/test');
        await tester.pumpAndSettle();

        // Act
        final canGoBack = navigationService.canGoBack();

        // Assert
        expect(canGoBack, isTrue);
      });

      testWidgets('should return false when cannot pop', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        // Act
        final canGoBack = navigationService.canGoBack();

        // Assert
        expect(canGoBack, isFalse);
      });

      test('should return false when navigator is not available', () {
        // Arrange & Act
        final canGoBack = navigationService.canGoBack();

        // Assert
        expect(canGoBack, isFalse);
      });
    });

    group('getCurrentRouteName', () {
      testWidgets('should return null when context is not available', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        // Act - Note: getCurrentRouteName returns null when no ModalRoute context
        final routeName = navigationService.getCurrentRouteName();

        // Assert - Method exists but requires proper context which isn't available in test
        expect(routeName, isNull);
      });

      test('should return null when navigator is not available', () {
        // Arrange & Act
        final routeName = navigationService.getCurrentRouteName();

        // Assert
        expect(routeName, isNull);
      });
    });

    group('showDialogCustom', () {
      testWidgets('should show dialog with custom widget', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        // Act
        navigationService.showDialogCustom(
          child: const AlertDialog(
            title: Text('Test Dialog'),
            content: Text('Dialog content'),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Dialog'), findsOneWidget);
        expect(find.text('Dialog content'), findsOneWidget);
      });

      testWidgets('should dismiss dialog when barrier is tapped if barrierDismissible is true', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        navigationService.showDialogCustom(
          child: const AlertDialog(title: Text('Test Dialog')),
          barrierDismissible: true,
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Dialog'), findsNothing);
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('should not dismiss dialog when barrier is tapped if barrierDismissible is false', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        navigationService.showDialogCustom(
          child: const AlertDialog(title: Text('Test Dialog')),
          barrierDismissible: false,
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Dialog'), findsOneWidget);
      });

      testWidgets('should return dialog result', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        const testResult = 'dialog-result';
        Future<String?>? dialogFuture;

        // Act
        dialogFuture = navigationService.showDialogCustom<String>(
          child: Builder(
            builder: (context) => AlertDialog(
              title: const Text('Test Dialog'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(testResult),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        final result = await dialogFuture;

        // Assert
        expect(result, equals(testResult));
      });

      test('should return null when navigator is not available', () async {
        // Arrange & Act
        final result = await navigationService.showDialogCustom(
          child: const AlertDialog(title: Text('Test')),
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('showBottomSheetCustom', () {
      testWidgets('should show bottom sheet with custom widget', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        // Act
        navigationService.showBottomSheetCustom(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Text('Bottom Sheet Content'),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Bottom Sheet Content'), findsOneWidget);
      });

      testWidgets('should show scrollable bottom sheet when isScrollControlled is true', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        // Act
        navigationService.showBottomSheetCustom(
          child: Container(
            height: 800,
            padding: const EdgeInsets.all(16),
            child: const Text('Tall Bottom Sheet'),
          ),
          isScrollControlled: true,
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Tall Bottom Sheet'), findsOneWidget);
      });

      testWidgets('should dismiss bottom sheet when dragged down', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        navigationService.showBottomSheetCustom(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Text('Bottom Sheet Content'),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.drag(find.text('Bottom Sheet Content'), const Offset(0, 500));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Bottom Sheet Content'), findsNothing);
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('should return bottom sheet result', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: NavigationServiceImpl.navigatorKey,
            home: const Scaffold(body: Text('Home')),
          ),
        );

        const testResult = 123;
        Future<int?>? sheetFuture;

        // Act
        sheetFuture = navigationService.showBottomSheetCustom<int>(
          child: Builder(
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(testResult),
                child: const Text('Close'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        final result = await sheetFuture;

        // Assert
        expect(result, equals(testResult));
      });

      test('should return null when navigator is not available', () async {
        // Arrange & Act
        final result = await navigationService.showBottomSheetCustom(
          child: const Text('Test'),
        );

        // Assert
        expect(result, isNull);
      });
    });
  });
}
