import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/presentation/base_bloc.dart';
import 'package:flutter_library/features/favorites/domain/usecases/get_favorite_ids_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_library/features/home/domain/usecases/get_books_usecase.dart';
import 'package:flutter_library/features/home/domain/usecases/search_books_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> with BlocResultHandler<HomeState> {
  final GetBooksUseCase getBooksUseCase;
  final SearchBooksUseCase searchBooksUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final GetFavoriteIdsUseCase getFavoriteIdsUseCase;

  HomeBloc({
    required this.getBooksUseCase,
    required this.searchBooksUseCase,
    required this.toggleFavoriteUseCase,
    required this.getFavoriteIdsUseCase,
  }) : super(HomeInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<LoadMoreBooks>(_onLoadMoreBooks);
    on<SearchBooks>(_onSearchBooks);
    on<ToggleFavorite>(_onToggleFavorite);
    on<RefreshBooks>(_onRefreshBooks);
    on<ClearSearch>(_onClearSearch);
    on<SyncFavoriteIds>(_onSyncFavoriteIds);
  }

  /// Runs getFavoriteIdsUseCase and returns the set, defaulting to empty on failure.
  Future<Set<String>> _loadFavoriteIds() async {
    final result = await getFavoriteIdsUseCase();
    return result.fold((_) => <String>{}, (ids) => ids);
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    final booksResult = await getBooksUseCase(page: 1, limit: 20);

    await booksResult.fold(
      (failure) async => emit(HomeError(failure.message)),
      (books) async {
        final favoriteIds = await _loadFavoriteIds();
        final enriched =
            books.map((b) => b.copyWith(isFavorite: favoriteIds.contains(b.id))).toList();
        emit(HomeLoaded(books: enriched, currentPage: 1, hasMore: books.length >= 20));
      },
    );
  }

  Future<void> _onLoadMoreBooks(LoadMoreBooks event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded &&
        !currentState.isLoadingMore &&
        currentState.hasMore) {
      final nextPage = currentState.currentPage + 1;
      emit(currentState.copyWithState(isLoadingMore: true));

      final result = await getBooksUseCase(page: nextPage, limit: 20);

      await result.fold(
        (failure) async => emit(currentState.copyWithState(isLoadingMore: false)),
        (newBooks) async {
          final favoriteIds = await _loadFavoriteIds();
          final enriched =
              newBooks.map((b) => b.copyWith(isFavorite: favoriteIds.contains(b.id))).toList();
          final allBooks = [...currentState.books, ...enriched];
          emit(HomeLoaded(
            books: allBooks,
            currentPage: nextPage,
            hasMore: newBooks.length >= 20,
            isSearching: currentState.isSearching,
            searchQuery: currentState.searchQuery,
          ));
        },
      );
    }
  }

  Future<void> _onSearchBooks(SearchBooks event, Emitter<HomeState> emit) async {
    if (event.query.isEmpty) {
      add(ClearSearch());
      return;
    }

    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(HomeSearching(currentState.books));

      final result = await searchBooksUseCase(event.query);

      await result.fold(
        (failure) async => emit(HomeError(failure.message)),
        (books) async {
          final favoriteIds = await _loadFavoriteIds();
          final enriched =
              books.map((b) => b.copyWith(isFavorite: favoriteIds.contains(b.id))).toList();
          emit(HomeLoaded(
            books: enriched,
            currentPage: 1,
            hasMore: false,
            isSearching: true,
            searchQuery: event.query,
          ));
        },
      );
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final result = await toggleFavoriteUseCase(event.bookId);

      result.fold(
        (failure) => emit(HomeError(failure.message)),
        (isFavorite) {
          final updatedBooks = currentState.books.map((book) {
            if (book.id == event.bookId) {
              return book.copyWith(isFavorite: isFavorite);
            }
            return book;
          }).toList();
          emit(currentState.copyWithState(books: updatedBooks));
        },
      );
    }
  }

  Future<void> _onRefreshBooks(RefreshBooks event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(HomeRefreshing(currentState.books));

      final booksResult = await getBooksUseCase(page: 1, limit: 20);

      await booksResult.fold(
        (failure) async => emit(HomeError(failure.message)),
        (books) async {
          final favoriteIds = await _loadFavoriteIds();
          final enriched =
              books.map((b) => b.copyWith(isFavorite: favoriteIds.contains(b.id))).toList();
          emit(HomeLoaded(books: enriched, currentPage: 1, hasMore: books.length >= 20));
        },
      );
    }
  }

  Future<void> _onClearSearch(ClearSearch event, Emitter<HomeState> emit) async {
    final booksResult = await getBooksUseCase(page: 1, limit: 20);

    await booksResult.fold(
      (failure) async => emit(HomeError(failure.message)),
      (books) async {
        final favoriteIds = await _loadFavoriteIds();
        final enriched =
            books.map((b) => b.copyWith(isFavorite: favoriteIds.contains(b.id))).toList();
        emit(HomeLoaded(books: enriched, currentPage: 1, hasMore: books.length >= 20));
      },
    );
  }

  Future<void> _onSyncFavoriteIds(
    SyncFavoriteIds event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final favoriteIds = await _loadFavoriteIds();
      final updatedBooks = currentState.books
          .map((b) => b.copyWith(isFavorite: favoriteIds.contains(b.id)))
          .toList();
      emit(currentState.copyWithState(books: updatedBooks));
    }
  }
}