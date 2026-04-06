import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

/// States for book details
abstract class BookDetailsState extends Equatable {
  const BookDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BookDetailsInitial extends BookDetailsState {}

/// Loading book details (fast loading)
class BookDetailsLoading extends BookDetailsState {}

/// Book loaded but other components may still be loading
class BookDetailsLoaded extends BookDetailsState {
  final Book book;
  final RentalStatus? rentalStatus; // null when not loaded yet
  final bool isLoadingRentalStatus;
  final bool isPerformingAction;
  final String? actionMessage;
  final String? rentalStatusError;

  const BookDetailsLoaded({
    required this.book,
    this.rentalStatus,
    this.isLoadingRentalStatus = false,
    this.isPerformingAction = false,
    this.actionMessage,
    this.rentalStatusError,
  });

  @override
  List<Object?> get props => [
    book, 
    rentalStatus, 
    isLoadingRentalStatus,
    isPerformingAction, 
    actionMessage,
    rentalStatusError,
  ];

  BookDetailsLoaded copyWith({
    Book? book,
    RentalStatus? rentalStatus,
    bool? isLoadingRentalStatus,
    bool? isPerformingAction,
    String? actionMessage,
    String? rentalStatusError,
    bool clearRentalStatusError = false,
  }) {
    return BookDetailsLoaded(
      book: book ?? this.book,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      isLoadingRentalStatus: isLoadingRentalStatus ?? this.isLoadingRentalStatus,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
      actionMessage: actionMessage ?? this.actionMessage,
      rentalStatusError: clearRentalStatusError ? null : (rentalStatusError ?? this.rentalStatusError),
    );
  }
}

/// Error state
class BookDetailsError extends BookDetailsState {
  final String message;

  const BookDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
