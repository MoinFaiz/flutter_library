import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('FavoritesState', () {
    final testBook = Book(
      id: '1',
      title: 'Test Book',
      author: 'Test Author',
      description: 'Test Description',
      imageUrls: const ['test_url'],
      rating: 4.5,
      publishedYear: 2023,
      isFavorite: true,
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

    final testBook2 = Book(
      id: '2',
      title: 'Test Book 2',
      author: 'Test Author 2',
      description: 'Test Description 2',
      imageUrls: const ['test_url_2'],
      rating: 3.5,
      publishedYear: 2022,
      isFavorite: true,
      isFromFriend: false,
      createdAt: DateTime(2022, 1, 1),
      updatedAt: DateTime(2022, 1, 1),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.youngAdult,
        genres: ['Romance'],
        pageCount: 250,
        language: 'English',
      ),
      pricing: const BookPricing(
        salePrice: 20.99,
        rentPrice: 4.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 3,
        availableForSaleCount: 2,
        totalCopies: 5,
      ),
    );

    group('FavoritesInitial', () {
      test('should have empty props', () {
        // Arrange
        final state = FavoritesInitial();

        // Act & Assert
        expect(state.props, isEmpty);
        expect(state, isA<FavoritesState>());
      });

      test('should be equal to another FavoritesInitial', () {
        // Arrange
        final state1 = FavoritesInitial();
        final state2 = FavoritesInitial();

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('FavoritesLoading', () {
      test('should have empty props', () {
        // Arrange
        final state = FavoritesLoading();

        // Act & Assert
        expect(state.props, isEmpty);
        expect(state, isA<FavoritesState>());
      });

      test('should be equal to another FavoritesLoading', () {
        // Arrange
        final state1 = FavoritesLoading();
        final state2 = FavoritesLoading();

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('FavoritesLoaded', () {
      test('should have correct props with default values', () {
        // Arrange
        final favoriteBooks = [testBook];
        final state = FavoritesLoaded(favoriteBooks: favoriteBooks);

        // Act & Assert
        expect(state.props, [favoriteBooks, 1, true, false]);
        expect(state.favoriteBooks, equals(favoriteBooks));
        expect(state.data, equals(favoriteBooks));
        expect(state.currentPage, equals(1));
        expect(state.hasMore, isTrue);
        expect(state.isLoadingMore, isFalse);
        expect(state, isA<FavoritesState>());
      });

      test('should have correct props with custom values', () {
        // Arrange
        final favoriteBooks = [testBook, testBook2];
        final state = FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          currentPage: 2,
          hasMore: false,
          isLoadingMore: true,
        );

        // Act & Assert
        expect(state.props, [favoriteBooks, 2, false, true]);
        expect(state.favoriteBooks, equals(favoriteBooks));
        expect(state.currentPage, equals(2));
        expect(state.hasMore, isFalse);
        expect(state.isLoadingMore, isTrue);
      });

      test('should be equal when all properties are the same', () {
        // Arrange
        final favoriteBooks = [testBook];
        final state1 = FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );
        final state2 = FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final favoriteBooks = [testBook];
        final state1 = FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );
        final state2 = FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          currentPage: 2,
          hasMore: true,
          isLoadingMore: false,
        );

        // Act & Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should create copy with new data using copyWith', () {
        // Arrange
        final originalBooks = [testBook];
        final newBooks = [testBook2];
        final originalState = FavoritesLoaded(
          favoriteBooks: originalBooks,
          currentPage: 2,
          hasMore: false,
          isLoadingMore: true,
        );

        // Act
        final newState = originalState.copyWith(newBooks);

        // Assert
        expect(newState.favoriteBooks, equals(newBooks));
        expect(newState.currentPage, equals(2)); // Should preserve other properties
        expect(newState.hasMore, isFalse);
        expect(newState.isLoadingMore, isTrue);
      });

      test('should create copy with state changes using copyWithState', () {
        // Arrange
        final originalBooks = [testBook];
        final originalState = FavoritesLoaded(
          favoriteBooks: originalBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );

        // Act
        final newState = originalState.copyWithState(
          currentPage: 2,
          hasMore: false,
          isLoadingMore: true,
        );

        // Assert
        expect(newState.favoriteBooks, equals(originalBooks)); // Should preserve
        expect(newState.currentPage, equals(2));
        expect(newState.hasMore, isFalse);
        expect(newState.isLoadingMore, isTrue);
      });

      test('should preserve original values when copyWithState called with nulls', () {
        // Arrange
        final originalBooks = [testBook];
        final originalState = FavoritesLoaded(
          favoriteBooks: originalBooks,
          currentPage: 2,
          hasMore: false,
          isLoadingMore: true,
        );

        // Act
        final newState = originalState.copyWithState();

        // Assert
        expect(newState.favoriteBooks, equals(originalBooks));
        expect(newState.currentPage, equals(2));
        expect(newState.hasMore, isFalse);
        expect(newState.isLoadingMore, isTrue);
        expect(newState, equals(originalState));
      });

      test('should update only specified fields in copyWithState', () {
        // Arrange
        final originalBooks = [testBook];
        final newBooks = [testBook2];
        final originalState = FavoritesLoaded(
          favoriteBooks: originalBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );

        // Act
        final newState = originalState.copyWithState(
          favoriteBooks: newBooks,
          isLoadingMore: true,
        );

        // Assert
        expect(newState.favoriteBooks, equals(newBooks));
        expect(newState.currentPage, equals(1)); // Preserved
        expect(newState.hasMore, isTrue); // Preserved
        expect(newState.isLoadingMore, isTrue); // Updated
      });
    });

    group('FavoritesError', () {
      test('should have correct message', () {
        // Arrange
        const errorMessage = 'Test error message';
        const state = FavoritesError(errorMessage);

        // Act & Assert
        expect(state.message, equals(errorMessage));
        expect(state, isA<FavoritesState>());
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const errorMessage = 'Test error message';
        const state1 = FavoritesError(errorMessage);
        const state2 = FavoritesError(errorMessage);

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when messages differ', () {
        // Arrange
        const state1 = FavoritesError('Error 1');
        const state2 = FavoritesError('Error 2');

        // Act & Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('FavoritesRefreshing', () {
      test('should store favorite books correctly', () {
        // Arrange
        final favoriteBooks = [testBook, testBook2];
        final state = FavoritesRefreshing(favoriteBooks);

        // Act & Assert
        expect(state.data, equals(favoriteBooks));
        expect(state, isA<FavoritesState>());
      });

      test('should be equal when books are the same', () {
        // Arrange
        final favoriteBooks = [testBook];
        final state1 = FavoritesRefreshing(favoriteBooks);
        final state2 = FavoritesRefreshing(favoriteBooks);

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when books differ', () {
        // Arrange
        final state1 = FavoritesRefreshing([testBook]);
        final state2 = FavoritesRefreshing([testBook2]);

        // Act & Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should create copy with new data using copyWith', () {
        // Arrange
        final originalBooks = [testBook];
        final newBooks = [testBook2];
        final originalState = FavoritesRefreshing(originalBooks);

        // Act
        final newState = originalState.copyWith(newBooks);

        // Assert
        expect(newState.data, equals(newBooks));
        expect(newState, isA<FavoritesRefreshing>());
      });
    });

    group('State type differentiation', () {
      test('should distinguish between different state types', () {
        // Arrange
        final initial = FavoritesInitial();
        final loading = FavoritesLoading();
        final loaded = FavoritesLoaded(favoriteBooks: [testBook]);
        const error = FavoritesError('Error');
        final refreshing = FavoritesRefreshing([testBook]);

        // Act & Assert
        expect(initial.runtimeType, isNot(equals(loading.runtimeType)));
        expect(initial.runtimeType, isNot(equals(loaded.runtimeType)));
        expect(initial.runtimeType, isNot(equals(error.runtimeType)));
        expect(initial.runtimeType, isNot(equals(refreshing.runtimeType)));
        expect(loading.runtimeType, isNot(equals(loaded.runtimeType)));
        expect(loading.runtimeType, isNot(equals(error.runtimeType)));
        expect(loading.runtimeType, isNot(equals(refreshing.runtimeType)));
        expect(loaded.runtimeType, isNot(equals(error.runtimeType)));
        expect(loaded.runtimeType, isNot(equals(refreshing.runtimeType)));
        expect(error.runtimeType, isNot(equals(refreshing.runtimeType)));

        // All should be FavoritesState
        expect(initial, isA<FavoritesState>());
        expect(loading, isA<FavoritesState>());
        expect(loaded, isA<FavoritesState>());
        expect(error, isA<FavoritesState>());
        expect(refreshing, isA<FavoritesState>());
      });
    });

    group('Edge cases', () {
      test('should handle empty list of books', () {
        // Arrange
        final state = FavoritesLoaded(favoriteBooks: const []);

        // Act & Assert
        expect(state.favoriteBooks, isEmpty);
        expect(state.data, isEmpty);
        expect(state.props, [const [], 1, true, false]);
      });

      test('should handle large list of books', () {
        // Arrange
        final manyBooks = List.generate(100, (index) => testBook.copyWith(
          id: 'book_$index',
          title: 'Book $index',
        ));
        final state = FavoritesLoaded(favoriteBooks: manyBooks);

        // Act & Assert
        expect(state.favoriteBooks.length, equals(100));
        expect(state.data.length, equals(100));
        expect(state.favoriteBooks.first.id, equals('book_0'));
        expect(state.favoriteBooks.last.id, equals('book_99'));
      });

      test('should handle refreshing with empty list', () {
        // Arrange
        final state = FavoritesRefreshing(const []);

        // Act & Assert
        expect(state.data, isEmpty);
      });

      test('should handle error with empty message', () {
        // Arrange
        const state = FavoritesError('');

        // Act & Assert
        expect(state.message, isEmpty);
      });

      test('should handle special characters in error message', () {
        // Arrange
        const specialMessage = 'Error with special chars: !@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        const state = FavoritesError(specialMessage);

        // Act & Assert
        expect(state.message, equals(specialMessage));
      });
    });
  });
}
