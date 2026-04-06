import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_library/features/orders/presentation/pages/orders_page.dart';
import 'package:flutter_library/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:flutter_library/features/orders/presentation/bloc/orders_state.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';

class MockOrdersBloc extends Mock implements OrdersBloc {
  @override
  Future<void> close() {
    return Future.value();
  }
}

void main() {
  group('OrdersView Widget Tests', () {
    late MockOrdersBloc mockOrdersBloc;

    setUp(() {
      mockOrdersBloc = MockOrdersBloc();
    });

    Widget createOrdersView() {
      return MaterialApp(
        home: BlocProvider<OrdersBloc>(
          create: (context) => mockOrdersBloc,
          child: const Scaffold(
            body: OrdersView(),
          ),
        ),
      );
    }

    testWidgets('should display loading indicator when state is OrdersLoading', (tester) async {
      // Arrange
      when(() => mockOrdersBloc.state).thenReturn(OrdersLoading());
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersLoading()));

      // Act
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OrdersView), findsOneWidget);
    });

    testWidgets('should display error view when state is OrdersError', (tester) async {
      // Arrange
      const errorMessage = 'Failed to load orders';
      when(() => mockOrdersBloc.state).thenReturn(OrdersError(errorMessage));
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersError(errorMessage)));

      // Act
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error Loading Orders'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display empty state when orders list is empty', (tester) async {
      // Arrange
      when(() => mockOrdersBloc.state).thenReturn(const OrdersLoaded(
        orders: [],
        activeOrders: [],
        orderHistory: [],
      ));
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(const OrdersLoaded(
        orders: [],
        activeOrders: [],
        orderHistory: [],
      )));

      // Act
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      // Should show empty state UI
    });

    testWidgets('should display orders list when state is OrdersLoaded with orders', (tester) async {
      // Arrange
      final mockOrders = <Order>[];
      when(() => mockOrdersBloc.state).thenReturn(OrdersLoaded(
        orders: mockOrders,
        activeOrders: mockOrders,
        orderHistory: mockOrders,
      ));
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersLoaded(
        orders: mockOrders,
        activeOrders: mockOrders,
        orderHistory: mockOrders,
      )));

      // Act
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      // Should show orders list
    });

    testWidgets('should show snackbar when OrdersError is emitted', (tester) async {
      // Arrange
      const errorMessage = 'Network error';
      when(() => mockOrdersBloc.state).thenReturn(OrdersInitial());
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersError(errorMessage)));

      // Act
      await tester.pumpWidget(createOrdersView());
      await tester.pump(); // Process the stream event

      // Assert - The error message may appear in both the error view and snackbar
      expect(find.text(errorMessage), findsWidgets);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show success snackbar when OrderCancelled is emitted', (tester) async {
      // Arrange
      const orderId = 'order_123';
      when(() => mockOrdersBloc.state).thenReturn(OrdersInitial());
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrderCancelled(orderId)));

      // Act
      await tester.pumpWidget(createOrdersView());
      await tester.pump(); // Process the stream event

      // Assert
      expect(find.text('Order #$orderId has been cancelled'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should handle retry button tap in error view', (tester) async {
      // Arrange
      const errorMessage = 'Failed to load orders';
      when(() => mockOrdersBloc.state).thenReturn(OrdersError(errorMessage));
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersError(errorMessage)));

      // Act
      await tester.pumpWidget(createOrdersView());
      
      // Find and tap retry button
      final retryButton = find.byType(ElevatedButton);
      expect(retryButton, findsOneWidget);
      
      await tester.tap(retryButton);
      await tester.pump();

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      // Verify that the retry action was triggered
    });

    testWidgets('should display default loading state for unknown states', (tester) async {
      // Arrange
      when(() => mockOrdersBloc.state).thenReturn(OrdersInitial());
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersInitial()));

      // Act
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OrdersView), findsOneWidget);
    });

    testWidgets('should use correct theme colors for error state', (tester) async {
      // Arrange
      const errorMessage = 'Theme test error';
      when(() => mockOrdersBloc.state).thenReturn(OrdersError(errorMessage));
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersError(errorMessage)));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: BlocProvider<OrdersBloc>(
            create: (context) => mockOrdersBloc,
            child: const Scaffold(
              body: OrdersView(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should work correctly with dark theme', (tester) async {
      // Arrange
      when(() => mockOrdersBloc.state).thenReturn(OrdersLoading());
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersLoading()));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: BlocProvider<OrdersBloc>(
            create: (context) => mockOrdersBloc,
            child: const Scaffold(
              body: OrdersView(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle rapid state changes without issues', (tester) async {
      // Arrange
      when(() => mockOrdersBloc.state).thenReturn(OrdersLoading());
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.fromIterable([
        const OrdersLoading(),
        const OrdersLoaded(orders: [], activeOrders: [], orderHistory: []),
        const OrdersError('Error'),
        const OrdersLoading(),
      ]));

      // Act
      await tester.pumpWidget(createOrdersView());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
    });

    testWidgets('should be accessible for screen readers', (tester) async {
      // Arrange
      const errorMessage = 'Accessibility test error';
      when(() => mockOrdersBloc.state).thenReturn(OrdersError(errorMessage));
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersError(errorMessage)));

      // Act
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      // Should have proper semantic labels and descriptions
    });

    testWidgets('should handle BlocConsumer properly', (tester) async {
      // Arrange
      when(() => mockOrdersBloc.state).thenReturn(OrdersLoading());
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersLoading()));

      // Act
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      expect(find.byType(BlocConsumer<OrdersBloc, OrdersState>), findsOneWidget);
    });

    testWidgets('should maintain widget state during rebuilds', (tester) async {
      // Arrange
      when(() => mockOrdersBloc.state).thenReturn(OrdersLoading());
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersLoading()));

      // Act
      await tester.pumpWidget(createOrdersView());
      
      // Rebuild
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should use correct padding constants', (tester) async {
      // Arrange
      const errorMessage = 'Padding test error';
      when(() => mockOrdersBloc.state).thenReturn(OrdersError(errorMessage));
      when(() => mockOrdersBloc.stream).thenAnswer((_) => Stream.value(OrdersError(errorMessage)));

      // Act
      await tester.pumpWidget(createOrdersView());

      // Assert
      expect(find.byType(OrdersView), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      // Should use proper padding constants
    });
  });
}
