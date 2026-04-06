import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/presentation/base_bloc.dart';
import 'package:flutter_library/features/favorites/domain/usecases/get_favorite_books_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState>
    with BlocResultHandler<FavoritesState> {
  final GetFavoriteBooksUseCase getFavoriteBooksUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesBloc({
    required this.getFavoriteBooksUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<LoadMoreFavorites>(_onLoadMoreFavorites);
    on<RefreshFavorites>(_onRefreshFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    await executeWithLoading(
      () => getFavoriteBooksUseCase(page: 1, limit: 20),
      emit,
      FavoritesLoading(),
      (books) => FavoritesLoaded(
        favoriteBooks: books,
        currentPage: 1,
        hasMore: books.length >= 20,
      ),
      (error) => FavoritesError(error),
    );
  }

  Future<void> _onLoadMoreFavorites(
    LoadMoreFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded &&
        !currentState.isLoadingMore &&
        currentState.hasMore) {
      final nextPage = currentState.currentPage + 1;

      // Set loading more state
      emit(currentState.copyWithState(isLoadingMore: true));

      final result = await getFavoriteBooksUseCase(page: nextPage, limit: 20);

      result.fold(
        (failure) {
          // On error, remove loading state but keep existing books
          emit(currentState.copyWithState(isLoadingMore: false));
        },
        (newBooks) {
          // Append new books to existing ones
          final allBooks = [...currentState.favoriteBooks, ...newBooks];
          emit(
            FavoritesLoaded(
              favoriteBooks: allBooks,
              currentPage: nextPage,
              hasMore: newBooks.length >= 20,
            ),
          );
        },
      );
    }
  }

  Future<void> _onRefreshFavorites(
    RefreshFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    await executeWithLoading(
      () => getFavoriteBooksUseCase(page: 1, limit: 20),
      emit,
      FavoritesLoading(),
      (books) => FavoritesLoaded(
        favoriteBooks: books,
        currentPage: 1,
        hasMore: books.length >= 20,
      ),
      (error) => FavoritesError(error),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final result = await toggleFavoriteUseCase(event.bookId);

      result.fold(
        (failure) => emit(FavoritesError(failure.message)),
        (isFavorite) {
          if (!isFavorite) {
            // Book was removed from favorites — remove from the displayed list
            final updatedBooks = currentState.favoriteBooks
                .where((book) => book.id != event.bookId)
                .toList();
            emit(currentState.copyWithState(favoriteBooks: updatedBooks));
          }
          // If added (isFavorite == true) the list already contains the book — no-op
        },
      );
    }
  }
}
