import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_event.dart';

void main() {
  group('PolicyEvent', () {
    group('LoadPolicy', () {
      test('should store policyId correctly', () {
        // Arrange
        const policyId = 'privacy-policy';
        final event = LoadPolicy(policyId);

        // Act & Assert
        expect(event.policyId, equals(policyId));
        expect(event, isA<PolicyEvent>());
      });

      test('should be equal when policyIds are the same', () {
        // Arrange
        const policyId = 'privacy-policy';
        final event1 = LoadPolicy(policyId);
        final event2 = LoadPolicy(policyId);

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when policyIds are different', () {
        // Arrange
        final event1 = LoadPolicy('privacy-policy');
        final event2 = LoadPolicy('terms-policy');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
        expect(event1.hashCode, isNot(equals(event2.hashCode)));
      });

      test('should handle empty policyId', () {
        // Arrange
        final event = LoadPolicy('');

        // Act & Assert
        expect(event.policyId, isEmpty);
        expect(event, isA<LoadPolicy>());
      });

      test('should handle special characters in policyId', () {
        // Arrange
        const specialPolicyId = 'policy-!@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        final event = LoadPolicy(specialPolicyId);

        // Act & Assert
        expect(event.policyId, equals(specialPolicyId));
      });

      test('should handle Unicode characters in policyId', () {
        // Arrange
        const unicodePolicyId = 'policy-隐私政策-プライバシー-🔒';
        final event = LoadPolicy(unicodePolicyId);

        // Act & Assert
        expect(event.policyId, equals(unicodePolicyId));
      });

      test('should handle very long policyId', () {
        // Arrange
        final longPolicyId = 'policy-${'a' * 1000}';
        final event = LoadPolicy(longPolicyId);

        // Act & Assert
        expect(event.policyId.length, equals(1007)); // 'policy-' + 1000 'a's
        expect(event.policyId, equals(longPolicyId));
      });

      test('should be identical when same instance', () {
        // Arrange
        final event = LoadPolicy('test-policy');

        // Act & Assert
        expect(identical(event, event), isTrue);
        expect(event == event, isTrue);
      });

      test('should handle null-like string values', () {
        // Arrange
        final event1 = LoadPolicy('null');
        final event2 = LoadPolicy('undefined');
        final event3 = LoadPolicy('NaN');

        // Act & Assert
        expect(event1.policyId, equals('null'));
        expect(event2.policyId, equals('undefined'));
        expect(event3.policyId, equals('NaN'));
      });

      test('should handle whitespace-only policyId', () {
        // Arrange
        final event1 = LoadPolicy('   ');
        final event2 = LoadPolicy('\t\n');
        final event3 = LoadPolicy(' \r\n ');

        // Act & Assert
        expect(event1.policyId, equals('   '));
        expect(event2.policyId, equals('\t\n'));
        expect(event3.policyId, equals(' \r\n '));
      });

      test('should handle multiline policyId', () {
        // Arrange
        const multilinePolicyId = '''policy-line1
line2
line3''';
        final event = LoadPolicy(multilinePolicyId);

        // Act & Assert
        expect(event.policyId, equals(multilinePolicyId));
        expect(event.policyId.split('\n').length, equals(3));
      });
    });

    group('RefreshPolicy', () {
      test('should store policyId correctly', () {
        // Arrange
        const policyId = 'terms-policy';
        final event = RefreshPolicy(policyId);

        // Act & Assert
        expect(event.policyId, equals(policyId));
        expect(event, isA<PolicyEvent>());
      });

      test('should be equal when policyIds are the same', () {
        // Arrange
        const policyId = 'terms-policy';
        final event1 = RefreshPolicy(policyId);
        final event2 = RefreshPolicy(policyId);

        // Act & Assert
        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when policyIds are different', () {
        // Arrange
        final event1 = RefreshPolicy('privacy-policy');
        final event2 = RefreshPolicy('terms-policy');

        // Act & Assert
        expect(event1, isNot(equals(event2)));
        expect(event1.hashCode, isNot(equals(event2.hashCode)));
      });

      test('should handle empty policyId', () {
        // Arrange
        final event = RefreshPolicy('');

        // Act & Assert
        expect(event.policyId, isEmpty);
        expect(event, isA<RefreshPolicy>());
      });

      test('should handle special characters in policyId', () {
        // Arrange
        const specialPolicyId = 'policy-!@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        final event = RefreshPolicy(specialPolicyId);

        // Act & Assert
        expect(event.policyId, equals(specialPolicyId));
      });

      test('should handle Unicode characters in policyId', () {
        // Arrange
        const unicodePolicyId = 'policy-条款-利用規約-📋';
        final event = RefreshPolicy(unicodePolicyId);

        // Act & Assert
        expect(event.policyId, equals(unicodePolicyId));
      });

      test('should be identical when same instance', () {
        // Arrange
        final event = RefreshPolicy('test-policy');

        // Act & Assert
        expect(identical(event, event), isTrue);
        expect(event == event, isTrue);
      });

      test('should not be equal to LoadPolicy with same policyId', () {
        // Arrange
        const policyId = 'test-policy';
        final loadEvent = LoadPolicy(policyId);
        final refreshEvent = RefreshPolicy(policyId);

        // Act & Assert
        expect(loadEvent, isNot(equals(refreshEvent)));
        expect(loadEvent.runtimeType, isNot(equals(refreshEvent.runtimeType)));
        expect(loadEvent.policyId, equals(refreshEvent.policyId)); // Same policyId
      });
    });

    group('Event type differentiation', () {
      test('should distinguish between different event types', () {
        // Arrange
        const policyId = 'test-policy';
        final loadEvent = LoadPolicy(policyId);
        final refreshEvent = RefreshPolicy(policyId);

        // Act & Assert - All events should be different types
        expect(loadEvent.runtimeType, isNot(equals(refreshEvent.runtimeType)));
        
        // But all should be PolicyEvent
        expect(loadEvent, isA<PolicyEvent>());
        expect(refreshEvent, isA<PolicyEvent>());
      });

      test('should work correctly with Set operations', () {
        // Arrange
        final event1 = LoadPolicy('policy-1');
        final event2 = LoadPolicy('policy-1'); // Same as event1
        final event3 = LoadPolicy('policy-2');
        final event4 = RefreshPolicy('policy-1');

        // Act - Create set by adding elements
        final eventSet = <PolicyEvent>{};
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

    group('Event polymorphism', () {
      test('should work correctly with polymorphic lists', () {
        // Arrange
        final List<PolicyEvent> events = [
          LoadPolicy('privacy-policy'),
          RefreshPolicy('terms-policy'),
          LoadPolicy('cookie-policy'),
          RefreshPolicy('privacy-policy'),
        ];

        // Act & Assert
        expect(events.length, equals(4));
        expect(events[0], isA<LoadPolicy>());
        expect(events[1], isA<RefreshPolicy>());
        expect(events[2], isA<LoadPolicy>());
        expect(events[3], isA<RefreshPolicy>());
        
        expect((events[0] as LoadPolicy).policyId, equals('privacy-policy'));
        expect((events[1] as RefreshPolicy).policyId, equals('terms-policy'));
        expect((events[2] as LoadPolicy).policyId, equals('cookie-policy'));
        expect((events[3] as RefreshPolicy).policyId, equals('privacy-policy'));
      });

      test('should support pattern matching', () {
        // Arrange
        final List<PolicyEvent> events = [
          LoadPolicy('privacy-policy'),
          RefreshPolicy('terms-policy'),
        ];

        // Act & Assert - Type checking via 'is'
        for (final event in events) {
          if (event is LoadPolicy) {
            expect(event, isA<LoadPolicy>());
            expect(event.policyId, isA<String>());
            expect(event.policyId, isNotEmpty);
          } else if (event is RefreshPolicy) {
            expect(event, isA<RefreshPolicy>());
            expect(event.policyId, isA<String>());
            expect(event.policyId, isNotEmpty);
          } else {
            fail('Unexpected event type: ${event.runtimeType}');
          }
        }
      });
    });

    group('Equality and hashCode behavior', () {
      test('should maintain equality contract for LoadPolicy', () {
        // Arrange
        const policyId = 'test-policy';
        final event1 = LoadPolicy(policyId);
        final event2 = LoadPolicy(policyId);
        final event3 = LoadPolicy(policyId);

        // Act & Assert - Reflexive, symmetric, and transitive
        expect(event1 == event1, isTrue); // Reflexive
        expect(event1 == event2, isTrue); // Symmetric
        expect(event2 == event1, isTrue); // Symmetric
        expect(event1 == event2 && event2 == event3, isTrue); // Transitive setup
        expect(event1 == event3, isTrue); // Transitive
        
        // Consistent hashCode
        expect(event1.hashCode == event2.hashCode, isTrue);
        expect(event1.hashCode == event3.hashCode, isTrue);
      });

      test('should maintain equality contract for RefreshPolicy', () {
        // Arrange
        const policyId = 'test-policy';
        final event1 = RefreshPolicy(policyId);
        final event2 = RefreshPolicy(policyId);
        final event3 = RefreshPolicy(policyId);

        // Act & Assert - Reflexive, symmetric, and transitive
        expect(event1 == event1, isTrue); // Reflexive
        expect(event1 == event2, isTrue); // Symmetric
        expect(event2 == event1, isTrue); // Symmetric
        expect(event1 == event2 && event2 == event3, isTrue); // Transitive setup
        expect(event1 == event3, isTrue); // Transitive
        
        // Consistent hashCode
        expect(event1.hashCode == event2.hashCode, isTrue);
        expect(event1.hashCode == event3.hashCode, isTrue);
      });

      test('should handle equality with different types', () {
        // Arrange
        final loadEvent = LoadPolicy('test-policy');
        final refreshEvent = RefreshPolicy('test-policy');
        const otherObject = 'not an event';

        // Act & Assert
        expect(loadEvent == refreshEvent, isFalse);
        expect(loadEvent.toString() == otherObject, isFalse);
        expect(refreshEvent.toString() == otherObject, isFalse);
      });
    });

    group('Edge cases and validation', () {
      test('should handle rapid event creation', () {
        // Arrange & Act - Create many events rapidly
        final events = List.generate(1000, (index) {
          switch (index % 2) {
            case 0:
              return LoadPolicy('policy-$index');
            default:
              return RefreshPolicy('policy-$index');
          }
        });

        // Assert
        expect(events.length, equals(1000));
        expect(events.whereType<LoadPolicy>().length, equals(500));
        expect(events.whereType<RefreshPolicy>().length, equals(500));
      });

      test('should handle event comparison in maps', () {
        // Arrange
        final loadEvent = LoadPolicy('privacy-policy');
        final refreshEvent = RefreshPolicy('terms-policy');

        final eventMap = <PolicyEvent, String>{
          loadEvent: 'load',
          refreshEvent: 'refresh',
        };

        // Act & Assert
        expect(eventMap[LoadPolicy('privacy-policy')], equals('load'));
        expect(eventMap[RefreshPolicy('terms-policy')], equals('refresh'));
        expect(eventMap.length, equals(2));
      });

      test('should maintain immutability', () {
        // Arrange
        const policyId = 'test-policy';
        final loadEvent = LoadPolicy(policyId);
        final refreshEvent = RefreshPolicy(policyId);

        // Act - Try to access properties multiple times
        final loadPolicyId1 = loadEvent.policyId;
        final loadPolicyId2 = loadEvent.policyId;
        final refreshPolicyId1 = refreshEvent.policyId;
        final refreshPolicyId2 = refreshEvent.policyId;

        // Assert - Should be consistent
        expect(loadPolicyId1, equals(policyId));
        expect(loadPolicyId2, equals(policyId));
        expect(loadPolicyId1, equals(loadPolicyId2));
        expect(refreshPolicyId1, equals(policyId));
        expect(refreshPolicyId2, equals(policyId));
        expect(refreshPolicyId1, equals(refreshPolicyId2));
      });

      test('should handle multiple events with same policyId but different types', () {
        // Arrange
        const policyId = 'shared-policy';
        final events = [
          LoadPolicy(policyId),
          RefreshPolicy(policyId),
          LoadPolicy(policyId), // Duplicate type and policyId
          RefreshPolicy(policyId), // Duplicate type and policyId
        ];

        // Act - Create set to test uniqueness
        final eventSet = events.toSet();

        // Assert - Should contain only 2 unique events (one of each type)
        expect(eventSet.length, equals(2));
        expect(eventSet.whereType<LoadPolicy>().length, equals(1));
        expect(eventSet.whereType<RefreshPolicy>().length, equals(1));
        expect(eventSet.whereType<LoadPolicy>().first.policyId, equals(policyId));
        expect(eventSet.whereType<RefreshPolicy>().first.policyId, equals(policyId));
      });

      test('should handle case-sensitive policyId comparison', () {
        // Arrange
        final event1 = LoadPolicy('Privacy-Policy');
        final event2 = LoadPolicy('privacy-policy');

        // Act & Assert - Should be case-sensitive
        expect(event1, isNot(equals(event2)));
        expect(event1.hashCode, isNot(equals(event2.hashCode)));
      });

      test('should handle events with escape sequences in policyId', () {
        // Arrange
        const policyIdWithEscapes = 'policy-\\"quoted\\" with \\n newline and \\t tab';
        final loadEvent = LoadPolicy(policyIdWithEscapes);
        final refreshEvent = RefreshPolicy(policyIdWithEscapes);

        // Act & Assert
        expect(loadEvent.policyId, equals(policyIdWithEscapes));
        expect(refreshEvent.policyId, equals(policyIdWithEscapes));
        expect(loadEvent, isNot(equals(refreshEvent))); // Different types
      });
    });
  });
}
