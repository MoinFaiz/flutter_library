import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_event.dart';

void main() {
  group('FavoritesEvent', () {
    group('LoadFavorites', () {
      test('should have empty props', () {
        // Arrange
        final event = LoadFavorites();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are LoadFavorites', () {
        // Arrange
        final event1 = LoadFavorites();
        final event2 = LoadFavorites();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are LoadFavorites', () {
        // Arrange
        final event1 = LoadFavorites();
        final event2 = LoadFavorites();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend FavoritesEvent', () {
        // Arrange
        final event = LoadFavorites();

        // Act & Assert
        expect(event, isA<FavoritesEvent>());
      });
    });

    group('LoadMoreFavorites', () {
      test('should have empty props', () {
        // Arrange
        final event = LoadMoreFavorites();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are LoadMoreFavorites', () {
        // Arrange
        final event1 = LoadMoreFavorites();
        final event2 = LoadMoreFavorites();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are LoadMoreFavorites', () {
        // Arrange
        final event1 = LoadMoreFavorites();
        final event2 = LoadMoreFavorites();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend FavoritesEvent', () {
        // Arrange
        final event = LoadMoreFavorites();

        // Act & Assert
        expect(event, isA<FavoritesEvent>());
      });

      test('should not be equal to LoadFavorites', () {
        // Arrange
        final loadEvent = LoadFavorites();
        final loadMoreEvent = LoadMoreFavorites();

        // Act & Assert
        expect(loadEvent, isNot(equals(loadMoreEvent)));
      });
    });

    group('RefreshFavorites', () {
      test('should have empty props', () {
        // Arrange
        final event = RefreshFavorites();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are RefreshFavorites', () {
        // Arrange
        final event1 = RefreshFavorites();
        final event2 = RefreshFavorites();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are RefreshFavorites', () {
        // Arrange
        final event1 = RefreshFavorites();
        final event2 = RefreshFavorites();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend FavoritesEvent', () {
        // Arrange
        final event = RefreshFavorites();

        // Act & Assert
        expect(event, isA<FavoritesEvent>());
      });

      test('should not be equal to other event types', () {
        // Arrange
        final refreshEvent = RefreshFavorites();
        final loadEvent = LoadFavorites();
        final loadMoreEvent = LoadMoreFavorites();

        // Act & Assert
        expect(refreshEvent, isNot(equals(loadEvent)));
        expect(refreshEvent, isNot(equals(loadMoreEvent)));
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

      test('should extend FavoritesEvent', () {
        // Arrange
        const event = ToggleFavorite('test-book-id');

        // Act & Assert
        expect(event, isA<FavoritesEvent>());
      });

      test('should not be equal to other event types with different props', () {
        // Arrange
        const toggleEvent = ToggleFavorite('test-book-id');
        final loadEvent = LoadFavorites();
        final loadMoreEvent = LoadMoreFavorites();
        final refreshEvent = RefreshFavorites();

        // Act & Assert
        expect(toggleEvent, isNot(equals(loadEvent)));
        expect(toggleEvent, isNot(equals(loadMoreEvent)));
        expect(toggleEvent, isNot(equals(refreshEvent)));
      });

      test('should handle empty string bookId', () {
        // Arrange & Act
        const event = ToggleFavorite('');

        // Assert
        expect(event.props, ['']);
        expect(event.bookId, equals(''));
      });

      test('should handle special characters in bookId', () {
        // Arrange
        const specialBookId = 'book-id-with-special-chars-!@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        const event = ToggleFavorite(specialBookId);

        // Act & Assert
        expect(event.props, [specialBookId]);
        expect(event.bookId, equals(specialBookId));
      });
    });

    group('FavoritesEvent base class', () {
      test('should have empty props by default', () {
        // This tests the abstract base class through a concrete implementation
        final event = LoadFavorites();
        
        // Verify that the base class props behavior is working
        expect(event.props, isA<List<Object>>());
        expect(event.props, isEmpty);
      });

      test('should support toString method', () {
        // Arrange
        final event = LoadFavorites();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should test base class props method directly', () {
        // Create a test implementation to access base class behavior
        final testEvent = _TestFavoritesEvent();
        
        // Act & Assert
        expect(testEvent.props, isEmpty);
        expect(testEvent.props, isA<List<Object>>());
      });
    });

    group('Event type differentiation', () {
      test('should be able to distinguish between different event types', () {
        // Arrange
        final loadEvent = LoadFavorites();
        final loadMoreEvent = LoadMoreFavorites();
        final refreshEvent = RefreshFavorites();
        const toggleEvent = ToggleFavorite('test-book-id');

        // Act & Assert - All events should be different types
        final eventTypes = [
          loadEvent.runtimeType,
          loadMoreEvent.runtimeType,
          refreshEvent.runtimeType,
          toggleEvent.runtimeType,
        ];

        // Check that all types are unique
        expect(eventTypes.toSet().length, equals(eventTypes.length));
        
        // But all should be FavoritesEvent
        expect(loadEvent, isA<FavoritesEvent>());
        expect(loadMoreEvent, isA<FavoritesEvent>());
        expect(refreshEvent, isA<FavoritesEvent>());
        expect(toggleEvent, isA<FavoritesEvent>());
      });

      test('should work correctly with Set operations', () {
        // Arrange
        final event1 = LoadFavorites();
        final event2 = LoadFavorites();
        final event3 = LoadMoreFavorites();

        // Act - Create set by adding elements instead of literal
        final eventSet = <FavoritesEvent>{};
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

    group('Event polymorphism', () {
      test('should work correctly with polymorphic lists', () {
        // Arrange
        final List<FavoritesEvent> events = [
          LoadFavorites(),
          LoadMoreFavorites(),
          RefreshFavorites(),
          const ToggleFavorite('test-book-id'),
        ];

        // Act & Assert
        expect(events.length, equals(4));
        expect(events[0], isA<LoadFavorites>());
        expect(events[1], isA<LoadMoreFavorites>());
        expect(events[2], isA<RefreshFavorites>());
        expect(events[3], isA<ToggleFavorite>());
        
        // Check properties
        expect((events[3] as ToggleFavorite).bookId, equals('test-book-id'));
      });

      test('should support pattern matching', () {
        // Arrange
        final List<FavoritesEvent> events = [
          LoadFavorites(),
          LoadMoreFavorites(),
          RefreshFavorites(),
          const ToggleFavorite('test-book-id'),
        ];

        // Act & Assert - Type checking via 'is'
        for (final event in events) {
          if (event is LoadFavorites) {
            expect(event, isA<LoadFavorites>());
          } else if (event is LoadMoreFavorites) {
            expect(event, isA<LoadMoreFavorites>());
          } else if (event is RefreshFavorites) {
            expect(event, isA<RefreshFavorites>());
          } else if (event is ToggleFavorite) {
            expect(event, isA<ToggleFavorite>());
            expect(event.bookId, equals('test-book-id'));
          } else {
            fail('Unexpected event type: [${event.runtimeType}');
          }
        }
      });
    });

    group('Event const constructors', () {
      test('should support const constructor for ToggleFavorite', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const toggleEvent1 = ToggleFavorite('test-id');
        const toggleEvent2 = ToggleFavorite('test-id');

        // Assert - Should be the same instance due to const optimization
        expect(identical(toggleEvent1, toggleEvent2), isTrue);
      });

      test('should create new instances for non-const events', () {
        // Arrange & Act
        final loadEvent1 = LoadFavorites();
        final loadEvent2 = LoadFavorites();
        final loadMoreEvent1 = LoadMoreFavorites();
        final loadMoreEvent2 = LoadMoreFavorites();
        final refreshEvent1 = RefreshFavorites();
        final refreshEvent2 = RefreshFavorites();

        // Assert - Should be different instances but equal
        expect(identical(loadEvent1, loadEvent2), isFalse);
        expect(loadEvent1, equals(loadEvent2));
        expect(identical(loadMoreEvent1, loadMoreEvent2), isFalse);
        expect(loadMoreEvent1, equals(loadMoreEvent2));
        expect(identical(refreshEvent1, refreshEvent2), isFalse);
        expect(refreshEvent1, equals(refreshEvent2));
      });
    });
  });
}

/// Test implementation of FavoritesEvent to access base class behavior
class _TestFavoritesEvent extends FavoritesEvent {
  const _TestFavoritesEvent();
}
