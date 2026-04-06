import 'package:equatable/equatable.dart';

/// Enum for order status
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  returned,
  completed,
  cancelled,
}

/// Enum for order type
enum OrderType {
  purchase,
  rental,
}

/// Order entity representing a user's book order
class Order extends Equatable {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookImageUrl;
  final String bookAuthor;
  final OrderType type;
  final OrderStatus status;
  final double price;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final DateTime? returnDate;
  final String? notes;

  const Order({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookImageUrl,
    required this.bookAuthor,
    required this.type,
    required this.status,
    required this.price,
    required this.orderDate,
    this.deliveryDate,
    this.returnDate,
    this.notes,
  });

  /// Check if this is an active order (not completed/delivered/cancelled)
  bool get isActive {
    return status == OrderStatus.pending ||
           status == OrderStatus.processing ||
           status == OrderStatus.shipped;
  }

  String get typeDisplayText {
    switch (type) {
      case OrderType.purchase:
        return 'Purchase';
      case OrderType.rental:
        return 'Rental';
    }
  }

  String get statusDisplayText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.returned:
        return 'Returned';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Order copyWith({
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
    return Order(
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

  @override
  List<Object?> get props => [
        id,
        bookId,
        bookTitle,
        bookImageUrl,
        bookAuthor,
        type,
        status,
        price,
        orderDate,
        deliveryDate,
        returnDate,
        notes,
      ];
}
