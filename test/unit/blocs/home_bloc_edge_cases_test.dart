import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_event.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_library/features/home/domain/usecases/get_books_usecase.dart';
import 'package:flutter_library/features/home/domain/usecases/search_books_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/get_favorite_ids_usecase.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockGetBooksUseCase extends Mock implements GetBooksUseCase {}
class MockSearchBooksUseCase extends Mock implements SearchBooksUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}
class MockGetFavoriteIdsUseCase extends Mock implements GetFavoriteIdsUseCase {}

void main() {
  group('HomeBloc Edge Cases and Missing Coverage', () {
    late HomeBloc homeBloc;
    late MockGetBooksUseCase mockGetBooksUseCase;
    late MockSearchBooksUseCase mockSearchBooksUseCase;
    late MockToggleFavoriteUseCase mockToggleFavoriteUseCase;
    late MockGetFavoriteIdsUseCase mockGetFavoriteIdsUseCase;

    final mockBook = Book(
      id: '1',
      title: 'Test Book',
      author: 'Test Author',
      description: 'Test Description',
      imageUrls: const ['test.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 24.99,
        rentPrice: 5.99,
      ),
      availability: const BookAvailability(
        totalCopies: 3,
        availableForRentCount: 2,
        availableForSaleCount: 5,
      ),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction'],
        pageCount: 300,
        language: 'English',
      ),
      isFavorite: false,
      isFromFriend: false,
      publishedYear: 2023,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockGetBooksUseCase = MockGetBooksUseCase();
      mockSearchBooksUseCase = MockSearchBooksUseCase();
      mockToggleFavoriteUseCase = MockToggleFavoriteUseCase();
      mockGetFavoriteIdsUseCase = MockGetFavoriteIdsUseCase();
      
      // Setup default successful responses
      when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
        (_) async => const Right([]),
      );
      when(() => mockSearchBooksUseCase.call(any())).thenAnswer(
        (_) async => const Right([]),
      );
      when(() => mockToggleFavoriteUseCase.call(any())).thenAnswer(
        (_) async => const Right(true),
      );
      when(() => mockGetFavoriteIdsUseCase.call(any()))
          .thenAnswer((_) async => const Right(<String>{}));
      
      homeBloc = HomeBloc(
        getBooksUseCase: mockGetBooksUseCase,
        searchBooksUseCase: mockSearchBooksUseCase,
        toggleFavoriteUseCase: mockToggleFavoriteUseCase,
        getFavoriteIdsUseCase: mockGetFavoriteIdsUseCase,
      );
    });

    tearDown(() {
      homeBloc.close();
    });

    group('LoadMoreBooks Edge Cases', () {
      blocTest<HomeBloc, HomeState>(
        'does nothing when state is not HomeLoaded',
        build: () => homeBloc,
        act: (bloc) => bloc.add(LoadMoreBooks()),
        expect: () => [],
      );

      blocTest<HomeBloc, HomeState>(
        'does nothing when already loading more',
        build: () => homeBloc,
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: true,
          isLoadingMore: true,
        ),
        act: (bloc) => bloc.add(LoadMoreBooks()),
        expect: () => [],
      );

      blocTest<HomeBloc, HomeState>(
        'does nothing when no more books available',
        build: () => homeBloc,
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: false,
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(LoadMoreBooks()),
        expect: () => [],
      );

      blocTest<HomeBloc, HomeState>(
        'handles error during load more and preserves existing books',
        build: () {
          when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return homeBloc;
        },
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: true,
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(LoadMoreBooks()),
        expect: () => [
          HomeLoaded(
            books: [mockBook],
            hasMore: true,
            isLoadingMore: true,
          ),
          HomeLoaded(
            books: [mockBook],
            hasMore: true,
            isLoadingMore: false,
          ),
        ],
      );
    });

    group('ToggleFavorite Edge Cases', () {
      blocTest<HomeBloc, HomeState>(
        'does nothing when state is not HomeLoaded',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const ToggleFavorite('1')),
        expect: () => [],
      );

      blocTest<HomeBloc, HomeState>(
        'does nothing when book is not found',
        build: () => homeBloc,
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: false,
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(const ToggleFavorite('non-existent-id')),
        expect: () => [],
      );

      blocTest<HomeBloc, HomeState>(
        'handles toggle favorite failure gracefully',
        build: () {
          when(() => mockToggleFavoriteUseCase.call(any()))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return homeBloc;
        },
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: false,
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(const ToggleFavorite('1')),
        expect: () => [
          const HomeError('Server error occurred'),
        ],
        verify: (bloc) {
          verify(() => mockToggleFavoriteUseCase.call(any())).called(1);
        },
      );
    });

    group('SearchBooks Edge Cases', () {
      blocTest<HomeBloc, HomeState>(
        'handles empty search query',
        build: () {
          when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')))
              .thenAnswer((_) async => const Right([]));
          return homeBloc;
        },
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: false,
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(const SearchBooks('')),
        expect: () => [
          HomeLoaded(
            books: [],
            hasMore: false,
            isLoadingMore: false,
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'handles search with very long query',
        build: () {
          final longQuery = 'a' * 1000;
          when(() => mockSearchBooksUseCase.call(longQuery))
              .thenAnswer((_) async => const Right([]));
          return homeBloc;
        },
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: false,
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(SearchBooks('a' * 1000)),
        expect: () => [
          HomeSearching([mockBook]),
          HomeLoaded(
            books: [],
            hasMore: true,
            isLoadingMore: false,
            isSearching: true,
            searchQuery: 'a' * 1000,
          ),
        ],
      );
    });

    group('ClearSearch Edge Cases', () {
      blocTest<HomeBloc, HomeState>(
        'does nothing when not searching',
        build: () => homeBloc,
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: false,
          isLoadingMore: false,
        ),
        act: (bloc) => bloc.add(ClearSearch()),
        expect: () => [
          HomeLoaded(
            books: [],
            hasMore: false,
            isLoadingMore: false,
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'handles error when reloading books after clear search',
        build: () {
          when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')))
              .thenAnswer((_) async => const Left(NetworkFailure()));
          return homeBloc;
        },
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: false,
          isLoadingMore: false,
          isSearching: true,
          searchQuery: 'test',
        ),
        act: (bloc) => bloc.add(ClearSearch()),
        expect: () => [
          const HomeError('No internet connection'),
        ],
      );
    });

    group('Concurrent Operations', () {
      blocTest<HomeBloc, HomeState>(
        'handles multiple rapid search requests',
        build: () {
          when(() => mockSearchBooksUseCase.call('query1'))
              .thenAnswer((_) async => Right([mockBook]));
          when(() => mockSearchBooksUseCase.call('query2'))
              .thenAnswer((_) async => Right([]));
          return homeBloc;
        },
        seed: () => HomeLoaded(
          books: [mockBook],
          hasMore: false,
          isLoadingMore: false,
        ),
        act: (bloc) async {
          bloc.add(const SearchBooks('query1'));
          bloc.add(const SearchBooks('query2'));
        },
        expect: () => [
          HomeSearching([mockBook]),
          HomeLoaded(
            books: [mockBook],
            hasMore: true,
            isLoadingMore: false,
            isSearching: true,
            searchQuery: 'query1',
          ),
          HomeSearching([mockBook]),
          HomeLoaded(
            books: [],
            hasMore: true,
            isLoadingMore: false,
            isSearching: true,
            searchQuery: 'query2',
          ),
        ],
      );
    });
  });
}
