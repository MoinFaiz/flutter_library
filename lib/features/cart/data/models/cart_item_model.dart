import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.book,
    required super.type,
    required super.addedAt,
    super.rentalPeriodInDays,
    super.requestId,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      book: BookModel.fromJson(json['book'] as Map<String, dynamic>).toEntity(),
      type: _parseCartItemType(json['type'] as String),
      addedAt: DateTime.parse(json['added_at'] as String),
      rentalPeriodInDays: json['rental_period_in_days'] as int? ?? 14,
      requestId: json['request_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': (book as BookModel).toJson(),
      'type': _cartItemTypeToString(type),
      'added_at': addedAt.toIso8601String(),
      'rental_period_in_days': rentalPeriodInDays,
      'request_id': requestId,
    };
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      id: item.id,
      book: item.book,
      type: item.type,
      addedAt: item.addedAt,
      rentalPeriodInDays: item.rentalPeriodInDays,
      requestId: item.requestId,
    );
  }

  static CartItemType _parseCartItemType(String type) {
    switch (type.toLowerCase()) {
      case 'rent':
      case 'rental':
        return CartItemType.rent;
      case 'purchase':
      case 'buy':
        return CartItemType.purchase;
      default:
        return CartItemType.rent;
    }
  }

  static String _cartItemTypeToString(CartItemType type) {
    switch (type) {
      case CartItemType.rent:
        return 'rent';
      case CartItemType.purchase:
        return 'purchase';
    }
  }
}
