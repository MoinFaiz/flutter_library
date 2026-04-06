# Shopping Cart Feature - Sample Test Suite

This document demonstrates the testing approach for the shopping cart feature with sample unit and widget tests.

## Test Coverage Overview

### Created Test Files (5 files, 32 tests)

#### Unit Tests

1. **cart_item_test.dart** (10 tests)
   - Entity properties validation
   - Price calculation for rental vs purchase
   - Request tracking (hasRequestSent, requestId)
   - Value equality with Equatable
   - copyWith functionality
   - Default rental period behavior

2. **get_cart_items_usecase_test.dart** (3 tests)
   - Success scenario: Returns cart items from repository
   - Server failure handling
   - Network failure handling

3. **add_to_cart_usecase_test.dart** (6 tests)
   - Adding rental items with custom period
   - Adding purchase items
   - Default rental period (14 days)
   - Server failure handling
   - Repository mock verification

4. **cart_bloc_test.dart** (3 tests)
   - Initial state verification (CartInitial)
   - LoadCartItems success flow (CartLoading → CartLoaded)
   - LoadCartItems failure flow (CartLoading → CartError)
   - RefreshCart state transitions

#### Widget Tests

5. **cart_item_card_test.dart** (10 tests)
   - Display book title and author
   - Rental badge display ("Rent (14 days)")
   - Purchase badge display ("Purchase")
   - Correct price display (rental: $5.00, purchase: $20.00)
   - Request button states (Request/Requested)
   - onRemove callback invocation
   - onSendRequest callback invocation
   - Request sent state (Chip widget)

## Test Results

✅ All 32 tests passing
- 22 unit tests
- 10 widget tests

## Testing Patterns Demonstrated

### 1. Entity Testing
```dart
test('should create CartItem with correct properties', () {
  expect(testCartItem.id, equals('cart1'));
  expect(testCartItem.book, equals(mockBook));
  expect(testCartItem.type, equals(CartItemType.rent));
});
```

### 2. Use Case Testing with Mocks
```dart
when(() => mockRepository.getCartItems())
    .thenAnswer((_) async => Right(mockCartItems));

final result = await useCase();

expect(result, equals(Right(mockCartItems)));
verify(() => mockRepository.getCartItems()).called(1);
```

### 3. BLoC Testing with bloc_test
```dart
blocTest<CartBloc, CartState>(
  'emits [CartLoading, CartLoaded] when LoadCartItems succeeds',
  build: () => cartBloc,
  act: (bloc) => bloc.add(LoadCartItems()),
  expect: () => [CartLoading(), CartLoaded(...)],
);
```

### 4. Widget Testing with Finders
```dart
testWidgets('displays book title and author', (tester) async {
  await tester.pumpWidget(buildTestWidget(testCartItem));
  
  expect(find.text('Test Book Title'), findsOneWidget);
  expect(find.text('Test Author'), findsOneWidget);
});
```

### 5. Interaction Testing
```dart
testWidgets('calls onRemove when delete button tapped', (tester) async {
  var deleteCalled = false;
  await tester.pumpWidget(buildTestWidget(
    testCartItem,
    onRemove: () => deleteCalled = true,
  ));

  await tester.tap(find.byIcon(Icons.delete_outline));
  await tester.pump();

  expect(deleteCalled, isTrue);
});
```

## Dependencies Used

- **flutter_test**: Core testing framework
- **mocktail**: Mocking library for dependencies
- **bloc_test**: BLoC-specific testing utilities
- **dartz**: Functional Either types for error handling

## Test Organization

```
test/
├── unit/
│   └── features/
│       └── cart/
│           ├── domain/
│           │   ├── entities/
│           │   │   └── cart_item_test.dart
│           │   └── usecases/
│           │       ├── get_cart_items_usecase_test.dart
│           │       └── add_to_cart_usecase_test.dart
│           └── presentation/
│               └── bloc/
│                   └── cart_bloc_test.dart
└── widget/
    └── features/
        └── cart/
            └── presentation/
                └── widgets/
                    └── cart_item_card_test.dart
```

## Additional Tests to Implement

To achieve comprehensive coverage, add tests for:

### Domain Layer
- [ ] cart_request_test.dart - Request entity tests
- [ ] cart_notification_test.dart - Notification entity tests
- [ ] remove_from_cart_usecase_test.dart
- [ ] send_rental_request_usecase_test.dart
- [ ] send_purchase_request_usecase_test.dart
- [ ] accept_request_usecase_test.dart
- [ ] reject_request_usecase_test.dart
- [ ] get_cart_total_usecase_test.dart
- [ ] get_received_requests_usecase_test.dart
- [ ] get_cart_notifications_usecase_test.dart
- [ ] mark_notification_as_read_usecase_test.dart

### Data Layer
- [ ] cart_item_model_test.dart - JSON serialization
- [ ] cart_request_model_test.dart
- [ ] cart_notification_model_test.dart
- [ ] cart_remote_datasource_test.dart - API calls with Dio
- [ ] cart_local_datasource_test.dart - SharedPreferences
- [ ] cart_repository_impl_test.dart - Remote/local coordination
- [ ] cart_notification_repository_impl_test.dart

### Presentation Layer
- [ ] cart_notification_bloc_test.dart - All events and states
- [ ] Additional cart_bloc_test.dart tests for remaining events

### Widget Tests
- [ ] cart_page_test.dart - Full page integration
- [ ] cart_summary_card_test.dart
- [ ] cart_notification_card_test.dart
- [ ] cart_notifications_page_test.dart

## Running Tests

### Run all cart tests:
```bash
flutter test test/unit/features/cart test/widget/features/cart
```

### Run specific test file:
```bash
flutter test test/unit/features/cart/domain/entities/cart_item_test.dart
```

### Run with coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Quality Guidelines

1. **Arrange-Act-Assert** pattern
2. **One assertion per test** (where possible)
3. **Descriptive test names** explaining what is tested
4. **Mock external dependencies** (repositories, data sources)
5. **Test both success and failure paths**
6. **Verify mock interactions** with `verify()`
7. **Test edge cases** (null values, empty lists, etc.)
8. **Widget tests verify UI** and user interactions

## Coverage Goals

- **Entities**: 100% (pure data classes)
- **Use Cases**: 100% (single responsibility)
- **Repositories**: >90% (error handling paths)
- **BLoCs**: >90% (all events and states)
- **Widgets**: >80% (key user flows)

## Notes

- All sample tests follow existing project patterns
- Tests use realistic mock data with proper Book entities
- BLoC tests verify state transitions and use case calls
- Widget tests check both rendering and interactions
- Error handling is tested for network and server failures
