import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/features/library/presentation/pages/library_page_provider.dart';
import 'package:flutter_library/features/library/presentation/pages/library_page.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_state.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';

// Mock classes
class MockLibraryBloc extends Mock implements LibraryBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}
class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('LibraryPageProvider', () {
    late MockLibraryBloc mockLibraryBloc;
    late MockNavigationService mockNavigationService;
    late GetIt sl;

    setUp(() {
      mockLibraryBloc = MockLibraryBloc();
      mockNavigationService = MockNavigationService();
      
      when(() => mockLibraryBloc.state).thenReturn(LibraryInitial());
      when(() => mockLibraryBloc.stream).thenAnswer((_) => const Stream.empty());
      
      // Setup dependency injection
      sl = GetIt.instance;
      if (!sl.isRegistered<LibraryBloc>()) {
        sl.registerFactory<LibraryBloc>(() => mockLibraryBloc);
      }
      if (!sl.isRegistered<NavigationService>()) {
        sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      }
    });
    
    tearDown(() {
      sl.reset();
    });

    testWidgets('creates BlocProvider with LibraryBloc', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LibraryPageProvider(),
        ),
      );

      expect(find.byType(BlocProvider<LibraryBloc>), findsOneWidget);
      expect(find.byType(LibraryPage), findsOneWidget);
    });

    testWidgets('provides LibraryBloc to LibraryPage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LibraryPageProvider(),
        ),
      );

      final libraryPageFinder = find.byType(LibraryPage);
      expect(libraryPageFinder, findsOneWidget);

      final context = tester.element(libraryPageFinder);
      final libraryBloc = BlocProvider.of<LibraryBloc>(context);
      expect(libraryBloc, isNotNull);
    });

    testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LibraryPageProvider(),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
