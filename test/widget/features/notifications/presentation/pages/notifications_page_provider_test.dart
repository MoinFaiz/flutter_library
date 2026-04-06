import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/notifications/presentation/pages/notifications_page_provider.dart';
import 'package:flutter_library/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_state.dart';

// Mock classes
class MockNotificationsBloc extends Mock implements NotificationsBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('NotificationsPageProvider', () {
    late MockNotificationsBloc mockNotificationsBloc;
    late MockNavigationService mockNavigationService;
    late GetIt sl;

    setUp(() {
      mockNotificationsBloc = MockNotificationsBloc();
      mockNavigationService = MockNavigationService();
      when(() => mockNotificationsBloc.state).thenReturn(NotificationsInitial());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => const Stream.empty());
      
      // Setup dependency injection
      sl = GetIt.instance;
      if (!sl.isRegistered<NotificationsBloc>()) {
        sl.registerFactory<NotificationsBloc>(() => mockNotificationsBloc);
      }
      if (!sl.isRegistered<NavigationService>()) {
        sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      }
    });

    tearDown(() {
      sl.reset();
    });

    testWidgets('creates BlocProvider with NotificationsBloc', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPageProvider(),
        ),
      );

      expect(find.byType(BlocProvider<NotificationsBloc>), findsOneWidget);
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('provides NotificationsBloc to NotificationsPage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPageProvider(),
        ),
      );

      final notificationsPageFinder = find.byType(NotificationsPage);
      expect(notificationsPageFinder, findsOneWidget);

      final context = tester.element(notificationsPageFinder);
      final notificationsBloc = BlocProvider.of<NotificationsBloc>(context);
      expect(notificationsBloc, isNotNull);
    });

    testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPageProvider(),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
