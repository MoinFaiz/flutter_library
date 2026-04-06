import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';

void main() {
  group('ResponsiveUtils Tests', () {
    testWidgets('isMobile should return true for mobile screen sizes', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final isMobile = ResponsiveUtils.isMobile(context);
                return Scaffold(
                  body: Text('Is Mobile: $isMobile'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size (< 600)
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Is Mobile: true'), findsOneWidget);

      // Test tablet size (>= 600)
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Is Mobile: false'), findsOneWidget);
    });

    testWidgets('isTablet should return true for tablet screen sizes', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final isTablet = ResponsiveUtils.isTablet(context);
                return Scaffold(
                  body: Text('Is Tablet: $isTablet'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size (< 600)
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Is Tablet: false'), findsOneWidget);

      // Test tablet size (600-899)
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Is Tablet: true'), findsOneWidget);

      // Test desktop size (>= 1200)
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Is Tablet: false'), findsOneWidget);
    });

    testWidgets('isDesktop should return true for desktop screen sizes', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final isDesktop = ResponsiveUtils.isDesktop(context);
                return Scaffold(
                  body: Text('Is Desktop: $isDesktop'),
                );
              },
            ),
          ),
        );
      }

      // Test tablet size (< 1200)
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Is Desktop: false'), findsOneWidget);

      // Test desktop size (>= 1200)
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Is Desktop: true'), findsOneWidget);
    });

    testWidgets('getResponsivePadding should return correct padding for different screen sizes', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveUtils.getResponsivePadding(context);
                return Scaffold(
                  body: Text('Padding: ${padding.left}'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size - should return 16.0
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Padding: 16.0'), findsOneWidget);

      // Test tablet size - should return 24.0
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Padding: 24.0'), findsOneWidget);

      // Test desktop size - should return 32.0
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Padding: 32.0'), findsOneWidget);
    });

    testWidgets('getResponsiveHorizontalPadding should return correct horizontal padding', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
                return Scaffold(
                  body: Text('H-Padding: ${padding.left}'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('H-Padding: 16.0'), findsOneWidget);

      // Test tablet size
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('H-Padding: 24.0'), findsOneWidget);

      // Test desktop size
      await tester.pumpWidget(buildTestWidget(const Size(1100, 800)));
      expect(find.text('H-Padding: 32.0'), findsOneWidget);
    });

    testWidgets('getResponsiveContentWidth should return correct content width', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final width = ResponsiveUtils.getResponsiveContentWidth(context);
                return Scaffold(
                  body: Text('Content Width: $width'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size - should return full width
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Content Width: 400.0'), findsOneWidget);

      // Test tablet size - should return 90% of width
      await tester.pumpWidget(buildTestWidget(const Size(800, 1000)));
      expect(find.text('Content Width: 720.0'), findsOneWidget);

      // Test very large desktop - should return max width of 1000
      await tester.pumpWidget(buildTestWidget(const Size(1600, 800)));
      expect(find.text('Content Width: 1000.0'), findsOneWidget);
    });

    testWidgets('getResponsiveBookCoverSize should return correct size', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final coverSize = ResponsiveUtils.getResponsiveBookCoverSize(context);
                return Scaffold(
                  body: Text('Cover: ${coverSize.width}x${coverSize.height}'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Cover: 60.0x80.0'), findsOneWidget);

      // Test tablet size
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Cover: 80.0x100.0'), findsOneWidget);

      // Test desktop size
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Cover: 100.0x120.0'), findsOneWidget);
    });

    testWidgets('getResponsiveStarSize should return correct star size', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final starSize = ResponsiveUtils.getResponsiveStarSize(context);
                return Scaffold(
                  body: Text('Star Size: $starSize'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Star Size: 40.0'), findsOneWidget);

      // Test tablet size
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Star Size: 48.0'), findsOneWidget);

      // Test desktop size
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Star Size: 56.0'), findsOneWidget);
    });

    testWidgets('getResponsiveAvatarRadius should return correct avatar radius', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final radius = ResponsiveUtils.getResponsiveAvatarRadius(context);
                return Scaffold(
                  body: Text('Avatar Radius: $radius'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Avatar Radius: 20.0'), findsOneWidget);

      // Test tablet size
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Avatar Radius: 24.0'), findsOneWidget);

      // Test desktop size
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Avatar Radius: 28.0'), findsOneWidget);
    });

    testWidgets('getResponsiveModalSizes should return correct modal sizes', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final modalSizes = ResponsiveUtils.getResponsiveModalSizes(context);
                return Scaffold(
                  body: Text('Modal Initial: ${modalSizes['initial']}'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Modal Initial: 0.7'), findsOneWidget);

      // Test tablet size
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Modal Initial: 0.6'), findsOneWidget);

      // Test desktop size
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Modal Initial: 0.5'), findsOneWidget);
    });

    testWidgets('getResponsiveTextFieldLines should return correct max lines', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final lines = ResponsiveUtils.getResponsiveTextFieldLines(context);
                return Scaffold(
                  body: Text('Text Field Lines: $lines'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Text Field Lines: 6'), findsOneWidget);

      // Test tablet size
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Text Field Lines: 8'), findsOneWidget);

      // Test desktop size
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Text Field Lines: 10'), findsOneWidget);
    });

    testWidgets('getResponsiveSpacing should return correct spacing', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final spacing = ResponsiveUtils.getResponsiveSpacing(context);
                return Scaffold(
                  body: Text('Spacing: $spacing'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size (base * 1)
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Spacing: 16.0'), findsOneWidget);

      // Test tablet size (base * 1.25)
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Spacing: 20.0'), findsOneWidget);

      // Test desktop size (base * 1.5)
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Spacing: 24.0'), findsOneWidget);
    });

    testWidgets('getResponsiveSpacing should accept custom base value', (WidgetTester tester) async {
      Widget buildTestWidget(Size size) {
        return MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final spacing = ResponsiveUtils.getResponsiveSpacing(context, base: 20.0);
                return Scaffold(
                  body: Text('Custom Spacing: $spacing'),
                );
              },
            ),
          ),
        );
      }

      // Test mobile size with custom base
      await tester.pumpWidget(buildTestWidget(const Size(400, 800)));
      expect(find.text('Custom Spacing: 20.0'), findsOneWidget);

      // Test tablet size with custom base
      await tester.pumpWidget(buildTestWidget(const Size(700, 1000)));
      expect(find.text('Custom Spacing: 25.0'), findsOneWidget);

      // Test desktop size with custom base
      await tester.pumpWidget(buildTestWidget(const Size(1300, 800)));
      expect(find.text('Custom Spacing: 30.0'), findsOneWidget);
    });

    testWidgets('should handle very large screen sizes correctly', (WidgetTester tester) async {
      Widget buildTestWidget() {
        return MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(2000, 1200)),
            child: Builder(
              builder: (context) {
                final hPadding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
                final contentWidth = ResponsiveUtils.getResponsiveContentWidth(context);
                return Scaffold(
                  body: Column(
                    children: [
                      Text('H-Padding: ${hPadding.left}'),
                      Text('Content Width: $contentWidth'),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(buildTestWidget());
      
      // For very large screens, horizontal padding should be calculated differently
      expect(find.textContaining('H-Padding:'), findsOneWidget);
      expect(find.text('Content Width: 1000.0'), findsOneWidget);
    });
  });
}
