import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

enum RequestStatus { pending, accepted, rejected, cancelled }

class CartRequest extends Equatable {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookImageUrl;
  final String requesterId; // User who made the request
  final String ownerId; // Book owner
  final CartItemType requestType;
  final int rentalPeriodInDays;
  final double price;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const CartRequest({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookImageUrl,
    required this.requesterId,
    required this.ownerId,
    required this.requestType,
    required this.rentalPeriodInDays,
    required this.price,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  bool get isPending => status == RequestStatus.pending;
  bool get isAccepted => status == RequestStatus.accepted;
  bool get isRejected => status == RequestStatus.rejected;
  bool get isCancelled => status == RequestStatus.cancelled;
  bool get isRental => requestType == CartItemType.rent;
  bool get isPurchase => requestType == CartItemType.purchase;

  String get requestTypeLabel => isRental ? 'Rental' : 'Purchase';

  CartRequest copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookImageUrl,
    String? requesterId,
    String? ownerId,
    CartItemType? requestType,
    int? rentalPeriodInDays,
    double? price,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return CartRequest(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      requesterId: requesterId ?? this.requesterId,
      ownerId: ownerId ?? this.ownerId,
      requestType: requestType ?? this.requestType,
      rentalPeriodInDays: rentalPeriodInDays ?? this.rentalPeriodInDays,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookId,
        bookTitle,
        bookAuthor,
        bookImageUrl,
        requesterId,
        ownerId,
        requestType,
        rentalPeriodInDays,
        price,
        status,
        createdAt,
        respondedAt,
      ];
}
