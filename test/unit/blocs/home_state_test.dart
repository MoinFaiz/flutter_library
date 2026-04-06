import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('HomeState', () {
    final testBook = Book(
      id: '1',
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

    group('HomeInitial', () {
      test('should have empty props', () {
        // Arrange
        final state = HomeInitial();

        // Act & Assert
        expect(state.props, isEmpty);
        expect(state, isA<HomeState>());
      });

      test('should be equal to another HomeInitial', () {
        // Arrange
        final state1 = HomeInitial();
        final state2 = HomeInitial();

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('HomeLoading', () {
      test('should have empty props', () {
        // Arrange
        final state = HomeLoading();

        // Act & Assert
        expect(state.props, isEmpty);
        expect(state, isA<HomeState>());
      });

      test('should be equal to another HomeLoading', () {
        // Arrange
        final state1 = HomeLoading();
        final state2 = HomeLoading();

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });
    });

    group('HomeLoaded', () {
      test('should have correct props with default values', () {
        // Arrange
        final books = [testBook];
        final state = HomeLoaded(books: books);

        // Act & Assert
        expect(state.props, [books, false, '', 1, true, false]);
        expect(state.books, equals(books));
        expect(state.data, equals(books));
        expect(state.isSearching, isFalse);
        expect(state.searchQuery, equals(''));
        expect(state.currentPage, equals(1));
        expect(state.hasMore, isTrue);
        expect(state.isLoadingMore, isFalse);
        expect(state, isA<HomeState>());
      });

      test('should have correct props with custom values', () {
        // Arrange
        final books = [testBook, testBook2];
        final state = HomeLoaded(
          books: books,
          isSearching: true,
          searchQuery: 'test query',
          currentPage: 2,
          hasMore: false,
          isLoadingMore: true,
        );

        // Act & Assert
        expect(state.props, [books, true, 'test query', 2, false, true]);
        expect(state.books, equals(books));
        expect(state.isSearching, isTrue);
        expect(state.searchQuery, equals('test query'));
        expect(state.currentPage, equals(2));
        expect(state.hasMore, isFalse);
        expect(state.isLoadingMore, isTrue);
      });

      test('should be equal when all properties are the same', () {
        // Arrange
        final books = [testBook];
        final state1 = HomeLoaded(
          books: books,
          isSearching: true,
          searchQuery: 'test',
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );
        final state2 = HomeLoaded(
          books: books,
          isSearching: true,
          searchQuery: 'test',
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
        final books = [testBook];
        final state1 = HomeLoaded(
          books: books,
          isSearching: true,
          searchQuery: 'test',
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );
        final state2 = HomeLoaded(
          books: books,
          isSearching: false,
          searchQuery: 'test',
          currentPage: 1,
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
        final originalState = HomeLoaded(
          books: originalBooks,
          isSearching: true,
          searchQuery: 'test',
          currentPage: 2,
          hasMore: false,
          isLoadingMore: true,
        );

        // Act
        final newState = originalState.copyWith(newBooks);

        // Assert
        expect(newState.books, equals(newBooks));
        expect(newState.isSearching, isTrue); // Should preserve other properties
        expect(newState.searchQuery, equals('test'));
        expect(newState.currentPage, equals(2));
        expect(newState.hasMore, isFalse);
        expect(newState.isLoadingMore, isTrue);
      });

      test('should create copy with state changes using copyWithState', () {
        // Arrange
        final originalBooks = [testBook];
        final originalState = HomeLoaded(
          books: originalBooks,
          isSearching: false,
          searchQuery: '',
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );

        // Act
        final newState = originalState.copyWithState(
          isSearching: true,
          searchQuery: 'new query',
          currentPage: 2,
          hasMore: false,
          isLoadingMore: true,
        );

        // Assert
        expect(newState.books, equals(originalBooks)); // Should preserve
        expect(newState.isSearching, isTrue);
        expect(newState.searchQuery, equals('new query'));
        expect(newState.currentPage, equals(2));
        expect(newState.hasMore, isFalse);
        expect(newState.isLoadingMore, isTrue);
      });

      test('should preserve original values when copyWithState called with nulls', () {
        // Arrange
        final originalBooks = [testBook];
        final originalState = HomeLoaded(
          books: originalBooks,
          isSearching: true,
          searchQuery: 'test query',
          currentPage: 2,
          hasMore: false,
          isLoadingMore: true,
        );

        // Act
        final newState = originalState.copyWithState();

        // Assert
        expect(newState.books, equals(originalBooks));
        expect(newState.isSearching, isTrue);
        expect(newState.searchQuery, equals('test query'));
        expect(newState.currentPage, equals(2));
        expect(newState.hasMore, isFalse);
        expect(newState.isLoadingMore, isTrue);
        expect(newState, equals(originalState));
      });

      test('should update only specified fields in copyWithState', () {
        // Arrange
        final originalBooks = [testBook];
        final newBooks = [testBook2];
        final originalState = HomeLoaded(
          books: originalBooks,
          isSearching: false,
          searchQuery: '',
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        );

        // Act
        final newState = originalState.copyWithState(
          books: newBooks,
          searchQuery: 'new query',
          isLoadingMore: true,
        );

        // Assert
        expect(newState.books, equals(newBooks));
        expect(newState.isSearching, isFalse); // Preserved
        expect(newState.searchQuery, equals('new query'));
        expect(newState.currentPage, equals(1)); // Preserved
        expect(newState.hasMore, isTrue); // Preserved
        expect(newState.isLoadingMore, isTrue); // Updated
      });
    });

    group('HomeError', () {
      test('should have correct message', () {
        // Arrange
        const errorMessage = 'Test error message';
        const state = HomeError(errorMessage);

        // Act & Assert
        expect(state.message, equals(errorMessage));
        expect(state, isA<HomeState>());
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const errorMessage = 'Test error message';
        const state1 = HomeError(errorMessage);
        const state2 = HomeError(errorMessage);

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when messages differ', () {
        // Arrange
        const state1 = HomeError('Error 1');
        const state2 = HomeError('Error 2');

        // Act & Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('HomeRefreshing', () {
      test('should store books correctly', () {
        // Arrange
        final books = [testBook, testBook2];
        final state = HomeRefreshing(books);

        // Act & Assert
        expect(state.data, equals(books));
        expect(state, isA<HomeState>());
      });

      test('should be equal when books are the same', () {
        // Arrange
        final books = [testBook];
        final state1 = HomeRefreshing(books);
        final state2 = HomeRefreshing(books);

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when books differ', () {
        // Arrange
        final state1 = HomeRefreshing([testBook]);
        final state2 = HomeRefreshing([testBook2]);

        // Act & Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should create copy with new data using copyWith', () {
        // Arrange
        final originalBooks = [testBook];
        final newBooks = [testBook2];
        final originalState = HomeRefreshing(originalBooks);

        // Act
        final newState = originalState.copyWith(newBooks);

        // Assert
        expect(newState.data, equals(newBooks));
        expect(newState, isA<HomeRefreshing>());
      });
    });

    group('HomeSearching', () {
      test('should store previous books correctly', () {
        // Arrange
        final previousBooks = [testBook, testBook2];
        final state = HomeSearching(previousBooks);

        // Act & Assert
        expect(state.data, equals(previousBooks));
        expect(state, isA<HomeState>());
      });

      test('should be equal when books are the same', () {
        // Arrange
        final books = [testBook];
        final state1 = HomeSearching(books);
        final state2 = HomeSearching(books);

        // Act & Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when books differ', () {
        // Arrange
        final state1 = HomeSearching([testBook]);
        final state2 = HomeSearching([testBook2]);

        // Act & Assert
        expect(state1, isNot(equals(state2)));
      });

      test('should create copy with new data using copyWith', () {
        // Arrange
        final originalBooks = [testBook];
        final newBooks = [testBook2];
        final originalState = HomeSearching(originalBooks);

        // Act
        final newState = originalState.copyWith(newBooks);

        // Assert
        expect(newState.data, equals(newBooks));
        expect(newState, isA<HomeSearching>());
      });
    });

    group('State type differentiation', () {
      test('should distinguish between different state types', () {
        // Arrange
        final initial = HomeInitial();
        final loading = HomeLoading();
        final loaded = HomeLoaded(books: [testBook]);
        const error = HomeError('Error');
        final refreshing = HomeRefreshing([testBook]);
        final searching = HomeSearching([testBook]);

        // Act & Assert
        expect(initial.runtimeType, isNot(equals(loading.runtimeType)));
        expect(initial.runtimeType, isNot(equals(loaded.runtimeType)));
        expect(initial.runtimeType, isNot(equals(error.runtimeType)));
        expect(initial.runtimeType, isNot(equals(refreshing.runtimeType)));
        expect(initial.runtimeType, isNot(equals(searching.runtimeType)));
        expect(loading.runtimeType, isNot(equals(loaded.runtimeType)));
        expect(loading.runtimeType, isNot(equals(error.runtimeType)));
        expect(loading.runtimeType, isNot(equals(refreshing.runtimeType)));
        expect(loading.runtimeType, isNot(equals(searching.runtimeType)));
        expect(loaded.runtimeType, isNot(equals(error.runtimeType)));
        expect(loaded.runtimeType, isNot(equals(refreshing.runtimeType)));
        expect(loaded.runtimeType, isNot(equals(searching.runtimeType)));
        expect(error.runtimeType, isNot(equals(refreshing.runtimeType)));
        expect(error.runtimeType, isNot(equals(searching.runtimeType)));
        expect(refreshing.runtimeType, isNot(equals(searching.runtimeType)));

        // All should be HomeState
        expect(initial, isA<HomeState>());
        expect(loading, isA<HomeState>());
        expect(loaded, isA<HomeState>());
        expect(error, isA<HomeState>());
        expect(refreshing, isA<HomeState>());
        expect(searching, isA<HomeState>());
      });
    });

    group('Edge cases', () {
      test('should handle empty list of books', () {
        // Arrange
        final state = HomeLoaded(books: const []);

        // Act & Assert
        expect(state.books, isEmpty);
        expect(state.data, isEmpty);
        expect(state.props, [const [], false, '', 1, true, false]);
      });

      test('should handle large list of books', () {
        // Arrange
        final manyBooks = List.generate(100, (index) => testBook.copyWith(
          id: 'book_$index',
          title: 'Book $index',
        ));
        final state = HomeLoaded(books: manyBooks);

        // Act & Assert
        expect(state.books.length, equals(100));
        expect(state.data.length, equals(100));
        expect(state.books.first.id, equals('book_0'));
        expect(state.books.last.id, equals('book_99'));
      });

      test('should handle special characters in search query', () {
        // Arrange
        const specialQuery = 'Query with special chars: !@#\$%^&*()_+{}[]|\\:";\'<>?,./-~`';
        final state = HomeLoaded(
          books: [testBook],
          searchQuery: specialQuery,
        );

        // Act & Assert
        expect(state.searchQuery, equals(specialQuery));
      });

      test('should handle empty search query', () {
        // Arrange
        final state = HomeLoaded(
          books: [testBook],
          isSearching: true,
          searchQuery: '',
        );

        // Act & Assert
        expect(state.searchQuery, isEmpty);
        expect(state.isSearching, isTrue);
      });

      test('should handle refreshing with empty list', () {
        // Arrange
        final state = HomeRefreshing(const []);

        // Act & Assert
        expect(state.data, isEmpty);
      });

      test('should handle searching with empty list', () {
        // Arrange
        final state = HomeSearching(const []);

        // Act & Assert
        expect(state.data, isEmpty);
      });

      test('should handle error with empty message', () {
        // Arrange
        const state = HomeError('');

        // Act & Assert
        expect(state.message, isEmpty);
      });

      test('should handle very long search query', () {
        // Arrange
        final longQuery = 'a' * 1000;
        final state = HomeLoaded(
          books: [testBook],
          searchQuery: longQuery,
        );

        // Act & Assert
        expect(state.searchQuery.length, equals(1000));
        expect(state.searchQuery, equals(longQuery));
      });

      test('should handle negative page numbers', () {
        // Arrange
        final state = HomeLoaded(
          books: [testBook],
          currentPage: -1,
        );

        // Act & Assert
        expect(state.currentPage, equals(-1));
      });

      test('should handle very large page numbers', () {
        // Arrange
        final state = HomeLoaded(
          books: [testBook],
          currentPage: 999999,
        );

        // Act & Assert
        expect(state.currentPage, equals(999999));
      });
    });
  });
}
