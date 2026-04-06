import 'package:flutter_library/core/presentation/base_bloc.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

abstract class HomeState extends BaseState {
  const HomeState();
}

class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoading extends BaseLoading implements HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoaded extends BaseDataState<List<Book>> implements HomeState {
  final bool isSearching;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  
  const HomeLoaded({
    required List<Book> books,
    this.isSearching = false,
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  }) : super(books);
  
  List<Book> get books => data;
  
  @override
  List<Object> get props => [data, isSearching, searchQuery, currentPage, hasMore, isLoadingMore];
  
  @override
  HomeLoaded copyWith(List<Book> newData) {
    return HomeLoaded(
      books: newData,
      isSearching: isSearching,
      searchQuery: searchQuery,
      currentPage: currentPage,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
    );
  }
  
  HomeLoaded copyWithState({
    List<Book>? books,
    bool? isSearching,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeLoaded(
      books: books ?? this.books,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HomeError extends BaseError implements HomeState {
  const HomeError(super.message);
}

class HomeRefreshing extends BaseDataState<List<Book>> implements HomeState {
  const HomeRefreshing(super.books);
  
  @override
  HomeRefreshing copyWith(List<Book> newData) {
    return HomeRefreshing(newData);
  }
}

class HomeSearching extends BaseDataState<List<Book>> implements HomeState {
  const HomeSearching(super.previousBooks);
  
  @override
  HomeSearching copyWith(List<Book> newData) {
    return HomeSearching(newData);
  }
}
