import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/policies/presentation/pages/policy_page.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_bloc.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_event.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_state.dart';
import 'package:flutter_library/features/policies/domain/entities/policy.dart';
import 'package:flutter_library/features/policies/presentation/widgets/markdown_viewer.dart';
import 'package:flutter_library/shared/widgets/app_error_widget.dart';
import 'package:flutter_library/shared/widgets/loading_widget.dart';

class MockPolicyBloc extends Mock implements PolicyBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

void main() {
  group('PolicyPage Tests', () {
    late MockPolicyBloc mockPolicyBloc;

    setUp(() {
      mockPolicyBloc = MockPolicyBloc();
      registerFallbackValue(LoadPolicy('test'));
      registerFallbackValue(RefreshPolicy('test'));
    });

    Widget createTestWidget({
      required String policyId,
      required String title,
    }) {
      return MaterialApp(
        home: BlocProvider<PolicyBloc>(
          create: (context) => mockPolicyBloc,
          child: PolicyPage(
            policyId: policyId,
            title: title,
          ),
        ),
      );
    }

    testWidgets('displays app bar with correct title', (WidgetTester tester) async {
      const testTitle = 'Privacy Policy';
      const testPolicyId = 'privacy';
      
      when(() => mockPolicyBloc.state).thenReturn(PolicyInitial());
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyInitial()));

      await tester.pumpWidget(createTestWidget(
        policyId: testPolicyId,
        title: testTitle,
      ));

      expect(find.text(testTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays refresh button in app bar', (WidgetTester tester) async {
      when(() => mockPolicyBloc.state).thenReturn(PolicyInitial());
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyInitial()));

      await tester.pumpWidget(createTestWidget(
        policyId: 'test',
        title: 'Test Policy',
      ));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('loads policy on initial state', (WidgetTester tester) async {
      when(() => mockPolicyBloc.state).thenReturn(PolicyInitial());
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyInitial()));

      await tester.pumpWidget(createTestWidget(
        policyId: 'privacy',
        title: 'Privacy Policy',
      ));

      verify(() => mockPolicyBloc.add(LoadPolicy('privacy'))).called(1);
    });

    testWidgets('displays loading widget when policy is loading', (WidgetTester tester) async {
      when(() => mockPolicyBloc.state).thenReturn(PolicyLoading());
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyLoading()));

      await tester.pumpWidget(createTestWidget(
        policyId: 'terms',
        title: 'Terms of Service',
      ));

      expect(find.byType(LoadingWidget), findsOneWidget);
    });

    testWidgets('displays markdown viewer when policy is loaded', (WidgetTester tester) async {
      final testPolicy = Policy(
        id: 'test',
        title: 'Test Policy',
        content: '# Test Policy Content',
        lastUpdated: DateTime.now(),
        version: '1.0',
      );

      when(() => mockPolicyBloc.state).thenReturn(PolicyLoaded(testPolicy));
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyLoaded(testPolicy)));

      await tester.pumpWidget(createTestWidget(
        policyId: 'test',
        title: 'Test Policy',
      ));

      expect(find.byType(MarkdownViewer), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays error widget when policy loading fails', (WidgetTester tester) async {
      const errorMessage = 'Failed to load policy';
      when(() => mockPolicyBloc.state).thenReturn(PolicyError(errorMessage));
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyError(errorMessage)));

      await tester.pumpWidget(createTestWidget(
        policyId: 'test',
        title: 'Test Policy',
      ));

      expect(find.byType(AppErrorWidget), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('triggers refresh when refresh button is tapped', (WidgetTester tester) async {
      const policyId = 'privacy';
      when(() => mockPolicyBloc.state).thenReturn(PolicyInitial());
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyInitial()));

      await tester.pumpWidget(createTestWidget(
        policyId: policyId,
        title: 'Privacy Policy',
      ));

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      verify(() => mockPolicyBloc.add(RefreshPolicy(policyId))).called(1);
    });

    testWidgets('triggers refresh when pull to refresh is performed', (WidgetTester tester) async {
      const policyId = 'terms';
      final testPolicy = Policy(
        id: policyId,
        title: 'Terms',
        content: '# Terms Content',
        lastUpdated: DateTime.now(),
        version: '1.0',
      );

      when(() => mockPolicyBloc.state).thenReturn(PolicyLoaded(testPolicy));
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyLoaded(testPolicy)));

      await tester.pumpWidget(createTestWidget(
        policyId: policyId,
        title: 'Terms of Service',
      ));

      // Trigger refresh by calling onRefresh directly
      final refreshIndicator = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
      await refreshIndicator.onRefresh();
      await tester.pumpAndSettle();

      verify(() => mockPolicyBloc.add(RefreshPolicy(policyId))).called(1);
    });

    testWidgets('retry button triggers policy reload on error', (WidgetTester tester) async {
      const policyId = 'privacy';
      const errorMessage = 'Network error';
      when(() => mockPolicyBloc.state).thenReturn(PolicyError(errorMessage));
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyError(errorMessage)));

      await tester.pumpWidget(createTestWidget(
        policyId: policyId,
        title: 'Privacy Policy',
      ));

      // Find and tap retry button
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      verify(() => mockPolicyBloc.add(LoadPolicy(policyId))).called(1); // Only the retry call
    });

    testWidgets('error state pull to refresh triggers policy reload', (WidgetTester tester) async {
      const policyId = 'terms';
      const errorMessage = 'Failed to load';
      when(() => mockPolicyBloc.state).thenReturn(PolicyError(errorMessage));
      when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyError(errorMessage)));

      await tester.pumpWidget(createTestWidget(
        policyId: policyId,
        title: 'Terms of Service',
      ));

      // Trigger refresh by calling onRefresh directly  
      final refreshIndicator = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
      await refreshIndicator.onRefresh();
      await tester.pumpAndSettle();

      verify(() => mockPolicyBloc.add(LoadPolicy(policyId))).called(1); // Only the refresh call
    });
  });
}
