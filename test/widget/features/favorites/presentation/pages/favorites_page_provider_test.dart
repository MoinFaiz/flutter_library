import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';

// Mock classes
class MockFavoritesBloc extends Mock implements FavoritesBloc {}

class MockNavigationService extends Mock implements NavigationService {}

class FakeFavoritesEvent extends Fake implements FavoritesEvent {}

void main() {
  late GetIt sl;
  late MockNavigationService mockNavigationService;

  setUpAll(() {
    registerFallbackValue(FakeFavoritesEvent());
  });

  group('FavoritesPage Provider Test (Manual Setup)', () {
    late MockFavoritesBloc mockFavoritesBloc;

    setUp(() {
      mockFavoritesBloc = MockFavoritesBloc();
      mockNavigationService = MockNavigationService();
      
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesInitial());
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockFavoritesBloc.add(any())).thenReturn(null);
      when(() => mockFavoritesBloc.close()).thenAnswer((_) async {});
      
      when(() => mockNavigationService.navigateTo<dynamic>(
        any(),
        arguments: any(named: 'arguments'),
      )).thenAnswer((_) async => null);
      
      // Setup GetIt
      sl = GetIt.instance;
      // Unregister if already registered, then register fresh
      if (sl.isRegistered<NavigationService>()) {
        sl.unregister<NavigationService>();
      }
      sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
    });

    tearDown(() async {
      // Clean up GetIt after test
      if (sl.isRegistered<NavigationService>()) {
        await sl.unregister<NavigationService>();
      }
    });

    testWidgets('can create BlocProvider with FavoritesBloc manually', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      expect(find.byType(BlocProvider<FavoritesBloc>), findsOneWidget);
      expect(find.byType(FavoritesPage), findsOneWidget);
    });

    testWidgets('provides FavoritesBloc to FavoritesPage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      final favoritesPageFinder = find.byType(FavoritesPage);
      expect(favoritesPageFinder, findsOneWidget);

      final context = tester.element(favoritesPageFinder);
      final favoritesBloc = BlocProvider.of<FavoritesBloc>(context);
      expect(favoritesBloc, isNotNull);
    });

    testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
