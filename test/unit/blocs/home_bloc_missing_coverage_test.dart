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
import 'package:flutter_library/core/error/failures.dart';

class MockGetBooksUseCase extends Mock implements GetBooksUseCase {}
class MockSearchBooksUseCase extends Mock implements SearchBooksUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}
class MockGetFavoriteIdsUseCase extends Mock implements GetFavoriteIdsUseCase {}

void main() {
  group('HomeBloc - missing coverage/edge cases', () {
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

    tearDown(() => homeBloc.close());

    test('onSearchBooks does nothing if state is not HomeLoaded and query is not empty', () async {
      when(() => mockSearchBooksUseCase.call(any())).thenAnswer((_) async => const Right([]));
      homeBloc.add(const SearchBooks('not-empty'));
      await expectLater(homeBloc.stream, emitsInOrder([]));
    });

    test('onRefreshBooks does nothing if state is not HomeLoaded', () async {
      when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer((_) async => const Right([]));
      homeBloc.add(RefreshBooks());
      await expectLater(homeBloc.stream, emitsInOrder([]));
    });

    test('onClearSearch emits error if getBooksUseCase fails and state is not HomeLoaded', () async {
      when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit'))).thenAnswer((_) async => const Left(ServerFailure(message: 'fail')));
      homeBloc.add(ClearSearch());
      await expectLater(
        homeBloc.stream,
        emitsInOrder([
          const HomeError('fail'),
        ]),
      );
    });

    test('onClearSearch emits error if getBooksUseCase fails and state is HomeLoaded', () async {
      when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'fail')));
      // Set state to HomeLoaded
      homeBloc.emit(HomeLoaded(books: const [], hasMore: false));
      await Future.delayed(Duration.zero); // allow state to update
      homeBloc.add(ClearSearch());
      await expectLater(
        homeBloc.stream,
        emitsInOrder([
          const HomeError('fail'),
        ]),
      );
    });

    test('onRefreshBooks emits error if getBooksUseCase fails and state is HomeLoaded', () async {
      when(() => mockGetBooksUseCase.call(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'fail')));
      homeBloc.emit(HomeLoaded(books: const [], hasMore: false));
      await Future.delayed(Duration.zero);
      homeBloc.add(RefreshBooks());
      await expectLater(
        homeBloc.stream,
        emitsInOrder([
          isA<HomeRefreshing>(),
          const HomeError('fail'),
        ]),
      );
    });

    test('onSearchBooks emits error if searchBooksUseCase fails and state is HomeLoaded', () async {
      when(() => mockSearchBooksUseCase.call(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'fail')));
      homeBloc.emit(HomeLoaded(books: const [], hasMore: false));
      await Future.delayed(Duration.zero);
      homeBloc.add(const SearchBooks('query'));
      await expectLater(
        homeBloc.stream,
        emitsInOrder([
          isA<HomeSearching>(),
          const HomeError('fail'),
        ]),
      );
    });

    test('onToggleFavorite emits error if toggleFavoriteUseCase fails and state is HomeLoaded', () async {
      when(() => mockToggleFavoriteUseCase.call(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'fail')));
      homeBloc.emit(HomeLoaded(books: const [], hasMore: false));
      await Future.delayed(Duration.zero);
      homeBloc.add(const ToggleFavorite('id'));
      await expectLater(
        homeBloc.stream,
        emitsInOrder([
          const HomeError('fail'),
        ]),
      );
    });
  });
}
