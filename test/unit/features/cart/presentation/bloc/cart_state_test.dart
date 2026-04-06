import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartState', () {
    final testBook = Book(
      id: 'book1',
      title: 'Test Book',
      author: 'Test Author',
      description: 'Test Description',
      imageUrls: const ['test_url'],
      rating: 4.5,
      publishedYear: 2023,
      isFavorite: false,
      isFromFriend: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction'],
        pageCount: 300,
        language: 'English',
      ),
      pricing: const BookPricing(
        salePrice: 25.99,
        rentPrice: 5.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 5,
        availableForSaleCount: 3,
        totalCopies: 8,
      ),
    );

    final testCartItem = CartItem(
      id: 'cart1',
      book: testBook,
      type: CartItemType.rent,
      addedAt: DateTime(2025, 10, 31),
      rentalPeriodInDays: 14,
    );

    final testRequest = CartRequest(
      id: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'url',
      requesterId: 'user1',
      ownerId: 'owner1',
      requestType: CartItemType.rent,
      rentalPeriodInDays: 14,
      price: 29.99,
      status: RequestStatus.pending,
      createdAt: DateTime(2025, 10, 31),
    );

    group('CartInitial', () {
      test('should have empty props', () {
        final state = CartInitial();
        expect(state.props, []);
      });

      test('should support value equality', () {
        final state1 = CartInitial();
        final state2 = CartInitial();
        expect(state1, state2);
      });
    });

    group('CartLoading', () {
      test('should have empty props', () {
        final state = CartLoading();
        expect(state.props, []);
      });

      test('should support value equality', () {
        final state1 = CartLoading();
        final state2 = CartLoading();
        expect(state1, state2);
      });
    });

    group('CartLoaded', () {
      test('should create with default values', () {
        final state = CartLoaded(items: [testCartItem]);
        expect(state.items, [testCartItem]);
        expect(state.total, 0.0);
        expect(state.receivedRequests, []);
        expect(state.isProcessing, false);
      });

      test('should create with all parameters', () {
        final state = CartLoaded(
          items: [testCartItem],
          total: 29.99,
          receivedRequests: [testRequest],
          isProcessing: true,
        );

        expect(state.items, [testCartItem]);
        expect(state.total, 29.99);
        expect(state.receivedRequests, [testRequest]);
        expect(state.isProcessing, true);
      });

      test('should include all properties in props', () {
        final state = CartLoaded(
          items: [testCartItem],
          total: 29.99,
          receivedRequests: [testRequest],
          isProcessing: true,
        );

        expect(state.props.length, 4);
        expect(state.props[0], [testCartItem]);
        expect(state.props[1], 29.99);
        expect(state.props[2], [testRequest]);
        expect(state.props[3], true);
      });

      test('copyWith should create new state with updated data', () {
        final state = CartLoaded(items: [testCartItem]);
        final newItem = testCartItem.copyWith(id: 'cart2');
        final newState = state.copyWith([newItem]);

        expect(newState.items, [newItem]);
        expect(newState.total, 0.0); // Should preserve other fields
      });

      test('copyWithState should update specific fields', () {
        final state = CartLoaded(
          items: [testCartItem],
          total: 10.0,
          receivedRequests: [],
          isProcessing: false,
        );

        final newState = state.copyWithState(
          total: 20.0,
          isProcessing: true,
        );

        expect(newState.items, [testCartItem]); // Preserved
        expect(newState.total, 20.0); // Updated
        expect(newState.receivedRequests, []); // Preserved
        expect(newState.isProcessing, true); // Updated
      });

      test('copyWithState should preserve values when parameters are null', () {
        final state = CartLoaded(
          items: [testCartItem],
          total: 30.0,
          receivedRequests: [testRequest],
          isProcessing: true,
        );

        final newState = state.copyWithState();

        expect(newState.items, state.items);
        expect(newState.total, state.total);
        expect(newState.receivedRequests, state.receivedRequests);
        expect(newState.isProcessing, state.isProcessing);
      });

      test('should support value equality', () {
        final state1 = CartLoaded(
          items: [testCartItem],
          total: 29.99,
          receivedRequests: [testRequest],
          isProcessing: false,
        );
        final state2 = CartLoaded(
          items: [testCartItem],
          total: 29.99,
          receivedRequests: [testRequest],
          isProcessing: false,
        );

        expect(state1, state2);
      });

      test('should not be equal if properties differ', () {
        final state1 = CartLoaded(items: [testCartItem], total: 10.0);
        final state2 = CartLoaded(items: [testCartItem], total: 20.0);

        expect(state1, isNot(state2));
      });

      test('should handle empty items list', () {
        final state = CartLoaded(items: []);
        expect(state.items, []);
      });

      test('should handle multiple items', () {
        final item2 = testCartItem.copyWith(id: 'cart2');
        final state = CartLoaded(items: [testCartItem, item2]);
        expect(state.items.length, 2);
      });
    });

    group('CartError', () {
      test('should create with error message', () {
        final state = const CartError('Error message');
        expect(state.message, 'Error message');
      });

      test('should include message in props', () {
        final state = const CartError('Error message');
        expect(state.props, ['Error message']);
      });

      test('should support value equality', () {
        final state1 = const CartError('Error message');
        final state2 = const CartError('Error message');
        expect(state1, state2);
      });

      test('should not be equal if messages differ', () {
        final state1 = const CartError('Error 1');
        final state2 = const CartError('Error 2');
        expect(state1, isNot(state2));
      });
    });

    group('CartOperationSuccess', () {
      test('should create with success message', () {
        final state = const CartOperationSuccess('Success');
        expect(state.message, 'Success');
      });

      test('should include message in props', () {
        final state = const CartOperationSuccess('Success');
        expect(state.props, ['Success']);
      });

      test('should support value equality', () {
        final state1 = const CartOperationSuccess('Success');
        final state2 = const CartOperationSuccess('Success');
        expect(state1, state2);
      });
    });

    group('CartRefreshing', () {
      test('should create with items', () {
        final state = CartRefreshing([testCartItem]);
        expect(state.data, [testCartItem]);
      });

      test('copyWith should create new state with updated data', () {
        final state = CartRefreshing([testCartItem]);
        final newItem = testCartItem.copyWith(id: 'cart2');
        final newState = state.copyWith([newItem]);

        expect(newState.data, [newItem]);
      });

      test('should handle empty items list', () {
        final state = const CartRefreshing([]);
        expect(state.data, []);
      });
    });
  });
}
