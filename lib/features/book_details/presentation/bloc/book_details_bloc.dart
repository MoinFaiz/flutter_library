import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/book_details/domain/usecases/rent_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/buy_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/return_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/renew_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_rental_status_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_library/features/home/domain/usecases/get_book_by_id_usecase.dart';
import 'book_details_event.dart';
import 'book_details_state.dart';

/// BLoC for managing book details state
class BookDetailsBloc extends Bloc<BookDetailsEvent, BookDetailsState> {
  final GetBookByIdUseCase getBookByIdUseCase;
  final RentBookUseCase rentBookUseCase;
  final BuyBookUseCase buyBookUseCase;
  final ReturnBookUseCase returnBookUseCase;
  final RenewBookUseCase renewBookUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final GetRentalStatusUseCase getRentalStatusUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  BookDetailsBloc({
    required this.getBookByIdUseCase,
    required this.rentBookUseCase,
    required this.buyBookUseCase,
    required this.returnBookUseCase,
    required this.renewBookUseCase,
    required this.removeFromCartUseCase,
    required this.getRentalStatusUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(BookDetailsInitial()) {
    on<LoadBookDetails>(_onLoadBookDetails);
    on<RefreshBookDetails>(_onRefreshBookDetails);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadBookDetails(
    LoadBookDetails event,
    Emitter<BookDetailsState> emit,
  ) async {
    emit(BookDetailsLoading());

    try {
      // Only load book details - fast loading
      final bookResult = await getBookByIdUseCase(event.bookId);

      bookResult.fold(
        (failure) => emit(BookDetailsError(failure.message)),
        (book) {
          if (book == null) {
            emit(const BookDetailsError('Book not found'));
            return;
          }
          
          // Emit loaded state with only book data
          // Rental status will be null initially
          emit(BookDetailsLoaded(
            book: book,
            rentalStatus: null,
          ));
        },
      );
    } catch (e) {
      emit(BookDetailsError('Failed to load book details: ${e.toString()}'));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<BookDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BookDetailsLoaded) {
      emit(currentState.copyWith(isPerformingAction: true));

      final result = await toggleFavoriteUseCase(event.bookId);
      result.fold(
        (failure) => emit(currentState.copyWith(
          isPerformingAction: false,
          actionMessage: 'Failed to toggle favorite: ${failure.message}',
        )),
        (isFavorite) => emit(currentState.copyWith(
          book: currentState.book.copyWith(isFavorite: isFavorite),
          isPerformingAction: false,
          actionMessage: isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites',
        )),
      );
    }
  }

  Future<void> _onRefreshBookDetails(
    RefreshBookDetails event,
    Emitter<BookDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is BookDetailsLoaded) {
      // Set loading states for refresh
      emit(currentState.copyWith(
        isLoadingRentalStatus: true,
        clearRentalStatusError: true,
      ));

      try {
        // Load all data in parallel for refresh
        final bookResult = await getBookByIdUseCase(event.bookId);
        final rentalStatusResult = await getRentalStatusUseCase(event.bookId);

        bookResult.fold(
          (failure) => emit(BookDetailsError(failure.message)),
          (book) {
            if (book == null) {
              emit(const BookDetailsError('Book not found'));
              return;
            }

            final rentalStatus = rentalStatusResult.fold(
              (failure) => currentState.rentalStatus,
              (status) => status,
            );

            emit(currentState.copyWith(
              book: book,
              rentalStatus: rentalStatus,
              isLoadingRentalStatus: false,
              clearRentalStatusError: true,
            ));
          },
        );
      } catch (e) {
        emit(currentState.copyWith(
          isLoadingRentalStatus: false,
          rentalStatusError: 'Failed to refresh rental status',
        ));
      }
    }
  }
}
