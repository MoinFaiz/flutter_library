import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/profile/presentation/pages/profile_page_provider.dart';
import 'package:flutter_library/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_state.dart';

// Mock classes
class MockProfileBloc extends Mock implements ProfileBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}
class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('ProfilePageProvider', () {
    late MockProfileBloc mockProfileBloc;
    late MockNavigationService mockNavigationService;
    late GetIt sl;

    setUp(() {
      sl = GetIt.instance;
      mockProfileBloc = MockProfileBloc();
      mockNavigationService = MockNavigationService();

      if (!sl.isRegistered<ProfileBloc>()) {
        sl.registerFactory<ProfileBloc>(() => mockProfileBloc);
      }

      if (!sl.isRegistered<NavigationService>()) {
        sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      }

      when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('creates BlocProvider with ProfileBloc', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePageProvider(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BlocProvider<ProfileBloc>), findsOneWidget);
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('provides ProfileBloc to ProfilePage', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProfilePageProvider(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        final profilePageFinder = find.byType(ProfilePage);
        expect(profilePageFinder, findsOneWidget);

        final context = tester.element(profilePageFinder);
        final profileBloc = BlocProvider.of<ProfileBloc>(context);
        expect(profileBloc, isNotNull);
      });
    });

    testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: ProfilePageProvider(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
      });
    });
  });
}
