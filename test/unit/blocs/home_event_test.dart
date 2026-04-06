import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_event.dart';

void main() {
  group('HomeEvent', () {
    group('LoadBooks', () {
      test('should have empty props', () {
        // Arrange
        final event = LoadBooks();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are LoadBooks', () {
        // Arrange
        final event1 = LoadBooks();
        final event2 = LoadBooks();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are LoadBooks', () {
        // Arrange
        final event1 = LoadBooks();
        final event2 = LoadBooks();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend HomeEvent', () {
        // Arrange
        final event = LoadBooks();

        // Act & Assert
        expect(event, isA<HomeEvent>());
      });
    });

    group('LoadMoreBooks', () {
      test('should have empty props', () {
        // Arrange
        final event = LoadMoreBooks();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are LoadMoreBooks', () {
        // Arrange
        final event1 = LoadMoreBooks();
        final event2 = LoadMoreBooks();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are LoadMoreBooks', () {
        // Arrange
        final event1 = LoadMoreBooks();
        final event2 = LoadMoreBooks();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend HomeEvent', () {
        // Arrange
        final event = LoadMoreBooks();

        // Act & Assert
        expect(event, isA<HomeEvent>());
      });

      test('should not be equal to LoadBooks', () {
        // Arrange
        final loadEvent = LoadBooks();
        final loadMoreEvent = LoadMoreBooks();

        // Act & Assert
        expect(loadEvent, isNot(equals(loadMoreEvent)));
      });
    });

    group('SearchBooks', () {
      test('should have correct props', () {
        // Arrange
        const query = 'test query';
        const event = SearchBooks(query);

        // Act & Assert
        expect(event.props, [query]);
      });

      test('should be equal when query is the same', () {
        // Arrange
        const query = 'same query';
        const event1 = SearchBooks(query);
        const event2 = SearchBooks(query);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when query is different', () {
        // Arrange
        const event1 = SearchBooks('query 1');
        const event2 = SearchBooks('query 2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when query is the same', () {
        // Arrange
        const query = 'test query';
        const event1 = SearchBooks(query);
        const event2 = SearchBooks(query);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend HomeEvent', () {
        // Arrange
        const event = SearchBooks('test');

        // Act & Assert
        expect(event, isA<HomeEvent>());
      });

      test('should handle empty query', () {
        // Arrange & Act
        const event = SearchBooks('');

        // Assert
        expect(event.query, equals(''));
        expect(event.props, ['']);
      });

      test('should handle special characters in query', () {
        // Arrange
        const specialQuery = 'query with special chars: !@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        const event = SearchBooks(specialQuery);

        // Act & Assert
        expect(event.query, equals(specialQuery));
        expect(event.props, [specialQuery]);
      });

      test('should handle Unicode characters in query', () {
        // Arrange
        const unicodeQuery = '搜索查询 - Search Query - 📚🔍';
        const event = SearchBooks(unicodeQuery);

        // Act & Assert
        expect(event.query, equals(unicodeQuery));
        expect(event.props, [unicodeQuery]);
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
        const bookId = 'same-book-id';
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

      test('should extend HomeEvent', () {
        // Arrange
        const event = ToggleFavorite('test-book-id');

        // Act & Assert
        expect(event, isA<HomeEvent>());
      });

      test('should handle empty string bookId', () {
        // Arrange & Act
        const event = ToggleFavorite('');

        // Assert
        expect(event.bookId, equals(''));
        expect(event.props, ['']);
      });
    });

    group('RefreshBooks', () {
      test('should have empty props', () {
        // Arrange
        final event = RefreshBooks();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are RefreshBooks', () {
        // Arrange
        final event1 = RefreshBooks();
        final event2 = RefreshBooks();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are RefreshBooks', () {
        // Arrange
        final event1 = RefreshBooks();
        final event2 = RefreshBooks();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend HomeEvent', () {
        // Arrange
        final event = RefreshBooks();

        // Act & Assert
        expect(event, isA<HomeEvent>());
      });
    });

    group('ClearSearch', () {
      test('should have empty props', () {
        // Arrange
        final event = ClearSearch();

        // Act & Assert
        expect(event.props, isEmpty);
      });

      test('should be equal when both are ClearSearch', () {
        // Arrange
        final event1 = ClearSearch();
        final event2 = ClearSearch();

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should have same hashCode when both are ClearSearch', () {
        // Arrange
        final event1 = ClearSearch();
        final event2 = ClearSearch();

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend HomeEvent', () {
        // Arrange
        final event = ClearSearch();

        // Act & Assert
        expect(event, isA<HomeEvent>());
      });
    });

    group('HomeEvent base class', () {
      test('should have empty props by default', () {
        // This tests the abstract base class through a concrete implementation
        final event = LoadBooks();
        
        // Verify that the base class props behavior is working
        expect(event.props, isA<List<Object>>());
        expect(event.props, isEmpty);
      });

      test('should support toString method', () {
        // Arrange
        final event = LoadBooks();

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should test base class props method directly', () {
        // Create a test implementation to access base class behavior
        final testEvent = _TestHomeEvent();
        
        // Act & Assert
        expect(testEvent.props, isEmpty);
        expect(testEvent.props, isA<List<Object>>());
      });
    });

    group('Event type differentiation', () {
      test('should be able to distinguish between different event types', () {
        // Arrange
        final loadEvent = LoadBooks();
        final loadMoreEvent = LoadMoreBooks();
        const searchEvent = SearchBooks('test');
        const toggleEvent = ToggleFavorite('book-id');
        final refreshEvent = RefreshBooks();
        final clearEvent = ClearSearch();

        // Act & Assert - All events should be different types
        final eventTypes = [
          loadEvent.runtimeType,
          loadMoreEvent.runtimeType,
          searchEvent.runtimeType,
          toggleEvent.runtimeType,
          refreshEvent.runtimeType,
          clearEvent.runtimeType,
        ];

        // Check that all types are unique
        expect(eventTypes.toSet().length, equals(eventTypes.length));
        
        // But all should be HomeEvent
        expect(loadEvent, isA<HomeEvent>());
        expect(loadMoreEvent, isA<HomeEvent>());
        expect(searchEvent, isA<HomeEvent>());
        expect(toggleEvent, isA<HomeEvent>());
        expect(refreshEvent, isA<HomeEvent>());
        expect(clearEvent, isA<HomeEvent>());
      });

      test('should work correctly with Set operations', () {
        // Arrange
        final event1 = LoadBooks();
        final event2 = LoadBooks();
        final event3 = LoadMoreBooks();

        // Act - Create set by adding elements instead of literal
        final eventSet = <HomeEvent>{};
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
        final loadEvent = LoadBooks();
        final loadMoreEvent = LoadMoreBooks();
        const searchEvent = SearchBooks('test');
        const toggleEvent = ToggleFavorite('book-id');
        final refreshEvent = RefreshBooks();
        final clearEvent = ClearSearch();

        final events = [loadEvent, loadMoreEvent, searchEvent, toggleEvent, refreshEvent, clearEvent];
        
        // Act & Assert - All events should be different
        for (int i = 0; i < events.length; i++) {
          for (int j = i + 1; j < events.length; j++) {
            expect(events[i], isNot(equals(events[j])),
                reason: '${events[i].runtimeType} should not equal ${events[j].runtimeType}');
          }
        }
      });
    });

    group('Event polymorphism', () {
      test('should work correctly with polymorphic lists', () {
        // Arrange
        final List<HomeEvent> events = [
          LoadBooks(),
          LoadMoreBooks(),
          const SearchBooks('test query'),
          const ToggleFavorite('book-id'),
          RefreshBooks(),
          ClearSearch(),
        ];

        // Act & Assert
        expect(events.length, equals(6));
        expect(events[0], isA<LoadBooks>());
        expect(events[1], isA<LoadMoreBooks>());
        expect(events[2], isA<SearchBooks>());
        expect(events[3], isA<ToggleFavorite>());
        expect(events[4], isA<RefreshBooks>());
        expect(events[5], isA<ClearSearch>());
        
        // Check properties
        expect((events[2] as SearchBooks).query, equals('test query'));
        expect((events[3] as ToggleFavorite).bookId, equals('book-id'));
      });

      test('should support pattern matching', () {
        // Arrange
        final List<HomeEvent> events = [
          LoadBooks(),
          const SearchBooks('search query'),
          const ToggleFavorite('book-id'),
        ];

        // Act & Assert - Pattern matching via type checking
        for (final event in events) {
          if (event is LoadBooks) {
            expect(event, isA<LoadBooks>());
          } else if (event is SearchBooks) {
            expect(event, isA<SearchBooks>());
            expect(event.query, equals('search query'));
          } else if (event is ToggleFavorite) {
            expect(event, isA<ToggleFavorite>());
            expect(event.bookId, equals('book-id'));
          } else {
            fail('Unexpected event type: ${event.runtimeType}');
          }
        }
      });
    });

    group('Event const constructors', () {
      test('should support const constructor for events with parameters', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const searchEvent1 = SearchBooks('test');
        const searchEvent2 = SearchBooks('test');
        const toggleEvent1 = ToggleFavorite('book-id');
        const toggleEvent2 = ToggleFavorite('book-id');

        // Assert - Should be the same instance due to const optimization
        expect(identical(searchEvent1, searchEvent2), isTrue);
        expect(identical(toggleEvent1, toggleEvent2), isTrue);
      });

      test('should create new instances for non-const events', () {
        // Arrange & Act
        final loadEvent1 = LoadBooks();
        final loadEvent2 = LoadBooks();
        final loadMoreEvent1 = LoadMoreBooks();
        final loadMoreEvent2 = LoadMoreBooks();

        // Assert - Should be different instances but equal
        expect(identical(loadEvent1, loadEvent2), isFalse);
        expect(loadEvent1, equals(loadEvent2));
        expect(identical(loadMoreEvent1, loadMoreEvent2), isFalse);
        expect(loadMoreEvent1, equals(loadMoreEvent2));
      });
    });
  });
}

/// Test implementation of HomeEvent to access base class behavior
class _TestHomeEvent extends HomeEvent {
  const _TestHomeEvent();
}
