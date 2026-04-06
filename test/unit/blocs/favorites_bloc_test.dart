import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:flutter_library/features/favorites/domain/usecases/get_favorite_books_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockGetFavoriteBooksUseCase extends Mock implements GetFavoriteBooksUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}

void main() {
  group('FavoritesBloc Tests', () {
    late FavoritesBloc favoritesBloc;
    late MockGetFavoriteBooksUseCase mockGetFavoriteBooksUseCase;
    late MockToggleFavoriteUseCase mockToggleFavoriteUseCase;

    setUp(() {
      mockGetFavoriteBooksUseCase = MockGetFavoriteBooksUseCase();
      mockToggleFavoriteUseCase = MockToggleFavoriteUseCase();
      
      favoritesBloc = FavoritesBloc(
        getFavoriteBooksUseCase: mockGetFavoriteBooksUseCase,
        toggleFavoriteUseCase: mockToggleFavoriteUseCase,
      );
    });

    tearDown(() {
      favoritesBloc.close();
    });

    final mockFavoriteBooks = [
      Book(
        id: '1',
        title: 'Favorite Book 1',
        author: 'Author 1',
        description: 'Description 1',
        imageUrls: const ['image1.jpg'],
        rating: 4.5,
        publishedYear: 2023,
        isFavorite: true,
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
          salePrice: 24.99,
          rentPrice: 5.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 3,
          availableForSaleCount: 2,
          totalCopies: 5,
        ),
      ),
    ];

    blocTest<FavoritesBloc, FavoritesState>(
      'does not change state when ToggleFavorite succeeds and book is still favorite',
      build: () {
        when(() => mockToggleFavoriteUseCase.call('1')).thenAnswer(
          (_) async => const Right(true),
        );
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favoriteBooks: mockFavoriteBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const ToggleFavorite('1')),
      expect: () => [],
    );

    test('initial state should be FavoritesInitial', () {
      expect(favoritesBloc.state, equals(FavoritesInitial()));
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesLoaded] when LoadFavorites succeeds',
      build: () {
        when(() => mockGetFavoriteBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => Right(mockFavoriteBooks),
        );
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(LoadFavorites()),
      expect: () => [
        FavoritesLoading(),
        FavoritesLoaded(
          favoriteBooks: mockFavoriteBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (bloc) {
        verify(() => mockGetFavoriteBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesError] when LoadFavorites fails',
      build: () {
        when(() => mockGetFavoriteBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(LoadFavorites()),
      expect: () => [
        FavoritesLoading(),
        const FavoritesError('Server error'),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'removes book from favorites when ToggleFavorite succeeds',
      build: () {
        when(() => mockToggleFavoriteUseCase.call(any())).thenAnswer(
          (_) async => const Right(false),
        );
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favoriteBooks: mockFavoriteBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const ToggleFavorite('1')),
      expect: () => [
        const FavoritesLoaded(
          favoriteBooks: [],
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (bloc) {
        verify(() => mockToggleFavoriteUseCase.call('1')).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'loads more favorites when LoadMoreFavorites succeeds',
      build: () {
        when(() => mockGetFavoriteBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => Right(mockFavoriteBooks),
        );
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favoriteBooks: mockFavoriteBooks,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(LoadMoreFavorites()),
      expect: () => [
        FavoritesLoaded(
          favoriteBooks: mockFavoriteBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: true,
        ),
        FavoritesLoaded(
          favoriteBooks: [...mockFavoriteBooks, ...mockFavoriteBooks],
          currentPage: 2,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'refreshes favorites when RefreshFavorites is called',
      build: () {
        when(() => mockGetFavoriteBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer(
          (_) async => Right(mockFavoriteBooks),
        );
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favoriteBooks: mockFavoriteBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(RefreshFavorites()),
      expect: () => [
        FavoritesLoading(),
        FavoritesLoaded(
          favoriteBooks: mockFavoriteBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'handles toggle favorite error gracefully',
      build: () {
        when(() => mockToggleFavoriteUseCase.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Toggle failed')),
        );
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favoriteBooks: mockFavoriteBooks,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const ToggleFavorite('1')),
      expect: () => [
        const FavoritesError('Toggle failed'),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'does nothing when ToggleFavorite is called and state is not FavoritesLoaded',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(const ToggleFavorite('1')),
      expect: () => [],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'does nothing when LoadMoreFavorites is called and state is not FavoritesLoaded',
      build: () => favoritesBloc,
      act: (bloc) => bloc.add(LoadMoreFavorites()),
      expect: () => [],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits [FavoritesLoading, FavoritesLoaded([])] when RefreshFavorites is called and state is not FavoritesLoaded',
      build: () {
        when(() => mockGetFavoriteBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')))
            .thenAnswer((_) async => Right([]));
        return favoritesBloc;
      },
      act: (bloc) => bloc.add(RefreshFavorites()),
      expect: () => [
        FavoritesLoading(),
        FavoritesLoaded(
          favoriteBooks: [],
          currentPage: 1,
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
    );

    // --- ADDITIONAL EDGE CASES FOR LoadMoreFavorites ---
    blocTest<FavoritesBloc, FavoritesState>(
      'does nothing when LoadMoreFavorites is called and isLoadingMore is true',
      build: () => favoritesBloc,
      seed: () => FavoritesLoaded(
        favoriteBooks: mockFavoriteBooks,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: true,
      ),
      act: (bloc) => bloc.add(LoadMoreFavorites()),
      expect: () => [],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'does nothing when LoadMoreFavorites is called and hasMore is false',
      build: () => favoritesBloc,
      seed: () => FavoritesLoaded(
        favoriteBooks: mockFavoriteBooks,
        currentPage: 1,
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(LoadMoreFavorites()),
      expect: () => [],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'sets isLoadingMore to false when LoadMoreFavorites fails',
      build: () {
        when(() => mockGetFavoriteBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'Load more failed')));
        return favoritesBloc;
      },
      seed: () => FavoritesLoaded(
        favoriteBooks: mockFavoriteBooks,
        currentPage: 1,
        hasMore: true,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(LoadMoreFavorites()),
      expect: () => [
        FavoritesLoaded(
          favoriteBooks: mockFavoriteBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: true,
        ),
        FavoritesLoaded(
          favoriteBooks: mockFavoriteBooks,
          currentPage: 1,
          hasMore: true,
          isLoadingMore: false,
        ),
      ],
    );
  });
}
