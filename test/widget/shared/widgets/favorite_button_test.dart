import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/favorite_button.dart';
import 'package:flutter_library/core/theme/app_colors.dart';

void main() {
  group('FavoriteButton Widget Tests', () {
    Widget createFavoriteButton({
      bool isFavorite = false,
      VoidCallback? onPressed,
      double iconSize = 24,
      Color? activeColor,
      Color? inactiveColor,
      bool showBackground = false,
      Color? backgroundColor,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: FavoriteButton(
            isFavorite: isFavorite,
            onPressed: onPressed,
            iconSize: iconSize,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            showBackground: showBackground,
            backgroundColor: backgroundColor,
          ),
        ),
      );
    }

    testWidgets('should display unfavorite icon when not favorite', (tester) async {
      await tester.pumpWidget(createFavoriteButton(isFavorite: false));

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('should display favorite icon when is favorite', (tester) async {
      await tester.pumpWidget(createFavoriteButton(isFavorite: true));

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('should handle tap events', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createFavoriteButton(
        onPressed: () => tapped = true,
      ));

      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(createFavoriteButton(onPressed: null));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('should apply custom icon size', (tester) async {
      await tester.pumpWidget(createFavoriteButton(iconSize: 32));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, equals(32));
    });

    testWidgets('should use default active color when favorite', (tester) async {
      await tester.pumpWidget(createFavoriteButton(isFavorite: true));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(AppColors.favoriteColor));
    });

    testWidgets('should use custom active color when favorite', (tester) async {
      await tester.pumpWidget(createFavoriteButton(
        isFavorite: true,
        activeColor: Colors.blue,
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(Colors.blue));
    });

    testWidgets('should use custom inactive color when not favorite', (tester) async {
      await tester.pumpWidget(createFavoriteButton(
        isFavorite: false,
        inactiveColor: Colors.grey,
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(Colors.grey));
    });

    testWidgets('should use null color when not favorite and no inactive color', (tester) async {
      await tester.pumpWidget(createFavoriteButton(isFavorite: false));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, isNull);
    });

    testWidgets('should not show background by default', (tester) async {
      await tester.pumpWidget(createFavoriteButton());

      expect(find.byType(Container), findsNothing);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should show background when showBackground is true', (tester) async {
      await tester.pumpWidget(createFavoriteButton(showBackground: true));

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should use default background color', (tester) async {
      await tester.pumpWidget(createFavoriteButton(showBackground: true));

      final context = tester.element(find.byType(FavoriteButton));
      final expectedColor = Theme.of(context).colorScheme.surface.withValues(alpha: 0.9);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(expectedColor));
    });

    testWidgets('should use custom background color', (tester) async {
      await tester.pumpWidget(createFavoriteButton(
        showBackground: true,
        backgroundColor: Colors.red,
      ));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.red));
    });

    testWidgets('should have circular background shape', (tester) async {
      await tester.pumpWidget(createFavoriteButton(showBackground: true));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('should have compact visual density', (tester) async {
      await tester.pumpWidget(createFavoriteButton());

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.visualDensity, equals(VisualDensity.compact));
    });

    testWidgets('should toggle favorite state through callbacks', (tester) async {
      bool isFavorite = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: FavoriteButton(
                  isFavorite: isFavorite,
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      // Initially not favorite
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap to favorite
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: FavoriteButton(
              isFavorite: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(FavoriteButton), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should handle rapid state changes', (tester) async {
      bool isFavorite = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: FavoriteButton(
                  isFavorite: isFavorite,
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      // Rapid taps
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(find.byType(FavoriteButton), findsOneWidget);
    });

    testWidgets('should maintain button accessibility', (tester) async {
      await tester.pumpWidget(createFavoriteButton(
        isFavorite: false,
        onPressed: () {},
      ));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('should handle edge case sizes', (tester) async {
      // Test very small size
      await tester.pumpWidget(createFavoriteButton(iconSize: 8));
      expect(find.byType(FavoriteButton), findsOneWidget);

      // Test very large size
      await tester.pumpWidget(createFavoriteButton(iconSize: 100));
      expect(find.byType(FavoriteButton), findsOneWidget);
    });

    testWidgets('should work without background colors', (tester) async {
      await tester.pumpWidget(createFavoriteButton(
        showBackground: true,
        backgroundColor: null,
      ));

      final context = tester.element(find.byType(FavoriteButton));
      final expectedColor = Theme.of(context).colorScheme.surface.withValues(alpha: 0.9);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(expectedColor));
    });

    testWidgets('should handle transparent colors', (tester) async {
      await tester.pumpWidget(createFavoriteButton(
        isFavorite: true,
        activeColor: Colors.transparent,
        showBackground: true,
        backgroundColor: Colors.transparent,
      ));

      expect(find.byType(FavoriteButton), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should preserve widget properties after rebuild', (tester) async {
      await tester.pumpWidget(createFavoriteButton(
        isFavorite: true,
        iconSize: 30,
        activeColor: Colors.red,
        showBackground: true,
      ));

      // Rebuild with same properties
      await tester.pumpWidget(createFavoriteButton(
        isFavorite: true,
        iconSize: 30,
        activeColor: Colors.red,
        showBackground: true,
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, equals(30));
      expect(icon.color, equals(Colors.red));
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should work in constrained layouts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 50,
              height: 50,
              child: FavoriteButton(
                isFavorite: true,
                onPressed: () {},
                iconSize: 20,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FavoriteButton), findsOneWidget);
    });

    testWidgets('should handle multiple instances correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FavoriteButton(isFavorite: true, onPressed: () {}),
                FavoriteButton(isFavorite: false, onPressed: () {}),
                FavoriteButton(isFavorite: true, showBackground: true, onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FavoriteButton), findsNWidgets(3));
      expect(find.byIcon(Icons.favorite), findsNWidgets(2));
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });
  });
}
