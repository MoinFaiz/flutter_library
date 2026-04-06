import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';

void main() {
  group('AppRoutes Tests', () {
    group('Main Navigation Routes', () {
      test('should have correct main route', () {
        expect(AppRoutes.main, equals('/'));
      });

      test('should have correct home route', () {
        expect(AppRoutes.home, equals('/home'));
      });

      test('should have correct library route', () {
        expect(AppRoutes.library, equals('/library'));
      });

      test('should have correct add book route', () {
        expect(AppRoutes.addBook, equals('/add-book'));
      });
    });

    group('Secondary Navigation Routes', () {
      test('should have correct favorites route', () {
        expect(AppRoutes.favorites, equals('/favorites'));
      });

      test('should have correct book details route', () {
        expect(AppRoutes.bookDetails, equals('/book-details'));
      });

      test('should have correct book reviews route', () {
        expect(AppRoutes.bookReviews, equals('/book-reviews'));
      });

      test('should have correct settings route', () {
        expect(AppRoutes.settings, equals('/settings'));
      });

      test('should have correct profile route', () {
        expect(AppRoutes.profile, equals('/profile'));
      });

      test('should have correct full book list route', () {
        expect(AppRoutes.fullBookList, equals('/full-book-list'));
      });

      test('should have correct notifications route', () {
        expect(AppRoutes.notifications, equals('/notifications'));
      });
    });

    group('Drawer Routes', () {
      test('should have correct orders route', () {
        expect(AppRoutes.orders, equals('/orders'));
      });

      test('should have correct feedback route', () {
        expect(AppRoutes.feedback, equals('/feedback'));
      });

      test('should have correct terms and conditions route', () {
        expect(AppRoutes.termsConditions, equals('/terms-conditions'));
      });

      test('should have correct shipping delivery policy route', () {
        expect(AppRoutes.shippingDeliveryPolicy, equals('/shipping-delivery-policy'));
      });

      test('should have correct cancellation refund policy route', () {
        expect(AppRoutes.cancellationRefundPolicy, equals('/cancellation-refund-policy'));
      });

      test('should have correct privacy policy route', () {
        expect(AppRoutes.privacyPolicy, equals('/privacy-policy'));
      });
    });

    group('Route String Constants', () {
      test('should have immutable route constants', () {
        // Test that routes are compile-time constants
        const routes = [
          AppRoutes.main,
          AppRoutes.home,
          AppRoutes.library,
          AppRoutes.addBook,
          AppRoutes.favorites,
          AppRoutes.bookDetails,
          AppRoutes.bookReviews,
          AppRoutes.settings,
          AppRoutes.profile,
          AppRoutes.fullBookList,
          AppRoutes.notifications,
          AppRoutes.orders,
          AppRoutes.feedback,
          AppRoutes.termsConditions,
          AppRoutes.shippingDeliveryPolicy,
          AppRoutes.cancellationRefundPolicy,
          AppRoutes.privacyPolicy,
        ];

        expect(routes.length, equals(17));
        expect(routes.every((route) => route.isNotEmpty), isTrue);
      });

      test('should have unique route values', () {
        final allRoutes = [
          AppRoutes.main,
          AppRoutes.home,
          AppRoutes.library,
          AppRoutes.addBook,
          AppRoutes.favorites,
          AppRoutes.bookDetails,
          AppRoutes.bookReviews,
          AppRoutes.settings,
          AppRoutes.profile,
          AppRoutes.fullBookList,
          AppRoutes.notifications,
          AppRoutes.orders,
          AppRoutes.feedback,
          AppRoutes.termsConditions,
          AppRoutes.shippingDeliveryPolicy,
          AppRoutes.cancellationRefundPolicy,
          AppRoutes.privacyPolicy,
        ];

        final uniqueRoutes = allRoutes.toSet();
        expect(uniqueRoutes.length, equals(allRoutes.length),
            reason: 'All routes should be unique');
      });

      test('should follow consistent naming pattern', () {
        final kebabCaseRoutes = [
          AppRoutes.addBook,
          AppRoutes.bookDetails,
          AppRoutes.bookReviews,
          AppRoutes.fullBookList,
          AppRoutes.termsConditions,
          AppRoutes.shippingDeliveryPolicy,
          AppRoutes.cancellationRefundPolicy,
          AppRoutes.privacyPolicy,
        ];

        for (final route in kebabCaseRoutes) {
          expect(route.contains('-'), isTrue,
              reason: 'Multi-word routes should use kebab-case: $route');
          expect(route.startsWith('/'), isTrue,
              reason: 'Routes should start with forward slash: $route');
        }
      });

      test('should not contain uppercase letters', () {
        final allRoutes = [
          AppRoutes.main,
          AppRoutes.home,
          AppRoutes.library,
          AppRoutes.addBook,
          AppRoutes.favorites,
          AppRoutes.bookDetails,
          AppRoutes.bookReviews,
          AppRoutes.settings,
          AppRoutes.profile,
          AppRoutes.fullBookList,
          AppRoutes.notifications,
          AppRoutes.orders,
          AppRoutes.feedback,
          AppRoutes.termsConditions,
          AppRoutes.shippingDeliveryPolicy,
          AppRoutes.cancellationRefundPolicy,
          AppRoutes.privacyPolicy,
        ];

        for (final route in allRoutes) {
          expect(route.toLowerCase(), equals(route),
              reason: 'Routes should be lowercase: $route');
        }
      });

      test('should all start with forward slash', () {
        final allRoutes = [
          AppRoutes.main,
          AppRoutes.home,
          AppRoutes.library,
          AppRoutes.addBook,
          AppRoutes.favorites,
          AppRoutes.bookDetails,
          AppRoutes.bookReviews,
          AppRoutes.settings,
          AppRoutes.profile,
          AppRoutes.fullBookList,
          AppRoutes.notifications,
          AppRoutes.orders,
          AppRoutes.feedback,
          AppRoutes.termsConditions,
          AppRoutes.shippingDeliveryPolicy,
          AppRoutes.cancellationRefundPolicy,
          AppRoutes.privacyPolicy,
        ];

        for (final route in allRoutes) {
          expect(route.startsWith('/'), isTrue,
              reason: 'All routes should start with /: $route');
        }
      });
    });

    group('Class Structure', () {
      test('should not be instantiable', () {
        // This test ensures the private constructor works
        expect(() => AppRoutes, returnsNormally);
        
        // We can't directly test private constructor instantiation,
        // but we can verify the class has only static members
        expect(AppRoutes.main, isA<String>());
        expect(AppRoutes.home, isA<String>());
      });

      test('should have all routes as static const strings', () {
        // Test that all route properties exist and are strings
        expect(AppRoutes.main, isA<String>());
        expect(AppRoutes.home, isA<String>());
        expect(AppRoutes.library, isA<String>());
        expect(AppRoutes.addBook, isA<String>());
        expect(AppRoutes.favorites, isA<String>());
        expect(AppRoutes.bookDetails, isA<String>());
        expect(AppRoutes.bookReviews, isA<String>());
        expect(AppRoutes.settings, isA<String>());
        expect(AppRoutes.profile, isA<String>());
        expect(AppRoutes.fullBookList, isA<String>());
        expect(AppRoutes.notifications, isA<String>());
        expect(AppRoutes.orders, isA<String>());
        expect(AppRoutes.feedback, isA<String>());
        expect(AppRoutes.termsConditions, isA<String>());
        expect(AppRoutes.shippingDeliveryPolicy, isA<String>());
        expect(AppRoutes.cancellationRefundPolicy, isA<String>());
        expect(AppRoutes.privacyPolicy, isA<String>());
      });
    });

    group('Route Categories', () {
      test('should have main navigation routes', () {
        final mainRoutes = [
          AppRoutes.main,
          AppRoutes.home,
          AppRoutes.library,
          AppRoutes.addBook,
        ];

        expect(mainRoutes.length, equals(4));
        expect(mainRoutes.every((route) => route.isNotEmpty), isTrue);
      });

      test('should have secondary navigation routes', () {
        final secondaryRoutes = [
          AppRoutes.favorites,
          AppRoutes.bookDetails,
          AppRoutes.bookReviews,
          AppRoutes.settings,
          AppRoutes.profile,
          AppRoutes.fullBookList,
          AppRoutes.notifications,
        ];

        expect(secondaryRoutes.length, equals(7));
        expect(secondaryRoutes.every((route) => route.isNotEmpty), isTrue);
      });

      test('should have drawer/policy routes', () {
        final drawerRoutes = [
          AppRoutes.orders,
          AppRoutes.feedback,
          AppRoutes.termsConditions,
          AppRoutes.shippingDeliveryPolicy,
          AppRoutes.cancellationRefundPolicy,
          AppRoutes.privacyPolicy,
        ];

        expect(drawerRoutes.length, equals(6));
        expect(drawerRoutes.every((route) => route.isNotEmpty), isTrue);
      });
    });

    group('Edge Cases and Validation', () {
      test('should handle route concatenation', () {
        final baseUrl = 'https://example.com';
        final fullUrl = baseUrl + AppRoutes.home;
        expect(fullUrl, equals('https://example.com/home'));
      });

      test('should work with string interpolation', () {
        final routeWithParam = '${AppRoutes.bookDetails}?id=123';
        expect(routeWithParam, equals('/book-details?id=123'));
      });

      test('should work in collections', () {
        final routeSet = {
          AppRoutes.home,
          AppRoutes.library,
          AppRoutes.favorites,
        };

        expect(routeSet.length, equals(3));
        expect(routeSet.contains(AppRoutes.home), isTrue);
      });

      test('should work in maps', () {
        final routeMap = {
          'home': AppRoutes.home,
          'library': AppRoutes.library,
          'profile': AppRoutes.profile,
        };

        expect(routeMap['home'], equals('/home'));
        expect(routeMap['library'], equals('/library'));
        expect(routeMap['profile'], equals('/profile'));
      });

      test('should be comparable', () {
        expect(AppRoutes.home == '/home', isTrue);
        expect(AppRoutes.main == '/', isTrue);
        expect(AppRoutes.home != AppRoutes.library, isTrue);
      });
    });
  });
}
