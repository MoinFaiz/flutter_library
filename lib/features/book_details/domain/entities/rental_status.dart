import 'package:equatable/equatable.dart';

/// Enum for rental status types
enum RentalStatusType {
  available,
  rented,
  dueSoon,
  overdue,
  inCart,
  purchased,
  unavailable,
}

/// Rental status entity representing the current rental state of a book
class RentalStatus extends Equatable {
  final String bookId;
  final RentalStatusType status;
  final DateTime? dueDate;
  final DateTime? rentedDate;
  final DateTime? returnDate;
  final int? daysRemaining;
  final bool canRenew;
  final bool isInCart;
  final bool isPurchased;
  final double? lateFee;
  final String? notes;

  const RentalStatus({
    required this.bookId,
    required this.status,
    this.dueDate,
    this.rentedDate,
    this.returnDate,
    this.daysRemaining,
    this.canRenew = false,
    this.isInCart = false,
    this.isPurchased = false,
    this.lateFee,
    this.notes,
  });

  // Convenience getters
  bool get isRented => status == RentalStatusType.rented || 
                      status == RentalStatusType.dueSoon || 
                      status == RentalStatusType.overdue;
  
  bool get isOverdue => status == RentalStatusType.overdue;
  
  bool get isDueSoon => status == RentalStatusType.dueSoon;
  
  bool get isAvailable => status == RentalStatusType.available;
  
  bool get hasLateFee => lateFee != null && lateFee! > 0;
  
  double get progressPercentage {
    if (daysRemaining == null || rentedDate == null || dueDate == null) {
      return 0.0;
    }
    
    final totalDays = dueDate!.difference(rentedDate!).inDays;
    final elapsedDays = totalDays - daysRemaining!;
    
    if (totalDays <= 0) return 1.0;
    
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
    bookId,
    status,
    dueDate,
    rentedDate,
    returnDate,
    daysRemaining,
    canRenew,
    isInCart,
    isPurchased,
    lateFee,
    notes,
  ];
}
