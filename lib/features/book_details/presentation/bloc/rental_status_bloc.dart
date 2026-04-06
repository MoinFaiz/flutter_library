import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_rental_status_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/rent_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/buy_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/return_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/renew_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_event.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_state.dart';

/// BLoC for managing rental status state
class RentalStatusBloc extends Bloc<RentalStatusEvent, RentalStatusState> {
  final GetRentalStatusUseCase getRentalStatusUseCase;
  final RentBookUseCase rentBookUseCase;
  final BuyBookUseCase buyBookUseCase;
  final ReturnBookUseCase returnBookUseCase;
  final RenewBookUseCase renewBookUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;

  RentalStatusBloc({
    required this.getRentalStatusUseCase,
    required this.rentBookUseCase,
    required this.buyBookUseCase,
    required this.returnBookUseCase,
    required this.renewBookUseCase,
    required this.removeFromCartUseCase,
  }) : super(const RentalStatusInitial()) {
    on<LoadRentalStatus>(_onLoadRentalStatus);
    on<RentBook>(_onRentBook);
    on<BuyBook>(_onBuyBook);
    on<ReturnBook>(_onReturnBook);
    on<RenewBook>(_onRenewBook);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<RefreshRentalStatus>(_onRefreshRentalStatus);
  }

  Future<void> _onLoadRentalStatus(LoadRentalStatus event, Emitter<RentalStatusState> emit) async {
    emit(const RentalStatusLoading());
    
    final result = await getRentalStatusUseCase(event.bookId);
    result.fold(
      (failure) => emit(RentalStatusError(failure.message)),
      (rentalStatus) => emit(RentalStatusLoaded(rentalStatus: rentalStatus)),
    );
  }

  Future<void> _onRentBook(RentBook event, Emitter<RentalStatusState> emit) async {
    if (state is RentalStatusLoaded) {
      final currentState = state as RentalStatusLoaded;
      emit(RentalStatusUpdating(rentalStatus: currentState.rentalStatus));
      
      final result = await rentBookUseCase(event.bookId);
      await result.fold(
        (failure) async => emit(RentalStatusError(failure.message)),
        (book) async {
          // Refresh rental status after successful rent
          final statusResult = await getRentalStatusUseCase(event.bookId);
          statusResult.fold(
            (failure) => emit(RentalStatusError(failure.message)),
            (rentalStatus) => emit(RentalStatusLoaded(
              rentalStatus: rentalStatus,
              actionMessage: 'Book rented successfully',
            )),
          );
        },
      );
    }
  }

  Future<void> _onBuyBook(BuyBook event, Emitter<RentalStatusState> emit) async {
    if (state is RentalStatusLoaded) {
      final currentState = state as RentalStatusLoaded;
      emit(RentalStatusUpdating(rentalStatus: currentState.rentalStatus));
      
      final result = await buyBookUseCase(event.bookId);
      await result.fold(
        (failure) async => emit(RentalStatusError(failure.message)),
        (book) async {
          // Refresh rental status after successful purchase
          final statusResult = await getRentalStatusUseCase(event.bookId);
          statusResult.fold(
            (failure) => emit(RentalStatusError(failure.message)),
            (rentalStatus) => emit(RentalStatusLoaded(
              rentalStatus: rentalStatus,
              actionMessage: 'Book purchased successfully',
            )),
          );
        },
      );
    }
  }

  Future<void> _onReturnBook(ReturnBook event, Emitter<RentalStatusState> emit) async {
    if (state is RentalStatusLoaded) {
      final currentState = state as RentalStatusLoaded;
      emit(RentalStatusUpdating(rentalStatus: currentState.rentalStatus));
      
      final result = await returnBookUseCase(event.bookId);
      await result.fold(
        (failure) async => emit(RentalStatusError(failure.message)),
        (book) async {
          // Refresh rental status after successful return
          final statusResult = await getRentalStatusUseCase(event.bookId);
          statusResult.fold(
            (failure) => emit(RentalStatusError(failure.message)),
            (rentalStatus) => emit(RentalStatusLoaded(
              rentalStatus: rentalStatus,
              actionMessage: 'Book returned successfully',
            )),
          );
        },
      );
    }
  }

  Future<void> _onRenewBook(RenewBook event, Emitter<RentalStatusState> emit) async {
    if (state is RentalStatusLoaded) {
      final currentState = state as RentalStatusLoaded;
      emit(RentalStatusUpdating(rentalStatus: currentState.rentalStatus));
      
      final result = await renewBookUseCase(event.bookId);
      await result.fold(
        (failure) async => emit(RentalStatusError(failure.message)),
        (book) async {
          // Refresh rental status after successful renewal
          final statusResult = await getRentalStatusUseCase(event.bookId);
          statusResult.fold(
            (failure) => emit(RentalStatusError(failure.message)),
            (rentalStatus) => emit(RentalStatusLoaded(
              rentalStatus: rentalStatus,
              actionMessage: 'Book renewed successfully',
            )),
          );
        },
      );
    }
  }

  Future<void> _onRemoveFromCart(RemoveFromCart event, Emitter<RentalStatusState> emit) async {
    if (state is RentalStatusLoaded) {
      final currentState = state as RentalStatusLoaded;
      emit(RentalStatusUpdating(rentalStatus: currentState.rentalStatus));
      
      final result = await removeFromCartUseCase(event.bookId);
      await result.fold(
        (failure) async => emit(RentalStatusError(failure.message)),
        (book) async {
          // Refresh rental status after successful removal
          final statusResult = await getRentalStatusUseCase(event.bookId);
          statusResult.fold(
            (failure) => emit(RentalStatusError(failure.message)),
            (rentalStatus) => emit(RentalStatusLoaded(
              rentalStatus: rentalStatus,
              actionMessage: 'Book removed from cart',
            )),
          );
        },
      );
    }
  }

  Future<void> _onRefreshRentalStatus(RefreshRentalStatus event, Emitter<RentalStatusState> emit) async {
    // Keep current state while refreshing
    final currentStatus = state is RentalStatusLoaded ? (state as RentalStatusLoaded).rentalStatus : null;
    
    final result = await getRentalStatusUseCase(event.bookId);
    result.fold(
      (failure) {
        // If refresh fails, keep current data but show error
        if (currentStatus != null) {
          emit(RentalStatusLoaded(
            rentalStatus: currentStatus,
            actionMessage: 'Failed to refresh rental status: ${failure.message}',
          ));
        } else {
          emit(RentalStatusError(failure.message));
        }
      },
      (rentalStatus) => emit(RentalStatusLoaded(rentalStatus: rentalStatus)),
    );
  }
}
