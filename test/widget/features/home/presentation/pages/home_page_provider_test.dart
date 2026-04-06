import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/features/home/presentation/pages/home_page_provider.dart';
import 'package:flutter_library/features/home/presentation/pages/home_page.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';

// Mock classes
class MockHomeBloc extends Mock implements HomeBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}
class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('HomePageProvider', () {
    late MockHomeBloc mockHomeBloc;
    late MockNavigationService mockNavigationService;
    late GetIt sl;

    setUp(() {
      mockHomeBloc = MockHomeBloc();
      mockNavigationService = MockNavigationService();
      
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => const Stream.empty());
      
      // Setup dependency injection
      sl = GetIt.instance;
      if (!sl.isRegistered<HomeBloc>()) {
        sl.registerFactory<HomeBloc>(() => mockHomeBloc);
      }
      if (!sl.isRegistered<NavigationService>()) {
        sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      }
    });
    
    tearDown(() {
      sl.reset();
    });

    testWidgets('creates BlocProvider with HomeBloc', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageProvider(),
        ),
      );

      expect(find.byType(BlocProvider<HomeBloc>), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('provides HomeBloc to HomePage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageProvider(),
        ),
      );

      final homePageFinder = find.byType(HomePage);
      expect(homePageFinder, findsOneWidget);

      final context = tester.element(homePageFinder);
      final homeBloc = BlocProvider.of<HomeBloc>(context);
      expect(homeBloc, isNotNull);
    });

    testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePageProvider(),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
