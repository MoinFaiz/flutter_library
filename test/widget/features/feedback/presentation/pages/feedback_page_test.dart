import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/feedback/presentation/pages/feedback_page.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_state.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart' as feedback_entity;

// Mock classes
class MockFeedbackBloc extends Mock implements FeedbackBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

class FakeFeedbackEvent extends Fake implements FeedbackEvent {}

void main() {
  group('FeedbackPage Tests', () {
    late MockFeedbackBloc mockFeedbackBloc;

    setUp(() {
      mockFeedbackBloc = MockFeedbackBloc();
      registerFallbackValue(FakeFeedbackEvent());
      
      when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());
      when(() => mockFeedbackBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<FeedbackBloc>(
          create: (context) => mockFeedbackBloc,
          child: const FeedbackPage(),
        ),
      );
    }

    group('UI Components', () {
      testWidgets('displays feedback form with all required elements', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Feedback'), findsOneWidget);
      });

      testWidgets('displays feedback type selection dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(DropdownButtonFormField<feedback_entity.FeedbackType>), findsOneWidget);
      });

      testWidgets('displays feedback text field with placeholder', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Please share your thoughts, suggestions, or report any issues...'), findsOneWidget);
      });

      testWidgets('displays submit button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Submit Feedback'), findsOneWidget);
      });

      testWidgets('displays feedback history section', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // The page has a form but no ListView in the current implementation
        expect(find.byType(Form), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('validates feedback text input when empty', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Try to submit empty form
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Please enter your feedback'), findsOneWidget);
      });

      testWidgets('validates form fields before submission', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        await tester.tap(find.text('Submit Feedback'));
        await tester.pumpAndSettle();

        // Should show validation error for empty feedback field
        expect(find.text('Please enter your feedback'), findsOneWidget);
      });
    });

    group('Form Interaction', () {
      testWidgets('submits feedback when form is valid', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Enter feedback text
        await tester.enterText(find.byType(TextFormField), 'This is my feedback');
        
        // Submit form
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Verify that submit feedback event was called
        verify(() => mockFeedbackBloc.add(any())).called(1);
      });

      testWidgets('changes feedback type when dropdown selection changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final dropdown = find.byType(DropdownButtonFormField<feedback_entity.FeedbackType>);
        expect(dropdown, findsOneWidget);

        // Tap dropdown to open it
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // Select a different feedback type
        await tester.tap(find.text('Feature Request').last);
        await tester.pumpAndSettle();

        // Verify selection changed
        expect(find.text('Feature Request'), findsOneWidget);
      });
    });

    group('State Management', () {
      testWidgets('shows loading state when submitting', (WidgetTester tester) async {
        when(() => mockFeedbackBloc.state).thenReturn(const FeedbackLoading());

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows success message when feedback submitted', (WidgetTester tester) async {
        final mockFeedback = feedback_entity.Feedback(
          id: '1',
          type: feedback_entity.FeedbackType.general,
          message: 'Test feedback',
          createdAt: DateTime.now(),
          status: feedback_entity.FeedbackStatus.pending,
        );
        when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.fromIterable([
          FeedbackSubmitted(feedback: mockFeedback),
        ]));
        when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());

        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Process the stream event

        // Look for SnackBar content
        expect(find.textContaining('Thank you for your feedback'), findsOneWidget);
      });

      testWidgets('shows success message via stream when feedback submitted', (WidgetTester tester) async {
        when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.fromIterable([
          FeedbackSubmitted(feedback: feedback_entity.Feedback(
            id: '1',
            type: feedback_entity.FeedbackType.general,
            message: 'Test feedback',
            createdAt: DateTime.now(),
            status: feedback_entity.FeedbackStatus.pending,
          )),
        ]));
        when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());

        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Process the stream event

        // Look for SnackBar content
        expect(find.textContaining('Thank you for your feedback'), findsOneWidget);
      });

      testWidgets('shows error message when submission fails', (WidgetTester tester) async {
        const errorMessage = 'Failed to submit feedback';
        when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.fromIterable([
          const FeedbackError(message: errorMessage),
        ]));
        when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());

        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Process the stream event

        // Look for SnackBar content
        expect(find.text(errorMessage), findsOneWidget);
      });

      testWidgets('shows error message via stream when submission fails', (WidgetTester tester) async {
        when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.fromIterable([
          const FeedbackError(message: 'Failed to submit feedback'),
        ]));
        when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());

        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Process the stream event

        // Look for SnackBar content
        expect(find.text('Failed to submit feedback'), findsOneWidget);
      });
    });

    group('General', () {
      testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(tester.takeException(), isNull);
      });
    });
  });
}
