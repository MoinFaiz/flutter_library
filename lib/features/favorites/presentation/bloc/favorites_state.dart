import 'package:flutter_library/core/presentation/base_bloc.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

abstract class FavoritesState extends BaseState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {
  @override
  List<Object> get props => [];
}

class FavoritesLoading extends BaseLoading implements FavoritesState {
  @override
  List<Object> get props => [];
}

class FavoritesLoaded extends BaseDataState<List<Book>> implements FavoritesState {
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  
  const FavoritesLoaded({
    required List<Book> favoriteBooks,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  }) : super(favoriteBooks);
  
  List<Book> get favoriteBooks => data;
  
  @override
  List<Object> get props => [data, currentPage, hasMore, isLoadingMore];
  
  @override
  FavoritesLoaded copyWith(List<Book> newData) {
    return FavoritesLoaded(
      favoriteBooks: newData,
      currentPage: currentPage,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
    );
  }
  
  FavoritesLoaded copyWithState({
    List<Book>? favoriteBooks,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return FavoritesLoaded(
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class FavoritesError extends BaseError implements FavoritesState {
  const FavoritesError(super.message);
}

class FavoritesRefreshing extends BaseDataState<List<Book>> implements FavoritesState {
  const FavoritesRefreshing(super.favoriteBooks);
  
  @override
  FavoritesRefreshing copyWith(List<Book> newData) {
    return FavoritesRefreshing(newData);
  }
}
