import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_event.dart';

void main() {
  group('BookDetailsEvent', () {
    group('LoadBookDetails', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = LoadBookDetails(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = LoadBookDetails(bookId);
        const event2 = LoadBookDetails(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = LoadBookDetails('book-id-1');
        const event2 = LoadBookDetails('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = LoadBookDetails(bookId);
        const event2 = LoadBookDetails(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend BookDetailsEvent', () {
        // Arrange
        const event = LoadBookDetails('test-book-id');

        // Act & Assert
        expect(event, isA<BookDetailsEvent>());
      });
    });

    group('RefreshBookDetails', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = RefreshBookDetails(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RefreshBookDetails(bookId);
        const event2 = RefreshBookDetails(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = RefreshBookDetails('book-id-1');
        const event2 = RefreshBookDetails('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RefreshBookDetails(bookId);
        const event2 = RefreshBookDetails(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend BookDetailsEvent', () {
        // Arrange
        const event = RefreshBookDetails('test-book-id');

        // Act & Assert
        expect(event, isA<BookDetailsEvent>());
      });

      test('should not be equal to LoadBookDetails with same bookId', () {
        // Arrange
        const bookId = 'test-book-id';
        const loadEvent = LoadBookDetails(bookId);
        const refreshEvent = RefreshBookDetails(bookId);

        // Act & Assert
        expect(loadEvent, isNot(equals(refreshEvent)));
      });
    });

    group('ToggleFavorite', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = ToggleFavorite(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = ToggleFavorite(bookId);
        const event2 = ToggleFavorite(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = ToggleFavorite('book-id-1');
        const event2 = ToggleFavorite('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = ToggleFavorite(bookId);
        const event2 = ToggleFavorite(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend BookDetailsEvent', () {
        // Arrange
        const event = ToggleFavorite('test-book-id');

        // Act & Assert
        expect(event, isA<BookDetailsEvent>());
      });

      test('should not be equal to other event types with same bookId', () {
        // Arrange
        const bookId = 'test-book-id';
        const toggleEvent = ToggleFavorite(bookId);
        const loadEvent = LoadBookDetails(bookId);
        const refreshEvent = RefreshBookDetails(bookId);

        // Act & Assert
        expect(toggleEvent, isNot(equals(loadEvent)));
        expect(toggleEvent, isNot(equals(refreshEvent)));
      });
    });

    group('BookDetailsEvent base class', () {
      test('should have empty props by default', () {
        // This tests the abstract base class through a concrete implementation
        const event = LoadBookDetails('test-id');
        
        // Verify that the base class props behavior is working
        expect(event.props, isA<List<Object?>>());
        expect(event.props, isNotEmpty); // LoadBookDetails overrides this
      });

      test('should support toString method', () {
        // Arrange
        const event = LoadBookDetails('test-book-id');

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should test base class props method directly', () {
        // Create a test implementation to access base class behavior
        final testEvent = _TestBookDetailsEvent();
        
        // Act & Assert
        expect(testEvent.props, isEmpty);
        expect(testEvent.props, isA<List<Object?>>());
      });
    });

    group('Event type differentiation', () {
      test('should be able to distinguish between different event types', () {
        // Arrange
        const bookId = 'test-book-id';
        const loadEvent = LoadBookDetails(bookId);
        const refreshEvent = RefreshBookDetails(bookId);
        const toggleEvent = ToggleFavorite(bookId);

        // Act & Assert - All events should be different types
        expect(loadEvent.runtimeType, isNot(equals(refreshEvent.runtimeType)));
        expect(loadEvent.runtimeType, isNot(equals(toggleEvent.runtimeType)));
        expect(refreshEvent.runtimeType, isNot(equals(toggleEvent.runtimeType)));
        
        // But all should be BookDetailsEvent
        expect(loadEvent, isA<BookDetailsEvent>());
        expect(refreshEvent, isA<BookDetailsEvent>());
        expect(toggleEvent, isA<BookDetailsEvent>());
      });

      test('should work correctly with Set operations', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = LoadBookDetails(bookId);
        const event2 = LoadBookDetails(bookId);
        const event3 = RefreshBookDetails(bookId);

        // Act - Create set by adding elements instead of literal
        final eventSet = <BookDetailsEvent>{};
        eventSet.add(event1);
        eventSet.add(event2); // This should not be added as it's equal to event1
        eventSet.add(event3);

        // Assert - Set should contain only 2 unique events
        expect(eventSet.length, equals(2));
        expect(eventSet.contains(event1), isTrue);
        expect(eventSet.contains(event2), isTrue); // Same as event1
        expect(eventSet.contains(event3), isTrue);
      });
    });

    group('Event edge cases and validation', () {
      test('should handle empty string bookId', () {
        // Arrange & Act
        const loadEvent = LoadBookDetails('');
        const refreshEvent = RefreshBookDetails('');
        const toggleEvent = ToggleFavorite('');

        // Assert - Should not throw and should have empty string in props
        expect(loadEvent.props, ['']);
        expect(refreshEvent.props, ['']);
        expect(toggleEvent.props, ['']);
      });

      test('should handle very long bookId strings', () {
        // Arrange
        final longBookId = 'a' * 1000; // 1000 character string
        final loadEvent = LoadBookDetails(longBookId);
        final refreshEvent = RefreshBookDetails(longBookId);
        final toggleEvent = ToggleFavorite(longBookId);

        // Act & Assert - Should handle long strings without issues
        expect(loadEvent.props, [longBookId]);
        expect(refreshEvent.props, [longBookId]);
        expect(toggleEvent.props, [longBookId]);
        expect(loadEvent.bookId.length, equals(1000));
      });

      test('should handle special characters in bookId', () {
        // Arrange
        const specialBookId = 'book-id-with-special-chars-!@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        const loadEvent = LoadBookDetails(specialBookId);
        const refreshEvent = RefreshBookDetails(specialBookId);
        const toggleEvent = ToggleFavorite(specialBookId);

        // Act & Assert
        expect(loadEvent.props, [specialBookId]);
        expect(refreshEvent.props, [specialBookId]);
        expect(toggleEvent.props, [specialBookId]);
      });

      test('should handle Unicode characters in bookId', () {
        // Arrange
        const unicodeBookId = '测试-書籍-📚-🔖-ID';
        const loadEvent = LoadBookDetails(unicodeBookId);
        const refreshEvent = RefreshBookDetails(unicodeBookId);
        const toggleEvent = ToggleFavorite(unicodeBookId);

        // Act & Assert
        expect(loadEvent.props, [unicodeBookId]);
        expect(refreshEvent.props, [unicodeBookId]);
        expect(toggleEvent.props, [unicodeBookId]);
      });
    });

    group('Event immutability and const constructors', () {
      test('should support const constructor for all event types', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const loadEvent1 = LoadBookDetails('test-id');
        const loadEvent2 = LoadBookDetails('test-id');
        const refreshEvent1 = RefreshBookDetails('test-id');
        const refreshEvent2 = RefreshBookDetails('test-id');
        const toggleEvent1 = ToggleFavorite('test-id');
        const toggleEvent2 = ToggleFavorite('test-id');

        // Assert - Should be the same instance due to const optimization
        expect(identical(loadEvent1, loadEvent2), isTrue);
        expect(identical(refreshEvent1, refreshEvent2), isTrue);
        expect(identical(toggleEvent1, toggleEvent2), isTrue);
      });

      test('should maintain event data integrity', () {
        // Arrange
        const originalBookId = 'original-book-id';
        const event = LoadBookDetails(originalBookId);

        // Act - Try to access bookId multiple times
        final bookId1 = event.bookId;
        final bookId2 = event.bookId;
        final props1 = event.props;
        final props2 = event.props;

        // Assert - Should be consistent
        expect(bookId1, equals(originalBookId));
        expect(bookId2, equals(originalBookId));
        expect(bookId1, equals(bookId2));
        expect(props1, equals(props2));
        expect(props1, equals([originalBookId]));
      });
    });

    group('Event polymorphism', () {
      test('should work correctly with polymorphic lists', () {
        // Arrange
        const bookId = 'test-book-id';
        final List<BookDetailsEvent> events = [
          const LoadBookDetails(bookId),
          const RefreshBookDetails(bookId),
          const ToggleFavorite(bookId),
        ];

        // Act & Assert
        expect(events.length, equals(3));
        expect(events[0], isA<LoadBookDetails>());
        expect(events[1], isA<RefreshBookDetails>());
        expect(events[2], isA<ToggleFavorite>());
        
        // All should have the same bookId but be different event types
        expect((events[0] as LoadBookDetails).bookId, equals(bookId));
        expect((events[1] as RefreshBookDetails).bookId, equals(bookId));
        expect((events[2] as ToggleFavorite).bookId, equals(bookId));
      });

      test('should support pattern matching', () {
        // Arrange
        const bookId = 'test-book-id';
        final List<BookDetailsEvent> events = [
          const LoadBookDetails(bookId),
          const RefreshBookDetails(bookId),
          const ToggleFavorite(bookId),
        ];

        // Act & Assert - Type checking via 'is'
        for (final event in events) {
          if (event is LoadBookDetails) {
            expect(event, isA<LoadBookDetails>());
            expect(event.bookId, equals(bookId));
          } else if (event is RefreshBookDetails) {
            expect(event, isA<RefreshBookDetails>());
            expect(event.bookId, equals(bookId));
          } else if (event is ToggleFavorite) {
            expect(event, isA<ToggleFavorite>());
            expect(event.bookId, equals(bookId));
          } else {
            fail('Unexpected event type: [${event.runtimeType}');
          }
        }
      });
    });
  });
}

/// Test implementation of BookDetailsEvent to access base class behavior
class _TestBookDetailsEvent extends BookDetailsEvent {
  const _TestBookDetailsEvent();
}
