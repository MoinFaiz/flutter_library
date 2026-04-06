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
  group('HomeBloc Tests', () {
    late HomeBloc homeBloc;
    late MockGetBooksUseCase mockGetBooksUseCase;
    late MockSearchBooksUseCase mockSearchBooksUseCase;
    late MockToggleFavoriteUseCase mockToggleFavoriteUseCase;
    late MockGetFavoriteIdsUseCase mockGetFavoriteIdsUseCase;

    setUp(() {
      mockGetBooksUseCase = MockGetBooksUseCase();
      mockSearchBooksUseCase = MockSearchBooksUseCase();
      mockToggleFavoriteUseCase = MockToggleFavoriteUseCase();
      mockGetFavoriteIdsUseCase = MockGetFavoriteIdsUseCase();
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

    final mockBooks = [
      Book(
        id: '1',
        title: 'Test Book 1',
        author: 'Test Author',
        description: 'Test Description',
        imageUrls: const ['test_url'],
        rating: 4.5,
        publishedYear: 2023,
        isFavorite: false,
        isFromFriend: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
      ),
    ];

    test('initial state should be HomeInitial', () {
      expect(homeBloc.state, equals(HomeInitial()));
    });

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when LoadBooks succeeds',
      build: () {
        when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => Right(mockBooks),
        );
        return homeBloc;
      },
      act: (bloc) => bloc.add(LoadBooks()),
      expect: () => [
        HomeLoading(),
        HomeLoaded(
          books: mockBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (bloc) {
        verify(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeError] when LoadBooks fails',
      build: () {
        when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return homeBloc;
      },
      act: (bloc) => bloc.add(LoadBooks()),
      expect: () => [
        HomeLoading(),
        const HomeError('Server error'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits search results when SearchBooks succeeds',
      build: () {
        when(() => mockSearchBooksUseCase.call(any())).thenAnswer(
          (_) async => Right(mockBooks),
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const SearchBooks('flutter')),
      expect: () => [
        HomeSearching(mockBooks),
        HomeLoaded(
          books: mockBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
          isSearching: true,
          searchQuery: 'flutter',
        ),
      ],
      verify: (bloc) {
        verify(() => mockSearchBooksUseCase.call(any())).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits original books when ClearSearch is called',
      build: () {
        when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => Right(mockBooks),
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        hasMore: false,
        isLoadingMore: false,
        isSearching: true,
        searchQuery: 'flutter',
      ),
      act: (bloc) => bloc.add(ClearSearch()),
      expect: () => [
        HomeLoaded(
          books: mockBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'toggles favorite successfully',
      build: () {
        when(() => mockToggleFavoriteUseCase.call(any())).thenAnswer(
          (_) async => const Right(true),
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const ToggleFavorite('1')),
      expect: () => [
        HomeLoaded(
          books: [
            mockBooks[0].copyWith(isFavorite: true),
          ],
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (bloc) {
        verify(() => mockToggleFavoriteUseCase.call(any())).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'loads more books when LoadMoreBooks succeeds',
      build: () {
        when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => Right(mockBooks), // Return just new books, not duplicated
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(LoadMoreBooks()),
      expect: () => [
        HomeLoaded(
          books: mockBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: true,
        ),
        HomeLoaded(
          books: [...mockBooks, ...mockBooks], // Original + new
          currentPage: 2,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'refreshes books when RefreshBooks is called',
      build: () {
        when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => Right(mockBooks),
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(RefreshBooks()),
      expect: () => [
        HomeRefreshing(mockBooks),
        HomeLoaded(
          books: mockBooks,
          currentPage: 1,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'calls ClearSearch when SearchBooks with empty query',
      build: () {
        when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => Right(mockBooks),
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        hasMore: false,
        isLoadingMore: false,
        isSearching: true,
        searchQuery: 'flutter',
      ),
      act: (bloc) => bloc.add(const SearchBooks('')),
      expect: () => [
        HomeLoaded(
          books: mockBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits error when toggle favorite fails',
      build: () {
        when(() => mockToggleFavoriteUseCase.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Toggle failed')),
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const ToggleFavorite('1')),
      expect: () => [
        const HomeError('Toggle failed'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'does not load more books when already loading more',
      build: () => homeBloc,
      seed: () => HomeLoaded(
        books: mockBooks,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: true, // Already loading
      ),
      act: (bloc) => bloc.add(LoadMoreBooks()),
      expect: () => [],
      verify: (bloc) {
        verifyNever(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'does not load more books when hasMore is false',
      build: () => homeBloc,
      seed: () => HomeLoaded(
        books: mockBooks,
        currentPage: 1,
        hasMore: false, // No more books
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(LoadMoreBooks()),
      expect: () => [],
      verify: (bloc) {
        verifyNever(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'keeps existing books when load more fails',
      build: () {
        when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'Network error')),
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(LoadMoreBooks()),
      expect: () => [
        HomeLoaded(
          books: mockBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: true,
        ),
        HomeLoaded(
          books: mockBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'does not search when state is not HomeLoaded',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const SearchBooks('flutter')),
      expect: () => [],
    );

    blocTest<HomeBloc, HomeState>(
      'emits error when SearchBooks fails',
      build: () {
        when(() => mockSearchBooksUseCase.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Search failed')),
        );
        return homeBloc;
      },
      seed: () => HomeLoaded(
        books: mockBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const SearchBooks('flutter')),
      expect: () => [
        HomeSearching(mockBooks),
        const HomeError('Search failed'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'does not toggle favorite when state is not HomeLoaded',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const ToggleFavorite('1')),
      expect: () => [],
    );

    blocTest<HomeBloc, HomeState>(
      'does not refresh when state is not HomeLoaded',
      build: () => homeBloc,
      act: (bloc) => bloc.add(RefreshBooks()),
      expect: () => [],
    );
  });
}
