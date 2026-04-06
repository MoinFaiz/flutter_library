import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

/// Base state for rental status
abstract class RentalStatusState extends Equatable {
  const RentalStatusState();

  @override
  List<Object?> get props => [];
}

/// Initial state for rental status
class RentalStatusInitial extends RentalStatusState {
  const RentalStatusInitial();
}

/// Loading state for rental status
class RentalStatusLoading extends RentalStatusState {
  const RentalStatusLoading();
}

/// Loaded state for rental status
class RentalStatusLoaded extends RentalStatusState {
  final RentalStatus rentalStatus;
  final String? actionMessage;

  const RentalStatusLoaded({
    required this.rentalStatus,
    this.actionMessage,
  });

  @override
  List<Object?> get props => [rentalStatus, actionMessage];

  RentalStatusLoaded copyWith({
    RentalStatus? rentalStatus,
    String? actionMessage,
  }) {
    return RentalStatusLoaded(
      rentalStatus: rentalStatus ?? this.rentalStatus,
      actionMessage: actionMessage,
    );
  }
}

/// Error state for rental status
class RentalStatusError extends RentalStatusState {
  final String message;

  const RentalStatusError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for performing rental actions
class RentalStatusUpdating extends RentalStatusState {
  final RentalStatus rentalStatus;

  const RentalStatusUpdating({required this.rentalStatus});

  @override
  List<Object?> get props => [rentalStatus];
}
