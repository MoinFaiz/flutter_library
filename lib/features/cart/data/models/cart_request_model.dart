import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

class CartRequestModel extends CartRequest {
  const CartRequestModel({
    required super.id,
    required super.bookId,
    required super.bookTitle,
    required super.bookAuthor,
    required super.bookImageUrl,
    required super.requesterId,
    required super.ownerId,
    required super.requestType,
    required super.rentalPeriodInDays,
    required super.price,
    required super.status,
    required super.createdAt,
    super.respondedAt,
  });

  factory CartRequestModel.fromJson(Map<String, dynamic> json) {
    return CartRequestModel(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      bookTitle: json['book_title'] as String,
      bookAuthor: json['book_author'] as String,
      bookImageUrl: json['book_image_url'] as String,
      requesterId: json['requester_id'] as String,
      ownerId: json['owner_id'] as String,
      requestType: _parseRequestType(json['request_type'] as String),
      rentalPeriodInDays: json['rental_period_in_days'] as int? ?? 14,
      price: (json['price'] as num).toDouble(),
      status: _parseRequestStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'book_title': bookTitle,
      'book_author': bookAuthor,
      'book_image_url': bookImageUrl,
      'requester_id': requesterId,
      'owner_id': ownerId,
      'request_type': _requestTypeToString(requestType),
      'rental_period_in_days': rentalPeriodInDays,
      'price': price,
      'status': _requestStatusToString(status),
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }

  factory CartRequestModel.fromEntity(CartRequest request) {
    return CartRequestModel(
      id: request.id,
      bookId: request.bookId,
      bookTitle: request.bookTitle,
      bookAuthor: request.bookAuthor,
      bookImageUrl: request.bookImageUrl,
      requesterId: request.requesterId,
      ownerId: request.ownerId,
      requestType: request.requestType,
      rentalPeriodInDays: request.rentalPeriodInDays,
      price: request.price,
      status: request.status,
      createdAt: request.createdAt,
      respondedAt: request.respondedAt,
    );
  }

  static CartItemType _parseRequestType(String type) {
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

  static String _requestTypeToString(CartItemType type) {
    switch (type) {
      case CartItemType.rent:
        return 'rent';
      case CartItemType.purchase:
        return 'purchase';
    }
  }

  static RequestStatus _parseRequestStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }

  static String _requestStatusToString(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.rejected:
        return 'rejected';
      case RequestStatus.cancelled:
        return 'cancelled';
    }
  }
}
