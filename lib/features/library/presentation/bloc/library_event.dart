import 'package:equatable/equatable.dart';

/// Events for LibraryBloc
abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Load borrowed books
class LoadBorrowedBooks extends LibraryEvent {
  const LoadBorrowedBooks();
}

/// Load uploaded books
class LoadUploadedBooks extends LibraryEvent {
  const LoadUploadedBooks();
}

/// Refresh library data
class RefreshLibrary extends LibraryEvent {
  const RefreshLibrary();
}
