import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_event.dart';

void main() {
  group('LibraryEvent', () {
    group('LoadBorrowedBooks', () {
      test('should have empty props', () {
        // Arrange
        const event = LoadBorrowedBooks();

        // Act & Assert
        expect(event.props, isEmpty);
        expect(event, isA<LibraryEvent>());
      });

      test('should be equal when instances are the same', () {
        // Arrange
        const event1 = LoadBorrowedBooks();
        const event2 = LoadBorrowedBooks();

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should support const constructor', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const event1 = LoadBorrowedBooks();
        const event2 = LoadBorrowedBooks();

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });

      test('should have consistent toString representation', () {
        // Arrange
        const event = LoadBorrowedBooks();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result, contains('LoadBorrowedBooks'));
      });
    });

    group('LoadUploadedBooks', () {
      test('should have empty props', () {
        // Arrange
        const event = LoadUploadedBooks();

        // Act & Assert
        expect(event.props, isEmpty);
        expect(event, isA<LibraryEvent>());
      });

      test('should be equal when instances are the same', () {
        // Arrange
        const event1 = LoadUploadedBooks();
        const event2 = LoadUploadedBooks();

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should support const constructor', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const event1 = LoadUploadedBooks();
        const event2 = LoadUploadedBooks();

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });

      test('should have consistent toString representation', () {
        // Arrange
        const event = LoadUploadedBooks();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result, contains('LoadUploadedBooks'));
      });

      test('should not be equal to LoadBorrowedBooks', () {
        // Arrange
        const loadBorrowedEvent = LoadBorrowedBooks();
        const loadUploadedEvent = LoadUploadedBooks();

        // Act & Assert
        expect(loadBorrowedEvent, isNot(equals(loadUploadedEvent)));
        expect(loadBorrowedEvent.hashCode, isNot(equals(loadUploadedEvent.hashCode)));
      });
    });

    group('RefreshLibrary', () {
      test('should have empty props', () {
        // Arrange
        const event = RefreshLibrary();

        // Act & Assert
        expect(event.props, isEmpty);
        expect(event, isA<LibraryEvent>());
      });

      test('should be equal when instances are the same', () {
        // Arrange
        const event1 = RefreshLibrary();
        const event2 = RefreshLibrary();

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should support const constructor', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const event1 = RefreshLibrary();
        const event2 = RefreshLibrary();

        // Assert - Should be the same instance due to const optimization
        expect(identical(event1, event2), isTrue);
      });

      test('should have consistent toString representation', () {
        // Arrange
        const event = RefreshLibrary();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
        expect(result, contains('RefreshLibrary'));
      });

      test('should not be equal to other event types', () {
        // Arrange
        const refreshEvent = RefreshLibrary();
        const loadBorrowedEvent = LoadBorrowedBooks();
        const loadUploadedEvent = LoadUploadedBooks();

        // Act & Assert
        expect(refreshEvent, isNot(equals(loadBorrowedEvent)));
        expect(refreshEvent, isNot(equals(loadUploadedEvent)));
        expect(refreshEvent.hashCode, isNot(equals(loadBorrowedEvent.hashCode)));
        expect(refreshEvent.hashCode, isNot(equals(loadUploadedEvent.hashCode)));
      });
    });

    group('LibraryEvent base class', () {
      test('should have empty props by default', () {
        // Create a test implementation to access base class behavior
        final testEvent = _TestLibraryEvent();
        
        // Act & Assert
        expect(testEvent.props, isEmpty);
        expect(testEvent.props, isA<List<Object?>>());
      });

      test('should support toString method', () {
        // Arrange
        const event = LoadBorrowedBooks();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });
    });

    group('Event type differentiation', () {
      test('should be able to distinguish between different event types', () {
        // Arrange
        const loadBorrowedEvent = LoadBorrowedBooks();
        const loadUploadedEvent = LoadUploadedBooks();
        const refreshEvent = RefreshLibrary();

        // Act & Assert - All events should be different types
        expect(loadBorrowedEvent.runtimeType, isNot(equals(loadUploadedEvent.runtimeType)));
        expect(loadBorrowedEvent.runtimeType, isNot(equals(refreshEvent.runtimeType)));
        expect(loadUploadedEvent.runtimeType, isNot(equals(refreshEvent.runtimeType)));
        
        // But all should be LibraryEvent
        expect(loadBorrowedEvent, isA<LibraryEvent>());
        expect(loadUploadedEvent, isA<LibraryEvent>());
        expect(refreshEvent, isA<LibraryEvent>());
      });

      test('should work correctly with Set operations', () {
        // Arrange
        const event1 = LoadBorrowedBooks();
        const event2 = LoadBorrowedBooks();
        const event3 = LoadUploadedBooks();
        const event4 = RefreshLibrary();

        // Act - Create set by adding elements
        final eventSet = <LibraryEvent>{};
        eventSet.add(event1);
        eventSet.add(event2); // This should not be added as it's equal to event1
        eventSet.add(event3);
        eventSet.add(event4);

        // Assert - Set should contain only 3 unique events
        expect(eventSet.length, equals(3));
        expect(eventSet.contains(event1), isTrue);
        expect(eventSet.contains(event2), isTrue); // Same as event1
        expect(eventSet.contains(event3), isTrue);
        expect(eventSet.contains(event4), isTrue);
      });
    });

    group('Event immutability and const constructors', () {
      test('should maintain event data integrity', () {
        // Arrange
        const loadBorrowedEvent = LoadBorrowedBooks();
        const loadUploadedEvent = LoadUploadedBooks();
        const refreshEvent = RefreshLibrary();

        // Act - Try to access props multiple times
        final props1 = loadBorrowedEvent.props;
        final props2 = loadBorrowedEvent.props;
        final props3 = loadUploadedEvent.props;
        final props4 = refreshEvent.props;

        // Assert - Should be consistent
        expect(props1, equals(props2));
        expect(props1, isEmpty);
        expect(props3, isEmpty);
        expect(props4, isEmpty);
      });
    });

    group('Event polymorphism', () {
      test('should work correctly with polymorphic lists', () {
        // Arrange
        final List<LibraryEvent> events = [
          const LoadBorrowedBooks(),
          const LoadUploadedBooks(),
          const RefreshLibrary(),
        ];

        // Act & Assert
        expect(events.length, equals(3));
        expect(events[0], isA<LoadBorrowedBooks>());
        expect(events[1], isA<LoadUploadedBooks>());
        expect(events[2], isA<RefreshLibrary>());
        
        // All should have empty props
        for (final event in events) {
          expect(event.props, isEmpty);
        }
      });

      test('should support pattern matching', () {
        // Arrange
        final List<LibraryEvent> events = [
          const LoadBorrowedBooks(),
          const LoadUploadedBooks(),
          const RefreshLibrary(),
        ];

        // Act & Assert - Type checking via 'is'
        for (final event in events) {
          if (event is LoadBorrowedBooks) {
            expect(event, isA<LoadBorrowedBooks>());
            expect(event.props, isEmpty);
          } else if (event is LoadUploadedBooks) {
            expect(event, isA<LoadUploadedBooks>());
            expect(event.props, isEmpty);
          } else if (event is RefreshLibrary) {
            expect(event, isA<RefreshLibrary>());
            expect(event.props, isEmpty);
          } else {
            fail('Unexpected event type: ${event.runtimeType}');
          }
        }
      });
    });

    group('Edge cases', () {
      test('should handle rapid event creation', () {
        // Arrange & Act - Create many events rapidly
        final events = List.generate(1000, (index) {
          switch (index % 3) {
            case 0:
              return const LoadBorrowedBooks();
            case 1:
              return const LoadUploadedBooks();
            default:
              return const RefreshLibrary();
          }
        });

        // Assert
        expect(events.length, equals(1000));
        expect(events.whereType<LoadBorrowedBooks>().length, greaterThan(300));
        expect(events.whereType<LoadUploadedBooks>().length, greaterThan(300));
        expect(events.whereType<RefreshLibrary>().length, greaterThan(300));
      });

      test('should handle event comparison in maps', () {
        // Arrange
        const loadBorrowedEvent = LoadBorrowedBooks();
        const loadUploadedEvent = LoadUploadedBooks();
        const refreshEvent = RefreshLibrary();

        final eventMap = <LibraryEvent, String>{
          loadBorrowedEvent: 'borrowed',
          loadUploadedEvent: 'uploaded',
          refreshEvent: 'refresh',
        };

        // Act & Assert
        expect(eventMap[const LoadBorrowedBooks()], equals('borrowed'));
        expect(eventMap[const LoadUploadedBooks()], equals('uploaded'));
        expect(eventMap[const RefreshLibrary()], equals('refresh'));
        expect(eventMap.length, equals(3));
      });
    });
  });
}

/// Test implementation of LibraryEvent to access base class behavior
class _TestLibraryEvent extends LibraryEvent {
  const _TestLibraryEvent();
}
