import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/shared/widgets/cart_icon_button.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  late MockNavigationService mockNavigationService;
  late GetIt sl;

  setUp(() {
    mockNavigationService = MockNavigationService();
    
    // Setup dependency injection
    sl = GetIt.instance;
    if (!sl.isRegistered<NavigationService>()) {
      sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
    }
  });

  tearDown(() {
    if (sl.isRegistered<NavigationService>()) {
      sl.unregister<NavigationService>();
    }
  });

  Widget createWidgetUnderTest({int itemCount = 0}) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            CartIconButton(itemCount: itemCount),
          ],
        ),
      ),
    );
  }

  group('CartIconButton Widget Tests', () {
    testWidgets('should display cart icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should not display badge when cart is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      // Badge should not be visible
      expect(find.text('0'), findsNothing);
    });

    testWidgets('should display badge with item count when cart has items', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(itemCount: 2));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should display 99+ when cart has more than 99 items', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(itemCount: 100));
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('should navigate to cart page when tapped', (WidgetTester tester) async {
      when(() => mockNavigationService.navigateTo(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      verify(() => mockNavigationService.navigateTo(AppRoutes.cart)).called(1);
    });

    testWidgets('should use custom colors when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                const CartIconButton(
                  iconColor: Colors.red,
                  badgeColor: Colors.green,
                  badgeTextColor: Colors.yellow,
                ),
              ],
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final icon = iconButton.icon as Icon;
      expect(icon.color, Colors.red);
    });

    testWidgets('should update badge when item count parameter changes', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(itemCount: 0));
      expect(find.text('1'), findsNothing);

      await tester.pumpWidget(createWidgetUnderTest(itemCount: 1));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });
  });
}
