import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

enum NotificationType { 
  requestSent, 
  requestReceived, 
  requestAccepted, 
  requestRejected 
}

class CartNotification extends Equatable {
  final String id;
  final String requestId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookImageUrl;
  final NotificationType type;
  final CartItemType requestType;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? actionUserId; // User who performed the action
  final String? actionUserName;

  const CartNotification({
    required this.id,
    required this.requestId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookImageUrl,
    required this.type,
    required this.requestType,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.actionUserId,
    this.actionUserName,
  });

  bool get isRequestSent => type == NotificationType.requestSent;
  bool get isRequestReceived => type == NotificationType.requestReceived;
  bool get isRequestAccepted => type == NotificationType.requestAccepted;
  bool get isRequestRejected => type == NotificationType.requestRejected;
  bool get requiresAction => type == NotificationType.requestReceived;

  CartNotification copyWith({
    String? id,
    String? requestId,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookImageUrl,
    NotificationType? type,
    CartItemType? requestType,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? actionUserId,
    String? actionUserName,
  }) {
    return CartNotification(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      type: type ?? this.type,
      requestType: requestType ?? this.requestType,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionUserId: actionUserId ?? this.actionUserId,
      actionUserName: actionUserName ?? this.actionUserName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requestId,
        bookId,
        bookTitle,
        bookAuthor,
        bookImageUrl,
        type,
        requestType,
        message,
        isRead,
        createdAt,
        actionUserId,
        actionUserName,
      ];
}
