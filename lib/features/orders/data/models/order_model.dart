import 'package:flutter_library/features/orders/domain/entities/order.dart';

/// Data model for Order
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.bookId,
    required super.bookTitle,
    required super.bookImageUrl,
    required super.bookAuthor,
    required super.type,
    required super.status,
    required super.price,
    required super.orderDate,
    super.deliveryDate,
    super.returnDate,
    super.notes,
  });

  /// Create model from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String,
      bookImageUrl: json['bookImageUrl'] as String,
      bookAuthor: json['bookAuthor'] as String,
      type: OrderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OrderType.purchase,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      price: (json['price'] as num).toDouble(),
      orderDate: DateTime.parse(json['orderDate'] as String),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'] as String)
          : null,
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookImageUrl': bookImageUrl,
      'bookAuthor': bookAuthor,
      'type': type.name,
      'status': status.name,
      'price': price,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create model from entity
  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      bookId: order.bookId,
      bookTitle: order.bookTitle,
      bookImageUrl: order.bookImageUrl,
      bookAuthor: order.bookAuthor,
      type: order.type,
      status: order.status,
      price: order.price,
      orderDate: order.orderDate,
      deliveryDate: order.deliveryDate,
      returnDate: order.returnDate,
      notes: order.notes,
    );
  }

  /// Create a copy with updated fields
  @override
  OrderModel copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    String? bookImageUrl,
    String? bookAuthor,
    OrderType? type,
    OrderStatus? status,
    double? price,
    DateTime? orderDate,
    DateTime? deliveryDate,
    DateTime? returnDate,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      type: type ?? this.type,
      status: status ?? this.status,
      price: price ?? this.price,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      returnDate: returnDate ?? this.returnDate,
      notes: notes ?? this.notes,
    );
  }
}
