import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/cart_icon_button.dart';

void main() {
  group('CartIconButton Tests', () {
    group('Constructor', () {
      test('should create CartIconButton with default parameters', () {
        const button = CartIconButton();
        expect(button, isA<CartIconButton>());
        expect(button.iconColor, isNull);
        expect(button.badgeColor, isNull);
        expect(button.badgeTextColor, isNull);
      });

      test('should create CartIconButton with custom icon color', () {
        const button = CartIconButton(iconColor: Color(0xFF000000));
        expect(button.iconColor, const Color(0xFF000000));
      });

      test('should create CartIconButton with custom badge color', () {
        const button = CartIconButton(badgeColor: Color(0xFFFF0000));
        expect(button.badgeColor, const Color(0xFFFF0000));
      });

      test('should create CartIconButton with custom badge text color', () {
        const button = CartIconButton(badgeTextColor: Color(0xFFFFFFFF));
        expect(button.badgeTextColor, const Color(0xFFFFFFFF));
      });

      test('should create CartIconButton with all custom colors', () {
        const button = CartIconButton(
          iconColor: Color(0xFF123456),
          badgeColor: Color(0xFF654321),
          badgeTextColor: Color(0xFFABCDEF),
        );
        expect(button.iconColor, const Color(0xFF123456));
        expect(button.badgeColor, const Color(0xFF654321));
        expect(button.badgeTextColor, const Color(0xFFABCDEF));
      });
    });

    group('Properties', () {
      test('should have nullable iconColor property', () {
        const button1 = CartIconButton();
        const button2 = CartIconButton(iconColor: Color(0xFF000000));

        expect(button1.iconColor, isNull);
        expect(button2.iconColor, isNotNull);
      });

      test('should have nullable badgeColor property', () {
        const button1 = CartIconButton();
        const button2 = CartIconButton(badgeColor: Color(0xFFFF0000));

        expect(button1.badgeColor, isNull);
        expect(button2.badgeColor, isNotNull);
      });

      test('should have nullable badgeTextColor property', () {
        const button1 = CartIconButton();
        const button2 = CartIconButton(badgeTextColor: Color(0xFFFFFFFF));

        expect(button1.badgeTextColor, isNull);
        expect(button2.badgeTextColor, isNotNull);
      });
    });

    group('Immutability', () {
      test('should be immutable', () {
        const button1 = CartIconButton(iconColor: Color(0xFF000000));
        const button2 = CartIconButton(iconColor: Color(0xFF000000));

        expect(button1.iconColor, equals(button2.iconColor));
      });
    });

    group('Edge Cases', () {
      test('should handle transparent colors', () {
        const button = CartIconButton(
          iconColor: Color(0x00000000),
          badgeColor: Color(0x00000000),
          badgeTextColor: Color(0x00000000),
        );

        expect(button.iconColor, const Color(0x00000000));
        expect(button.badgeColor, const Color(0x00000000));
        expect(button.badgeTextColor, const Color(0x00000000));
      });

      test('should handle maximum color values', () {
        const button = CartIconButton(
          iconColor: Color(0xFFFFFFFF),
          badgeColor: Color(0xFFFFFFFF),
          badgeTextColor: Color(0xFFFFFFFF),
        );

        expect(button.iconColor, const Color(0xFFFFFFFF));
        expect(button.badgeColor, const Color(0xFFFFFFFF));
        expect(button.badgeTextColor, const Color(0xFFFFFFFF));
      });
    });
  });
}
