import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadBooks extends HomeEvent {}

class LoadMoreBooks extends HomeEvent {}

class SearchBooks extends HomeEvent {
  final String query;
  
  const SearchBooks(this.query);
  
  @override
  List<Object> get props => [query];
}

class ToggleFavorite extends HomeEvent {
  final String bookId;
  
  const ToggleFavorite(this.bookId);
  
  @override
  List<Object> get props => [bookId];
}

class RefreshBooks extends HomeEvent {}

class ClearSearch extends HomeEvent {}

class SyncFavoriteIds extends HomeEvent {}
