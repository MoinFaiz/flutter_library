import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/core/network/network_info.dart';
import 'package:flutter_library/features/feedback/presentation/pages/feedback_page_provider.dart';
import 'package:flutter_library/features/feedback/presentation/pages/feedback_page.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_bloc.dart';

// Mock classes
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  group('FeedbackPageProvider', () {
    late GetIt getIt;
    late MockNetworkInfo mockNetworkInfo;

    setUp(() {
      getIt = GetIt.instance;
      mockNetworkInfo = MockNetworkInfo();
      
      // Register mock NetworkInfo
      if (!getIt.isRegistered<NetworkInfo>()) {
        getIt.registerLazySingleton<NetworkInfo>(() => mockNetworkInfo);
      }
      
      // Mock network info to return true
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('creates BlocProvider with FeedbackBloc', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackPageProvider(),
        ),
      );

      expect(find.byType(BlocProvider<FeedbackBloc>), findsOneWidget);
      expect(find.byType(FeedbackPage), findsOneWidget);
    });

    testWidgets('provides FeedbackBloc to descendants', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackPageProvider(),
        ),
      );

      final feedbackPageFinder = find.byType(FeedbackPage);
      expect(feedbackPageFinder, findsOneWidget);

      final context = tester.element(feedbackPageFinder);
      final feedbackBloc = context.read<FeedbackBloc>();
      expect(feedbackBloc, isNotNull);
    });

    testWidgets('renders FeedbackPage without exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackPageProvider(),
        ),
      );

      expect(find.byType(FeedbackPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
