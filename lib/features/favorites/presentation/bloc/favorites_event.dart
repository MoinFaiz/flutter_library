import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class LoadMoreFavorites extends FavoritesEvent {}

class RefreshFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final String bookId;
  
  const ToggleFavorite(this.bookId);
  
  @override
  List<Object> get props => [bookId];
}
