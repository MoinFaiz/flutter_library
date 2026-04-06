import 'package:equatable/equatable.dart';

/// Base event for rental status
abstract class RentalStatusEvent extends Equatable {
  const RentalStatusEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load rental status for a book
class LoadRentalStatus extends RentalStatusEvent {
  final String bookId;

  const LoadRentalStatus(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to rent a book
class RentBook extends RentalStatusEvent {
  final String bookId;

  const RentBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to buy a book
class BuyBook extends RentalStatusEvent {
  final String bookId;

  const BuyBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to return a book
class ReturnBook extends RentalStatusEvent {
  final String bookId;

  const ReturnBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to renew a book rental
class RenewBook extends RentalStatusEvent {
  final String bookId;

  const RenewBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to remove book from cart
class RemoveFromCart extends RentalStatusEvent {
  final String bookId;

  const RemoveFromCart(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

/// Event to refresh rental status for a book
class RefreshRentalStatus extends RentalStatusEvent {
  final String bookId;

  const RefreshRentalStatus(this.bookId);

  @override
  List<Object?> get props => [bookId];
}
