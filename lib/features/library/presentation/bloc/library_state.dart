import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

/// States for LibraryBloc
abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LibraryInitial extends LibraryState {}

/// Loading state
class LibraryLoading extends LibraryState {}

/// Loaded state with both borrowed and uploaded books
class LibraryLoaded extends LibraryState {
  final List<Book> borrowedBooks;
  final List<Book> uploadedBooks;
  final bool isRefreshing;

  const LibraryLoaded({
    required this.borrowedBooks,
    required this.uploadedBooks,
    this.isRefreshing = false,
  });

  LibraryLoaded copyWith({
    List<Book>? borrowedBooks,
    List<Book>? uploadedBooks,
    bool? isRefreshing,
  }) {
    return LibraryLoaded(
      borrowedBooks: borrowedBooks ?? this.borrowedBooks,
      uploadedBooks: uploadedBooks ?? this.uploadedBooks,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [borrowedBooks, uploadedBooks, isRefreshing];
}

/// Error state
class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
