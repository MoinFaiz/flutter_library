import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_event.dart';

void main() {
  group('RentalStatusEvent', () {
    group('LoadRentalStatus', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = LoadRentalStatus(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = LoadRentalStatus(bookId);
        const event2 = LoadRentalStatus(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = LoadRentalStatus('book-id-1');
        const event2 = LoadRentalStatus('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = LoadRentalStatus(bookId);
        const event2 = LoadRentalStatus(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend RentalStatusEvent', () {
        // Arrange
        const event = LoadRentalStatus('test-book-id');

        // Act & Assert
        expect(event, isA<RentalStatusEvent>());
      });
    });

    group('RentBook', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = RentBook(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RentBook(bookId);
        const event2 = RentBook(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = RentBook('book-id-1');
        const event2 = RentBook('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RentBook(bookId);
        const event2 = RentBook(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend RentalStatusEvent', () {
        // Arrange
        const event = RentBook('test-book-id');

        // Act & Assert
        expect(event, isA<RentalStatusEvent>());
      });
    });

    group('BuyBook', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = BuyBook(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = BuyBook(bookId);
        const event2 = BuyBook(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = BuyBook('book-id-1');
        const event2 = BuyBook('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = BuyBook(bookId);
        const event2 = BuyBook(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend RentalStatusEvent', () {
        // Arrange
        const event = BuyBook('test-book-id');

        // Act & Assert
        expect(event, isA<RentalStatusEvent>());
      });
    });

    group('ReturnBook', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = ReturnBook(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = ReturnBook(bookId);
        const event2 = ReturnBook(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = ReturnBook('book-id-1');
        const event2 = ReturnBook('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = ReturnBook(bookId);
        const event2 = ReturnBook(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend RentalStatusEvent', () {
        // Arrange
        const event = ReturnBook('test-book-id');

        // Act & Assert
        expect(event, isA<RentalStatusEvent>());
      });
    });

    group('RenewBook', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = RenewBook(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RenewBook(bookId);
        const event2 = RenewBook(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = RenewBook('book-id-1');
        const event2 = RenewBook('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RenewBook(bookId);
        const event2 = RenewBook(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend RentalStatusEvent', () {
        // Arrange
        const event = RenewBook('test-book-id');

        // Act & Assert
        expect(event, isA<RentalStatusEvent>());
      });
    });

    group('RemoveFromCart', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = RemoveFromCart(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RemoveFromCart(bookId);
        const event2 = RemoveFromCart(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = RemoveFromCart('book-id-1');
        const event2 = RemoveFromCart('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RemoveFromCart(bookId);
        const event2 = RemoveFromCart(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend RentalStatusEvent', () {
        // Arrange
        const event = RemoveFromCart('test-book-id');

        // Act & Assert
        expect(event, isA<RentalStatusEvent>());
      });
    });

    group('RefreshRentalStatus', () {
      test('should have correct props', () {
        // Arrange
        const bookId = 'test-book-id';
        const event = RefreshRentalStatus(bookId);

        // Act & Assert
        expect(event.props, [bookId]);
      });

      test('should be equal when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RefreshRentalStatus(bookId);
        const event2 = RefreshRentalStatus(bookId);

        // Act & Assert
        expect(event1, equals(event2));
      });

      test('should not be equal when bookId is different', () {
        // Arrange
        const event1 = RefreshRentalStatus('book-id-1');
        const event2 = RefreshRentalStatus('book-id-2');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
      });

      test('should have same hashCode when bookId is the same', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = RefreshRentalStatus(bookId);
        const event2 = RefreshRentalStatus(bookId);

        // Act & Assert
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should extend RentalStatusEvent', () {
        // Arrange
        const event = RefreshRentalStatus('test-book-id');

        // Act & Assert
        expect(event, isA<RentalStatusEvent>());
      });
    });

    group('RentalStatusEvent base class', () {
      test('should have empty props by default', () {
        // This tests the abstract base class through a concrete implementation
        const event = LoadRentalStatus('test-id');
        
        // Verify that the base class props behavior is working
        expect(event.props, isA<List<Object?>>());
        expect(event.props, isNotEmpty); // LoadRentalStatus overrides this
      });

      test('should support toString method', () {
        // Arrange
        const event = LoadRentalStatus('test-book-id');

        // Act
        final result = event.toString();

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should test base class props method directly', () {
        // Create a test implementation to access base class behavior
        final testEvent = _TestRentalStatusEvent();
        
        // Act & Assert
        expect(testEvent.props, isEmpty);
        expect(testEvent.props, isA<List<Object?>>());
      });
    });

    group('Event type differentiation', () {
      test('should be able to distinguish between different event types', () {
        // Arrange
        const bookId = 'test-book-id';
        const loadEvent = LoadRentalStatus(bookId);
        const rentEvent = RentBook(bookId);
        const buyEvent = BuyBook(bookId);
        const returnEvent = ReturnBook(bookId);
        const renewEvent = RenewBook(bookId);
        const removeEvent = RemoveFromCart(bookId);
        const refreshEvent = RefreshRentalStatus(bookId);

        // Act & Assert - All events should be different types
        final eventTypes = [
          loadEvent.runtimeType,
          rentEvent.runtimeType,
          buyEvent.runtimeType,
          returnEvent.runtimeType,
          renewEvent.runtimeType,
          removeEvent.runtimeType,
          refreshEvent.runtimeType,
        ];

        // Check that all types are unique
        expect(eventTypes.toSet().length, equals(eventTypes.length));
        
        // But all should be RentalStatusEvent
        expect(loadEvent, isA<RentalStatusEvent>());
        expect(rentEvent, isA<RentalStatusEvent>());
        expect(buyEvent, isA<RentalStatusEvent>());
        expect(returnEvent, isA<RentalStatusEvent>());
        expect(renewEvent, isA<RentalStatusEvent>());
        expect(removeEvent, isA<RentalStatusEvent>());
        expect(refreshEvent, isA<RentalStatusEvent>());
      });

      test('should work correctly with Set operations', () {
        // Arrange
        const bookId = 'test-book-id';
        const event1 = LoadRentalStatus(bookId);
        const event2 = LoadRentalStatus(bookId);
        const event3 = RentBook(bookId);

        // Act - Create set by adding elements instead of literal
        final eventSet = <RentalStatusEvent>{};
        eventSet.add(event1);
        eventSet.add(event2); // This should not be added as it's equal to event1
        eventSet.add(event3);

        // Assert - Set should contain only 2 unique events
        expect(eventSet.length, equals(2));
        expect(eventSet.contains(event1), isTrue);
        expect(eventSet.contains(event2), isTrue); // Same as event1
        expect(eventSet.contains(event3), isTrue);
      });

      test('should not be equal between different event types with same bookId', () {
        // Arrange
        const bookId = 'test-book-id';
        const loadEvent = LoadRentalStatus(bookId);
        const rentEvent = RentBook(bookId);
        const buyEvent = BuyBook(bookId);
        const returnEvent = ReturnBook(bookId);
        const renewEvent = RenewBook(bookId);
        const removeEvent = RemoveFromCart(bookId);
        const refreshEvent = RefreshRentalStatus(bookId);

        // Act & Assert - All events should be different even with same bookId
        final events = [loadEvent, rentEvent, buyEvent, returnEvent, renewEvent, removeEvent, refreshEvent];
        
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
        const bookId = 'test-book-id';
        final List<RentalStatusEvent> events = [
          const LoadRentalStatus(bookId),
          const RentBook(bookId),
          const BuyBook(bookId),
          const ReturnBook(bookId),
          const RenewBook(bookId),
          const RemoveFromCart(bookId),
          const RefreshRentalStatus(bookId),
        ];

        // Act & Assert
        expect(events.length, equals(7));
        expect(events[0], isA<LoadRentalStatus>());
        expect(events[1], isA<RentBook>());
        expect(events[2], isA<BuyBook>());
        expect(events[3], isA<ReturnBook>());
        expect(events[4], isA<RenewBook>());
        expect(events[5], isA<RemoveFromCart>());
        expect(events[6], isA<RefreshRentalStatus>());
        
        // All should have the same bookId
        for (final event in events) {
          if (event is LoadRentalStatus) {
            expect(event.bookId, equals(bookId));
          } else if (event is RentBook) {
            expect(event.bookId, equals(bookId));
          } else if (event is BuyBook) {
            expect(event.bookId, equals(bookId));
          } else if (event is ReturnBook) {
            expect(event.bookId, equals(bookId));
          } else if (event is RenewBook) {
            expect(event.bookId, equals(bookId));
          } else if (event is RemoveFromCart) {
            expect(event.bookId, equals(bookId));
          } else if (event is RefreshRentalStatus) {
            expect(event.bookId, equals(bookId));
          } else {
            fail('Unexpected event type: ${event.runtimeType}');
          }
        }
      });
    });

    group('Event edge cases and validation', () {
      test('should handle empty string bookId for all event types', () {
        // Arrange & Act
        const loadEvent = LoadRentalStatus('');
        const rentEvent = RentBook('');
        const buyEvent = BuyBook('');
        const returnEvent = ReturnBook('');
        const renewEvent = RenewBook('');
        const removeEvent = RemoveFromCart('');
        const refreshEvent = RefreshRentalStatus('');

        // Assert - Should not throw and should have empty string in props
        expect(loadEvent.props, ['']);
        expect(rentEvent.props, ['']);
        expect(buyEvent.props, ['']);
        expect(returnEvent.props, ['']);
        expect(renewEvent.props, ['']);
        expect(removeEvent.props, ['']);
        expect(refreshEvent.props, ['']);
      });

      test('should handle special characters in bookId', () {
        // Arrange
        const specialBookId = 'book-id-with-special-chars-!@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        const events = [
          LoadRentalStatus(specialBookId),
          RentBook(specialBookId),
          BuyBook(specialBookId),
          ReturnBook(specialBookId),
          RenewBook(specialBookId),
          RemoveFromCart(specialBookId),
          RefreshRentalStatus(specialBookId),
        ];

        // Act & Assert
        for (final event in events) {
          expect(event.props, [specialBookId]);
        }
      });

      test('should support const constructor for all event types', () {
        // Arrange & Act - These should compile without issues due to const constructors
        const loadEvent1 = LoadRentalStatus('test-id');
        const loadEvent2 = LoadRentalStatus('test-id');
        const rentEvent1 = RentBook('test-id');
        const rentEvent2 = RentBook('test-id');

        // Assert - Should be the same instance due to const optimization
        expect(identical(loadEvent1, loadEvent2), isTrue);
        expect(identical(rentEvent1, rentEvent2), isTrue);
      });
    });
  });
}

/// Test implementation of RentalStatusEvent to access base class behavior
class _TestRentalStatusEvent extends RentalStatusEvent {
  const _TestRentalStatusEvent();
}
