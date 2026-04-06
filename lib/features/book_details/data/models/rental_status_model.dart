import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

/// Data model for rental status
class RentalStatusModel extends RentalStatus {
  const RentalStatusModel({
    required super.bookId,
    required super.status,
    super.dueDate,
    super.rentedDate,
    super.returnDate,
    super.daysRemaining,
    super.canRenew,
    super.isInCart,
    super.isPurchased,
    super.lateFee,
    super.notes,
  });

  /// Create model from JSON
  factory RentalStatusModel.fromJson(Map<String, dynamic> json) {
    return RentalStatusModel(
      bookId: json['bookId'] as String,
      status: _statusFromString(json['status'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      rentedDate: json['rentedDate'] != null ? DateTime.parse(json['rentedDate']) : null,
      returnDate: json['returnDate'] != null ? DateTime.parse(json['returnDate']) : null,
      daysRemaining: json['daysRemaining'] as int?,
      canRenew: json['canRenew'] as bool? ?? false,
      isInCart: json['isInCart'] as bool? ?? false,
      isPurchased: json['isPurchased'] as bool? ?? false,
      lateFee: json['lateFee'] as double?,
      notes: json['notes'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'status': _statusToString(status),
      'dueDate': dueDate?.toIso8601String(),
      'rentedDate': rentedDate?.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'daysRemaining': daysRemaining,
      'canRenew': canRenew,
      'isInCart': isInCart,
      'isPurchased': isPurchased,
      'lateFee': lateFee,
      'notes': notes,
    };
  }

  /// Convert string to RentalStatusType
  static RentalStatusType _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return RentalStatusType.available;
      case 'rented':
        return RentalStatusType.rented;
      case 'duesoon':
        return RentalStatusType.dueSoon;
      case 'overdue':
        return RentalStatusType.overdue;
      case 'incart':
        return RentalStatusType.inCart;
      case 'purchased':
        return RentalStatusType.purchased;
      case 'unavailable':
        return RentalStatusType.unavailable;
      default:
        return RentalStatusType.available;
    }
  }

  /// Convert RentalStatusType to string
  static String _statusToString(RentalStatusType status) {
    switch (status) {
      case RentalStatusType.available:
        return 'available';
      case RentalStatusType.rented:
        return 'rented';
      case RentalStatusType.dueSoon:
        return 'duesoon';
      case RentalStatusType.overdue:
        return 'overdue';
      case RentalStatusType.inCart:
        return 'incart';
      case RentalStatusType.purchased:
        return 'purchased';
      case RentalStatusType.unavailable:
        return 'unavailable';
    }
  }

  /// Create a copy with updated fields
  RentalStatusModel copyWith({
    String? bookId,
    RentalStatusType? status,
    DateTime? dueDate,
    DateTime? rentedDate,
    DateTime? returnDate,
    int? daysRemaining,
    bool? canRenew,
    bool? isInCart,
    bool? isPurchased,
    double? lateFee,
    String? notes,
  }) {
    return RentalStatusModel(
      bookId: bookId ?? this.bookId,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      rentedDate: rentedDate ?? this.rentedDate,
      returnDate: returnDate ?? this.returnDate,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      canRenew: canRenew ?? this.canRenew,
      isInCart: isInCart ?? this.isInCart,
      isPurchased: isPurchased ?? this.isPurchased,
      lateFee: lateFee ?? this.lateFee,
      notes: notes ?? this.notes,
    );
  }
}
