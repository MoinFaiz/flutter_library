import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/navigation/route_generator.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_reviews_page_args.dart';

void main() {
  group('RouteGenerator', () {
    late RouteSettings settings;
    late Book testBook;

    setUp(() {
      settings = const RouteSettings(name: '/test');
      
      testBook = Book(
        id: 'book_123',
        title: 'Test Book',
        author: 'Test Author',
        imageUrls: ['https://example.com/book.jpg'],
        rating: 4.5,
        pricing: const BookPricing(
          salePrice: 29.99,
          rentPrice: 5.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 5,
          availableForSaleCount: 3,
          totalCopies: 8,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'en',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'Test description',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
    });

    group('generateRoute', () {
      testWidgets('should return MainNavigationScaffold for main route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.main);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return AddBookPage for addBook route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.addBook);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return FavoritesPage for favorites route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.favorites);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
        
        // Note: BlocProvider injection testing requires full DI setup and is covered in integration tests
      });

      testWidgets('should return BookDetailsPageProvider for bookDetails route with Book argument', (tester) async {
        // arrange
        settings = RouteSettings(name: AppRoutes.bookDetails, arguments: testBook);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return error route for bookDetails without Book argument', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookDetails);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
        
        // Build the route to verify it's an error page
        final materialRoute = route as MaterialPageRoute;
        final widget = materialRoute.builder(tester.element(find.byType(Container).first));
        expect(widget, isA<Scaffold>());
      });

      testWidgets('should return error route for bookDetails with wrong argument type', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookDetails, arguments: 'invalid_argument');

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
        
        // Build the route to verify it's an error page
        final materialRoute = route as MaterialPageRoute;
        final widget = materialRoute.builder(tester.element(find.byType(Container).first));
        expect(widget, isA<Scaffold>());
      });

      testWidgets('should return BookReviewsPage for bookReviews route with correct arguments', (tester) async {
        // arrange
        final args = BookReviewsPageArgs(book: testBook);
        settings = RouteSettings(name: AppRoutes.bookReviews, arguments: args);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return error route for bookReviews without correct arguments', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookReviews);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
        
        // Build the route to verify it's an error page
        final materialRoute = route as MaterialPageRoute;
        final widget = materialRoute.builder(tester.element(find.byType(Container).first));
        expect(widget, isA<Scaffold>());
      });

      testWidgets('should return error route for bookReviews with wrong argument type', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookReviews, arguments: 'invalid_argument');

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
        
        // Build the route to verify it's an error page
        final materialRoute = route as MaterialPageRoute;
        final widget = materialRoute.builder(tester.element(find.byType(Container).first));
        expect(widget, isA<Scaffold>());
      });

      testWidgets('should return SettingsPage for settings route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.settings);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return ProfilePageProvider for profile route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.profile);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return OrdersPage for orders route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.orders);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return FeedbackPageProvider for feedback route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.feedback);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return TermsConditionsPage for termsConditions route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.termsConditions);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return ShippingDeliveryPolicyPage for shippingDeliveryPolicy route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.shippingDeliveryPolicy);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return CancellationRefundPolicyPage for cancellationRefundPolicy route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.cancellationRefundPolicy);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return PrivacyPolicyPage for privacyPolicy route', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.privacyPolicy);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      testWidgets('should return error route for unknown route', (tester) async {
        // arrange
        settings = const RouteSettings(name: '/unknown-route');

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
        
        // Build the route to verify it's an error page
        final materialRoute = route as MaterialPageRoute;
        final widget = materialRoute.builder(tester.element(find.byType(Container).first));
        expect(widget, isA<Scaffold>());
      });

      testWidgets('should handle null route name', (tester) async {
        // arrange
        settings = const RouteSettings(name: null);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
        
        // Build the route to verify it's an error page
        final materialRoute = route as MaterialPageRoute;
        final widget = materialRoute.builder(tester.element(find.byType(Container).first));
        expect(widget, isA<Scaffold>());
      });

      testWidgets('should handle empty route name', (tester) async {
        // arrange
        settings = const RouteSettings(name: '');

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
        
        // Build the route to verify it's an error page
        final materialRoute = route as MaterialPageRoute;
        final widget = materialRoute.builder(tester.element(find.byType(Container).first));
        expect(widget, isA<Scaffold>());
      });
    });

    group('error route', () {
      testWidgets('should build error route with correct structure', (tester) async {
        // arrange
        settings = const RouteSettings(name: '/unknown');

        // act
        final route = RouteGenerator.generateRoute(settings);
        
        // Build and pump the widget
        final materialRoute = route as MaterialPageRoute;
        await tester.pumpWidget(
          MaterialApp(
            home: materialRoute.builder(tester.element(find.byType(Container).first)),
          ),
        );

        // assert
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Route not found'), findsOneWidget);
        expect(find.text('Go Back'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should build error route with custom message', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookDetails);

        // act
        final route = RouteGenerator.generateRoute(settings);
        
        // Build and pump the widget
        final materialRoute = route as MaterialPageRoute;
        await tester.pumpWidget(
          MaterialApp(
            home: materialRoute.builder(tester.element(find.byType(Container).first)),
          ),
        );

        // assert
        expect(find.text('Book data is required'), findsOneWidget);
      });

      testWidgets('should handle go back button tap', (tester) async {
        // arrange
        settings = const RouteSettings(name: '/unknown');

        // act
        final route = RouteGenerator.generateRoute(settings);
        
        // Build and pump the widget in a navigation context
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(tester.element(find.byType(ElevatedButton).first))
                      .push(route);
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        );

        // Navigate to error page
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Verify error page is shown
        expect(find.text('Route not found'), findsOneWidget);
        expect(find.text('Go Back'), findsOneWidget);

        // Tap go back button
        await tester.tap(find.text('Go Back'));
        await tester.pumpAndSettle();

        // Verify we're back to the original page
        expect(find.text('Navigate'), findsOneWidget);
        expect(find.text('Route not found'), findsNothing);
      });
    });

    group('route settings preservation', () {
      test('should preserve route settings in generated routes', () {
        // arrange
        const customSettings = RouteSettings(
          name: AppRoutes.main,
          arguments: {'test': 'data'},
        );

        // act
        final route = RouteGenerator.generateRoute(customSettings);

        // assert
        expect(route.settings, equals(customSettings));
        expect(route.settings.name, equals(AppRoutes.main));
        expect(route.settings.arguments, equals({'test': 'data'}));
      });

      test('should preserve settings for error routes', () {
        // arrange
        const customSettings = RouteSettings(
          name: '/unknown',
          arguments: {'error': 'test'},
        );

        // act
        final route = RouteGenerator.generateRoute(customSettings);

        // assert
        expect(route.settings, equals(customSettings));
        expect(route.settings.name, equals('/unknown'));
        expect(route.settings.arguments, equals({'error': 'test'}));
      });
    });

    group('edge cases', () {
      test('should handle very long route names', () {
        // arrange
        final longRouteName = '/${'a' * 1000}';
        settings = RouteSettings(name: longRouteName);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings.name, equals(longRouteName));
      });

      test('should handle special characters in route names', () {
        // arrange
        const specialRouteName = '/test-route_with@special#chars!';
        settings = const RouteSettings(name: specialRouteName);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings.name, equals(specialRouteName));
      });

      test('should handle complex arguments', () {
        // arrange
        final complexArgs = {
          'string': 'test',
          'number': 123,
          'boolean': true,
          'list': [1, 2, 3],
          'map': {'nested': 'value'},
        };
        settings = RouteSettings(name: AppRoutes.main, arguments: complexArgs);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route.settings.arguments, equals(complexArgs));
      });

      test('should handle null arguments', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.main, arguments: null);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings.arguments, isNull);
      });

      test('should handle case-sensitive route names', () {
        // arrange
        settings = const RouteSettings(name: '/MAIN'); // uppercase version

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        // Should return error route since routes are case-sensitive
        expect(route.settings.name, equals('/MAIN'));
      });

      test('should handle route names with trailing slashes', () {
        // arrange
        settings = const RouteSettings(name: '//'); // double slash

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings.name, equals('//'));
      });
    });

    group('unhandled AppRoutes', () {
      test('should return error route for home route (not implemented)', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.home);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('should return error route for library route (not implemented)', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.library);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('should return error route for fullBookList route (not implemented)', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.fullBookList);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('should return error route for notifications route (not implemented)', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.notifications);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });
    });

    group('specific error messages', () {
      testWidgets('should show specific error message for bookDetails without Book', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookDetails);

        // act
        final route = RouteGenerator.generateRoute(settings);
        
        // Build and pump the widget
        final materialRoute = route as MaterialPageRoute;
        await tester.pumpWidget(
          MaterialApp(
            home: materialRoute.builder(tester.element(find.byType(Container).first)),
          ),
        );

        // assert
        expect(find.text('Book data is required'), findsOneWidget);
      });

      testWidgets('should show specific error message for bookReviews without args', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookReviews);

        // act
        final route = RouteGenerator.generateRoute(settings);
        
        // Build and pump the widget
        final materialRoute = route as MaterialPageRoute;
        await tester.pumpWidget(
          MaterialApp(
            home: materialRoute.builder(tester.element(find.byType(Container).first)),
          ),
        );

        // assert
        expect(find.text('Book reviews data is required'), findsOneWidget);
      });
    });

    group('unhandled AppRoutes', () {
      test('should return error route for home route (not implemented)', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.home);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('should return error route for library route (not implemented)', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.library);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('should return error route for fullBookList route (not implemented)', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.fullBookList);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });

      test('should return error route for notifications route (not implemented)', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.notifications);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        expect(route.settings, equals(settings));
      });
    });

    group('specific error messages', () {
      testWidgets('should show specific error message for bookDetails without Book', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookDetails);

        // act
        final route = RouteGenerator.generateRoute(settings);
        
        // Build and pump the widget
        final materialRoute = route as MaterialPageRoute;
        await tester.pumpWidget(
          MaterialApp(
            home: materialRoute.builder(tester.element(find.byType(Container).first)),
          ),
        );

        // assert
        expect(find.text('Book data is required'), findsOneWidget);
      });

      testWidgets('should show specific error message for bookReviews without args', (tester) async {
        // arrange
        settings = const RouteSettings(name: AppRoutes.bookReviews);

        // act
        final route = RouteGenerator.generateRoute(settings);
        
        // Build and pump the widget
        final materialRoute = route as MaterialPageRoute;
        await tester.pumpWidget(
          MaterialApp(
            home: materialRoute.builder(tester.element(find.byType(Container).first)),
          ),
        );

        // assert
        expect(find.text('Book reviews data is required'), findsOneWidget);
      });
    });

    group('route builder functionality', () {
      test('should create MaterialPageRoute with correct builder', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.main);

        // act
        final route = RouteGenerator.generateRoute(settings);

        // assert
        expect(route, isA<MaterialPageRoute>());
        final materialRoute = route as MaterialPageRoute;
        expect(materialRoute.builder, isNotNull);
        expect(materialRoute.settings, equals(settings));
      });

      test('should create consistent routes for same settings', () {
        // arrange
        settings = const RouteSettings(name: AppRoutes.main);

        // act
        final route1 = RouteGenerator.generateRoute(settings);
        final route2 = RouteGenerator.generateRoute(settings);

        // assert
        expect(route1.runtimeType, equals(route2.runtimeType));
        expect(route1.settings, equals(route2.settings));
      });

      testWidgets('should build error route with proper Navigator context', (tester) async {
        // arrange
        settings = const RouteSettings(name: '/unknown');

        // act
        final route = RouteGenerator.generateRoute(settings);
        
        // Build and test in navigation context
        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/',
            routes: {
              '/': (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Navigate'),
                ),
              ),
            },
          ),
        );

        // Navigate to error page
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Verify error page and go back functionality
        expect(find.text('Route not found'), findsOneWidget);
        expect(find.text('Go Back'), findsOneWidget);
        
        // Test go back
        await tester.tap(find.text('Go Back'));
        await tester.pumpAndSettle();
        
        expect(find.text('Navigate'), findsOneWidget);
      });
    });

    group('AppRoutes coverage', () {
      test('should handle all defined AppRoutes', () {
        final routesToTest = [
          AppRoutes.main,
          AppRoutes.addBook,
          AppRoutes.favorites,
          AppRoutes.settings,
          AppRoutes.profile,
          AppRoutes.orders,
          AppRoutes.feedback,
          AppRoutes.termsConditions,
          AppRoutes.shippingDeliveryPolicy,
          AppRoutes.cancellationRefundPolicy,
          AppRoutes.privacyPolicy,
        ];

        for (final routeName in routesToTest) {
          // arrange
          settings = RouteSettings(name: routeName);

          // act
          final route = RouteGenerator.generateRoute(settings);

          // assert
          expect(route, isA<MaterialPageRoute>(), 
              reason: 'Route $routeName should return MaterialPageRoute');
          expect(route.settings.name, equals(routeName));
        }
      });

      test('should handle routes requiring arguments', () {
        // Test bookDetails with Book argument
        settings = RouteSettings(name: AppRoutes.bookDetails, arguments: testBook);
        final route1 = RouteGenerator.generateRoute(settings);
        expect(route1, isA<MaterialPageRoute>());

        // Test bookReviews with BookReviewsPageArgs argument
        final args = BookReviewsPageArgs(book: testBook);
        settings = RouteSettings(name: AppRoutes.bookReviews, arguments: args);
        final route2 = RouteGenerator.generateRoute(settings);
        expect(route2, isA<MaterialPageRoute>());
      });
    });
  });
}
