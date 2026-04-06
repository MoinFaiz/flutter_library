import 'package:equatable/equatable.dart';

/// Events for book details
abstract class BookDetailsEvent extends Equatable {
  const BookDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Load only basic book details (fast loading)
class LoadBookDetails extends BookDetailsEvent {
  final String bookId;

  const LoadBookDetails(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Refresh all data (for pull-to-refresh)
class RefreshBookDetails extends BookDetailsEvent {
  final String bookId;

  const RefreshBookDetails(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Toggle favorite status
class ToggleFavorite extends BookDetailsEvent {
  final String bookId;

  const ToggleFavorite(this.bookId);

  @override
  List<Object?> get props => [bookId];
}