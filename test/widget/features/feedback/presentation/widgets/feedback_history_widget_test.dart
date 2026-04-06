import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/feedback/presentation/widgets/feedback_history_widget.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_state.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart' as feedback_entities;

class MockFeedbackBloc extends Mock implements FeedbackBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

class FakeFeedbackEvent extends Fake implements FeedbackEvent {}

void main() {
  group('FeedbackHistoryWidget Tests', () {
    late MockFeedbackBloc mockFeedbackBloc;

    setUpAll(() {
      registerFallbackValue(FakeFeedbackEvent());
    });

    setUp(() {
      mockFeedbackBloc = MockFeedbackBloc();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<FeedbackBloc>(
            create: (context) => mockFeedbackBloc,
            child: const FeedbackHistoryWidget(),
          ),
        ),
      );
    }

    testWidgets('displays history title correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());
      when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Your Feedback History'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays loading state correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockFeedbackBloc.state).thenReturn(const FeedbackLoading());
      when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockFeedbackBloc.state).thenReturn(const FeedbackError(message: 'Failed to load'));
      when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Failed to load'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('has proper layout structure with title and card', (WidgetTester tester) async {
      // Arrange
      when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());
      when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.text('Your Feedback History'), findsOneWidget);
    });

    testWidgets('handles BlocBuilder state changes', (WidgetTester tester) async {
      // Arrange
      when(() => mockFeedbackBloc.state).thenReturn(const FeedbackInitial());
      when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(BlocBuilder<FeedbackBloc, FeedbackState>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays widget without crashing on different states', (WidgetTester tester) async {
      // Test various states without crashing
      final testFeedback = feedback_entities.Feedback(
        id: '1',
        type: feedback_entities.FeedbackType.general,
        message: 'Test feedback',
        status: feedback_entities.FeedbackStatus.pending,
        createdAt: DateTime.now(),
      );
      
      final states = [
        const FeedbackInitial(),
        const FeedbackLoading(),
        const FeedbackError(message: 'Error'),
        FeedbackSubmitted(feedback: testFeedback),
      ];

      for (final state in states) {
        when(() => mockFeedbackBloc.state).thenReturn(state);
        when(() => mockFeedbackBloc.stream).thenAnswer((_) => Stream.empty());

        await tester.pumpWidget(createTestWidget());
        expect(find.text('Your Feedback History'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
