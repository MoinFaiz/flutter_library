import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/core/presentation/main_navigation_scaffold.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_state.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_state.dart';

// Mock classes
class MockNavigationService extends Mock implements NavigationService {}
class MockHomeBloc extends Mock implements HomeBloc {}
class MockLibraryBloc extends Mock implements LibraryBloc {}
class MockNotificationsBloc extends Mock implements NotificationsBloc {}

void main() {
  group('MainNavigationScaffold', () {
    late MockNavigationService mockNavigationService;
    late MockHomeBloc mockHomeBloc;
    late MockLibraryBloc mockLibraryBloc;
    late MockNotificationsBloc mockNotificationsBloc;
    late GetIt sl;

    setUp(() {
      mockNavigationService = MockNavigationService();
      mockHomeBloc = MockHomeBloc();
      mockLibraryBloc = MockLibraryBloc();
      mockNotificationsBloc = MockNotificationsBloc();
      
      // Setup dependency injection
      sl = GetIt.instance;
      sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      sl.registerFactory<HomeBloc>(() => mockHomeBloc);
      sl.registerFactory<LibraryBloc>(() => mockLibraryBloc);
      sl.registerFactory<NotificationsBloc>(() => mockNotificationsBloc);
      
      // Setup default bloc state streams
      when(() => mockHomeBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.close()).thenAnswer((_) async {});
      
      when(() => mockLibraryBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockLibraryBloc.state).thenReturn(LibraryInitial());
      when(() => mockLibraryBloc.close()).thenAnswer((_) async {});
      
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsInitial());
      when(() => mockNotificationsBloc.close()).thenAnswer((_) async {});
    });

    tearDown(() {
      sl.reset();
    });

    testWidgets('displays scaffold with bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScaffold(),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('has five navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScaffold(),
        ),
      );

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.items.length, equals(5));
    });

    testWidgets('has correct navigation tab labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScaffold(),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Drawer'), findsOneWidget);
    });

    testWidgets('has correct navigation tab icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScaffold(),
        ),
      );
      
      await tester.pump();

      // Check that the bottom navigation bar has icons
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.items.length, equals(5));
      
      // Verify each item has an icon
      for (final item in bottomNavBar.items) {
        expect(item.icon, isA<Icon>());
      }
    });

    testWidgets('has app drawer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScaffold(),
        ),
      );
      
      await tester.pump();

      // Find all scaffolds and check the innermost one for drawer
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsWidgets);
      
      // The MainNavigationScaffold's Scaffold should have a drawer
      bool hasDrawer = false;
      for (final element in scaffolds.evaluate()) {
        final scaffold = element.widget as Scaffold;
        if (scaffold.drawer != null) {
          hasDrawer = true;
          break;
        }
      }
      expect(hasDrawer, isTrue);
    });

    testWidgets('switches between tabs when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScaffold(),
        ),
      );
      
      await tester.pump();

      // Tap on Library tab
      await tester.tap(find.text('Library'));
      await tester.pump();

      // Verify tab switched
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, equals(1));
    });

    testWidgets('displays correct initial tab (Home)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScaffold(),
        ),
      );

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, equals(0));
    });

    testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigationScaffold(),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
