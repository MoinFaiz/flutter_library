import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/library/domain/usecases/get_borrowed_books_usecase.dart';
import 'package:flutter_library/features/library/domain/usecases/get_uploaded_books_usecase.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_event.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_state.dart';

/// BLoC for managing library state
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetBorrowedBooksUseCase getBorrowedBooksUseCase;
  final GetUploadedBooksUseCase getUploadedBooksUseCase;

  LibraryBloc({
    required this.getBorrowedBooksUseCase,
    required this.getUploadedBooksUseCase,
  }) : super(LibraryInitial()) {
    on<LoadBorrowedBooks>(_onLoadBorrowedBooks);
    on<LoadUploadedBooks>(_onLoadUploadedBooks);
    on<RefreshLibrary>(_onRefreshLibrary);
  }

  Future<void> _onLoadBorrowedBooks(
    LoadBorrowedBooks event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is! LibraryLoaded) {
      emit(LibraryLoading());
    }

    final result = await getBorrowedBooksUseCase(limit: 5); // Limit to 5 for horizontal list

    result.fold(
      (failure) {
        if (state is! LibraryLoaded) {
          emit(LibraryError(failure.message));
        }
      },
      (borrowedBooks) {
        if (state is LibraryLoaded) {
          final currentState = state as LibraryLoaded;
          emit(currentState.copyWith(borrowedBooks: borrowedBooks));
        } else {
          // If this is the first load, emit loaded state with empty uploaded books
          emit(LibraryLoaded(
            borrowedBooks: borrowedBooks,
            uploadedBooks: const [],
          ));
        }
      },
    );
  }

  Future<void> _onLoadUploadedBooks(
    LoadUploadedBooks event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is! LibraryLoaded) {
      emit(LibraryLoading());
    }

    final result = await getUploadedBooksUseCase(limit: 5); // Limit to 5 for horizontal list

    result.fold(
      (failure) {
        if (state is! LibraryLoaded) {
          emit(LibraryError(failure.message));
        }
      },
      (uploadedBooks) {
        if (state is LibraryLoaded) {
          final currentState = state as LibraryLoaded;
          emit(currentState.copyWith(uploadedBooks: uploadedBooks));
        } else {
          // If this is the first load, emit loaded state with empty borrowed books
          emit(LibraryLoaded(
            borrowedBooks: const [],
            uploadedBooks: uploadedBooks,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshLibrary(
    RefreshLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(LibraryLoading());
    }

    // Load both borrowed and uploaded books concurrently
    final borrowedResult = await getBorrowedBooksUseCase(limit: 5);
    final uploadedResult = await getUploadedBooksUseCase(limit: 5);

    final borrowedBooks = borrowedResult.fold((l) => <Book>[], (r) => r);
    final uploadedBooks = uploadedResult.fold((l) => <Book>[], (r) => r);

    if (borrowedResult.isLeft() || uploadedResult.isLeft()) {
      final errorMessage = borrowedResult.fold(
        (failure) => failure.message,
        (_) => uploadedResult.fold((failure) => failure.message, (_) => ''),
      );
      emit(LibraryError(errorMessage));
    } else {
      emit(LibraryLoaded(
        borrowedBooks: borrowedBooks,
        uploadedBooks: uploadedBooks,
        isRefreshing: false,
      ));
    }
  }
}
