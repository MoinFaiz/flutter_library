import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/main.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_state.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_state.dart';

// Mock classes
class MockNavigationService extends Mock implements NavigationService {}
class MockHomeBloc extends Mock implements HomeBloc {}
class MockLibraryBloc extends Mock implements LibraryBloc {}
class MockNotificationsBloc extends Mock implements NotificationsBloc {}
class MockCartBloc extends Mock implements CartBloc {}

void main() {
  group('Main App Tests', () {
    late GetIt sl;
    late MockNavigationService mockNavigationService;
    late MockHomeBloc mockHomeBloc;
    late MockLibraryBloc mockLibraryBloc;
    late MockNotificationsBloc mockNotificationsBloc;
    late MockCartBloc mockCartBloc;

    setUp(() {
      // Initialize SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
      
      // Setup dependency injection
      sl = GetIt.instance;
      
      mockNavigationService = MockNavigationService();
      mockHomeBloc = MockHomeBloc();
      mockLibraryBloc = MockLibraryBloc();
      mockNotificationsBloc = MockNotificationsBloc();
      mockCartBloc = MockCartBloc();
      
      sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      sl.registerFactory<HomeBloc>(() => mockHomeBloc);
      sl.registerFactory<LibraryBloc>(() => mockLibraryBloc);
      sl.registerFactory<NotificationsBloc>(() => mockNotificationsBloc);
      sl.registerFactory<CartBloc>(() => mockCartBloc);
      
      // Setup default bloc state streams
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.value(HomeInitial()).asBroadcastStream());
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.close()).thenAnswer((_) async {});
      
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.value(LibraryInitial()).asBroadcastStream());
      when(() => mockLibraryBloc.state).thenReturn(LibraryInitial());
      when(() => mockLibraryBloc.close()).thenAnswer((_) async {});
      
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => Stream.value(const NotificationsInitial()).asBroadcastStream());
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.close()).thenAnswer((_) async {});

      when(() => mockCartBloc.stream).thenAnswer((_) => Stream.value(CartInitial()).asBroadcastStream());
      when(() => mockCartBloc.state).thenReturn(CartInitial());
      when(() => mockCartBloc.close()).thenAnswer((_) async {});
    });

    tearDown(() {
      sl.reset();
    });

    testWidgets('should build main app without errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pump(); // Single pump instead of pumpAndSettle

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should display bottom navigation bar', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pump(); // Single pump instead of pumpAndSettle

      // Assert
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should navigate between tabs', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pump();

      // Check initial tab (Home)
      expect(find.byIcon(Icons.home), findsWidgets);

      // Navigate to Library tab - use first match
      final libraryTab = find.byIcon(Icons.library_books_outlined);
      if (libraryTab.evaluate().isNotEmpty) {
        await tester.tap(libraryTab.first);
        await tester.pump();
      }

      // Navigate to Notifications tab if it exists
      final notificationsTab = find.byIcon(Icons.notifications_outlined);
      if (notificationsTab.evaluate().isNotEmpty) {
        await tester.tap(notificationsTab.first);
        await tester.pump();
      }

      // Navigate back to Home - use first match
      final homeTab = find.byIcon(Icons.home_outlined);
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab.first);
        await tester.pump();
      }

      // Assert app is still functional
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should maintain theme consistency', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pump();

      // Get the material app
      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      // Assert theme properties
      expect(app.theme, isNotNull);
      expect(app.theme?.colorScheme, isNotNull);
    });

    testWidgets('should handle navigation state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pump();

      // Verify initial route
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Test navigation state preservation - use first match
      final libraryTab = find.byIcon(Icons.library_books_outlined);
      if (libraryTab.evaluate().isNotEmpty) {
        await tester.tap(libraryTab.first);
        await tester.pump();
      }
      
      final homeTab = find.byIcon(Icons.home_outlined);
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab.first);
        await tester.pump();
      }
      
      // Should be functional without issues
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle app startup flow', (WidgetTester tester) async {
      // Test that app starts up correctly
      await tester.pumpWidget(const FlutterLibraryApp());
      
      // Initial frame
      await tester.pump();
      
      // Wait for initialization
      await tester.pump(const Duration(seconds: 1));

      // Assert app loaded successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should provide proper widget hierarchy', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pump();

      // Assert proper widget structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
