import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

enum CartItemType { rent, purchase }

class CartItem extends Equatable {
  final String id;
  final Book book;
  final CartItemType type;
  final DateTime addedAt;
  final int rentalPeriodInDays; // Default 14 days for rent
  final String? requestId; // ID from server after sending request

  const CartItem({
    required this.id,
    required this.book,
    required this.type,
    required this.addedAt,
    this.rentalPeriodInDays = 14,
    this.requestId,
  });

  double get price {
    return type == CartItemType.rent ? book.rentPrice : book.salePrice;
  }

  bool get isRental => type == CartItemType.rent;
  bool get isPurchase => type == CartItemType.purchase;
  bool get hasRequestSent => requestId != null;

  CartItem copyWith({
    String? id,
    Book? book,
    CartItemType? type,
    DateTime? addedAt,
    int? rentalPeriodInDays,
    String? requestId,
  }) {
    return CartItem(
      id: id ?? this.id,
      book: book ?? this.book,
      type: type ?? this.type,
      addedAt: addedAt ?? this.addedAt,
      rentalPeriodInDays: rentalPeriodInDays ?? this.rentalPeriodInDays,
      requestId: requestId ?? this.requestId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        book,
        type,
        addedAt,
        rentalPeriodInDays,
        requestId,
      ];
}
