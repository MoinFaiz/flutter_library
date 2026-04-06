import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

void main() {
  group('FeedbackEvent', () {
    group('SubmitFeedback', () {
      test('should have correct props', () {
        // Arrange
        const type = FeedbackType.general;
        const message = 'Test feedback message';
        const event = SubmitFeedback(type: type, message: message);

        // Act & Assert
        expect(event.props, [type, message]);
      });

      test('should be equal when properties are the same', () {
        // Arrange
        const type = FeedbackType.bugReport;
        const message = 'Bug report message';
        const event1 = SubmitFeedback(type: type, message: message);
        const event2 = SubmitFeedback(type: type, message: message);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when type is different', () {
        // Arrange
        const message = 'Same message';
        const event1 = SubmitFeedback(type: FeedbackType.general, message: message);
        const event2 = SubmitFeedback(type: FeedbackType.bugReport, message: message);

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should not be equal when message is different', () {
        // Arrange
        const type = FeedbackType.featureRequest;
        const event1 = SubmitFeedback(type: type, message: 'Message 1');
        const event2 = SubmitFeedback(type: type, message: 'Message 2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when properties are the same', () {
        // Arrange
        const type = FeedbackType.complaint;
        const message = 'Complaint message';
        const event1 = SubmitFeedback(type: type, message: message);
        const event2 = SubmitFeedback(type: type, message: message);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend FeedbackEvent', () {
        // Arrange
        const event = SubmitFeedback(type: FeedbackType.general, message: 'Test');

        // Act & Assert
        expect(event, isA<FeedbackEvent>());
      });

      test('should handle all feedback types', () {
        // Arrange & Act
        const generalEvent = SubmitFeedback(type: FeedbackType.general, message: 'General feedback');
        const bugReportEvent = SubmitFeedback(type: FeedbackType.bugReport, message: 'Bug report');
        const featureRequestEvent = SubmitFeedback(type: FeedbackType.featureRequest, message: 'Feature request');
        const complaintEvent = SubmitFeedback(type: FeedbackType.complaint, message: 'Complaint');

        // Assert
        expect(generalEvent.type, equals(FeedbackType.general));
        expect(bugReportEvent.type, equals(FeedbackType.bugReport));
        expect(featureRequestEvent.type, equals(FeedbackType.featureRequest));
        expect(complaintEvent.type, equals(FeedbackType.complaint));
      });

      test('should handle empty message', () {
        // Arrange & Act
        const event = SubmitFeedback(type: FeedbackType.general, message: '');

        // Assert
        expect(event.message, equals(''));
        expect(event.props, [FeedbackType.general, '']);
      });

      test('should handle long message', () {
        // Arrange
        final longMessage = 'a' * 1000;
        final event = SubmitFeedback(type: FeedbackType.general, message: longMessage);

        // Act & Assert
        expect(event.message, equals(longMessage));
        expect(event.message.length, equals(1000));
      });

      test('should handle special characters in message', () {
        // Arrange
        const specialMessage = 'Message with special chars: !@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        const event = SubmitFeedback(type: FeedbackType.general, message: specialMessage);

        // Act & Assert
        expect(event.message, equals(specialMessage));
        expect(event.props, [FeedbackType.general, specialMessage]);
      });

      test('should handle Unicode characters in message', () {
        // Arrange
        const unicodeMessage = '反馈消息 - Feedback Message - 📝✅';
        const event = SubmitFeedback(type: FeedbackType.general, message: unicodeMessage);

        // Act & Assert
        expect(event.message, equals(unicodeMessage));
        expect(event.props, [FeedbackType.general, unicodeMessage]);
      });
    });

    group('GetFeedbackHistory', () {
      test('should have empty props', () {
        // Arrange
        const event = GetFeedbackHistory();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are GetFeedbackHistory', () {
        // Arrange
        const event1 = GetFeedbackHistory();
        const event2 = GetFeedbackHistory();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are GetFeedbackHistory', () {
        // Arrange
        const event1 = GetFeedbackHistory();
        const event2 = GetFeedbackHistory();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend FeedbackEvent', () {
        // Arrange
        const event = GetFeedbackHistory();

        // Act & Assert
        expect(event, isA<FeedbackEvent>());
      });
    });

    group('ResetFeedbackState', () {
      test('should have empty props', () {
        // Arrange
        const event = ResetFeedbackState();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are ResetFeedbackState', () {
        // Arrange
        const event1 = ResetFeedbackState();
        const event2 = ResetFeedbackState();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are ResetFeedbackState', () {
        // Arrange
        const event1 = ResetFeedbackState();
        const event2 = ResetFeedbackState();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend FeedbackEvent', () {
        // Arrange
        const event = ResetFeedbackState();

        // Act & Assert
        expect(event, isA<FeedbackEvent>());
      });

      test('should not be equal to GetFeedbackHistory', () {
        // Arrange
        const resetEvent = ResetFeedbackState();
        const historyEvent = GetFeedbackHistory();

        // Act & Assert
        expect(resetEvent, isNot(equals(historyEvent)));
      });
    });

    group('FeedbackEvent base class', () {
      test('should have empty props by default', () {
        // This tests the abstract base class through a concrete implementation
        const event = GetFeedbackHistory();
        
        // Verify that the base class props behavior is working
        expect(event.props, isA<List<Object?>>());
        expect(event.props, isEmpty);
      });

      test('should support toString method', () {
        // Arrange
        const event = GetFeedbackHistory();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should test base class props method directly', () {
        // Create a test implementation to access base class behavior
        final testEvent = _TestFeedbackEvent();
        
        // Act & Assert
        expect(testEvent.props, isEmpty);
        expect(testEvent.props, isA<List<Object?>>());
      });
    });

    group('Event type differentiation', () {
      test('should be able to distinguish between different event types', () {
        // Arrange
        const submitEvent = SubmitFeedback(type: FeedbackType.general, message: 'Test');
        const historyEvent = GetFeedbackHistory();
        const resetEvent = ResetFeedbackState();

        // Act & Assert - All events should be different types
        final eventTypes = [
          submitEvent.runtimeType,
          historyEvent.runtimeType,
          resetEvent.runtimeType,
        ];

        // Check that all types are unique
        expect(eventTypes.toSet().length, equals(eventTypes.length));
        
        // But all should be FeedbackEvent
        expect(submitEvent, isA<FeedbackEvent>());
        expect(historyEvent, isA<FeedbackEvent>());
        expect(resetEvent, isA<FeedbackEvent>());
      });

      test('should work correctly with Set operations', () {
        // Arrange
        const event1 = GetFeedbackHistory();
        const event2 = GetFeedbackHistory();
        const event3 = ResetFeedbackState();

        // Act - Create set by adding elements instead of literal
        final eventSet = <FeedbackEvent>{};
        eventSet.add(event1);
        eventSet.add(event2); // This should not be added as it's equal to event1
        eventSet.add(event3);

        // Assert - Set should contain only 2 unique events
        expect(eventSet.length, equals(2));
        expect(eventSet.contains(event1), isTrue);
        expect(eventSet.contains(event2), isTrue); // Same as event1
        expect(eventSet.contains(event3), isTrue);
      });

      test('should not be equal between different event types', () {
        // Arrange
        const submitEvent = SubmitFeedback(type: FeedbackType.general, message: 'Test');
        const historyEvent = GetFeedbackHistory();
        const resetEvent = ResetFeedbackState();

        // Act & Assert - All events should be different
        expect(submitEvent, isNot(equals(historyEvent)));
        expect(submitEvent, isNot(equals(resetEvent)));
        expect(historyEvent, isNot(equals(resetEvent)));
      });
    });

    group('Event polymorphism', () {
      test('should work correctly with polymorphic lists', () {
        // Arrange
        final List<FeedbackEvent> events = [
          const SubmitFeedback(type: FeedbackType.general, message: 'Test'),
          const GetFeedbackHistory(),
          const ResetFeedbackState(),
        ];

        // Act & Assert
        expect(events.length, equals(3));
        expect(events[0], isA<SubmitFeedback>());
        expect(events[1], isA<GetFeedbackHistory>());
        expect(events[2], isA<ResetFeedbackState>());
        
        // Check properties
        expect((events[0] as SubmitFeedback).type, equals(FeedbackType.general));
        expect((events[0] as SubmitFeedback).message, equals('Test'));
      });

      test('should support pattern matching', () {
        // Arrange
        final List<FeedbackEvent> events = [
          const SubmitFeedback(type: FeedbackType.bugReport, message: 'Bug'),
          const GetFeedbackHistory(),
          const ResetFeedbackState(),
        ];

        // Act & Assert - Type checking via 'is'
        for (final event in events) {
          if (event is SubmitFeedback) {
            expect(event, isA<SubmitFeedback>());
            expect(event.type, equals(FeedbackType.bugReport));
            expect(event.message, equals('Bug'));
          } else if (event is GetFeedbackHistory) {
            expect(event, isA<GetFeedbackHistory>());
          } else if (event is ResetFeedbackState) {
            expect(event, isA<ResetFeedbackState>());
          } else {
            fail('Unexpected event type: ${event.runtimeType}');
          }
        }
      });
    });

    group('Event const constructors', () {
      test('should support const constructor for all event types', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const submitEvent1 = SubmitFeedback(type: FeedbackType.general, message: 'test');
        const submitEvent2 = SubmitFeedback(type: FeedbackType.general, message: 'test');
        const historyEvent1 = GetFeedbackHistory();
        const historyEvent2 = GetFeedbackHistory();
        const resetEvent1 = ResetFeedbackState();
        const resetEvent2 = ResetFeedbackState();

        // Assert - Should be the same instance due to const optimization
        expect(identical(submitEvent1, submitEvent2), isTrue);
        expect(identical(historyEvent1, historyEvent2), isTrue);
        expect(identical(resetEvent1, resetEvent2), isTrue);
      });

      test('should maintain event data integrity', () {
        // Arrange
        const originalType = FeedbackType.featureRequest;
        const originalMessage = 'Feature request message';
        const event = SubmitFeedback(type: originalType, message: originalMessage);

        // Act - Try to access properties multiple times
        final type1 = event.type;
        final type2 = event.type;
        final message1 = event.message;
        final message2 = event.message;
        final props1 = event.props;
        final props2 = event.props;

        // Assert - Should be consistent
        expect(type1, equals(originalType));
        expect(type2, equals(originalType));
        expect(type1, equals(type2));
        expect(message1, equals(originalMessage));
        expect(message2, equals(originalMessage));
        expect(message1, equals(message2));
        expect(props1, equals(props2));
        expect(props1, equals([originalType, originalMessage]));
      });
    });
  });
}

/// Test implementation of FeedbackEvent to access base class behavior
class _TestFeedbackEvent extends FeedbackEvent {
  const _TestFeedbackEvent();
}
