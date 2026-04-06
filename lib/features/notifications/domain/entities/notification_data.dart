import 'package:equatable/equatable.dart';

/// Base class for notification data
abstract class NotificationData extends Equatable {
  const NotificationData();
}

/// Data for book request notifications
class BookRequestData extends NotificationData {
  final String bookId;
  final String bookTitle;
  final String requesterId;
  final String requesterName;
  final String requesterEmail;
  final String requestType; // Instead of enum to keep it simple
  final DateTime? pickupDate;
  final String? pickupLocation;
  final double? offerPrice;
  final String? requestMessage;
  final String status; // Instead of enum to keep it simple

  const BookRequestData({
    required this.bookId,
    required this.bookTitle,
    required this.requesterId,
    required this.requesterName,
    required this.requesterEmail,
    required this.requestType,
    this.pickupDate,
    this.pickupLocation,
    this.offerPrice,
    this.requestMessage,
    this.status = 'pending',
  });

  @override
  List<Object?> get props => [
    bookId,
    bookTitle,
    requesterId,
    requesterName,
    requesterEmail,
    requestType,
    pickupDate,
    pickupLocation,
    offerPrice,
    requestMessage,
    status,
  ];
}

/// Data for book reminder notifications
class BookReminderData extends NotificationData {
  final String bookId;
  final String bookTitle;
  final DateTime dueDate;

  const BookReminderData({
    required this.bookId,
    required this.bookTitle,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [bookId, bookTitle, dueDate];
}

/// Data for system notifications (no additional data needed)
class SystemNotificationData extends NotificationData {
  const SystemNotificationData();

  @override
  List<Object?> get props => [];
}

/// Data for book status notifications
class BookStatusData extends NotificationData {
  final String bookId;
  final String bookTitle;
  final String status;

  const BookStatusData({
    required this.bookId,
    required this.bookTitle,
    required this.status,
  });

  @override
  List<Object?> get props => [bookId, bookTitle, status];
}

/// Data for cart request notifications
class CartNotificationData extends NotificationData {
  final String requestId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookImageUrl;
  final String requestType; // 'rent' or 'purchase'
  final String? actionUserId;
  final String? actionUserName;
  final int? rentalPeriodInDays;

  const CartNotificationData({
    required this.requestId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookImageUrl,
    required this.requestType,
    this.actionUserId,
    this.actionUserName,
    this.rentalPeriodInDays,
  });

  @override
  List<Object?> get props => [
    requestId,
    bookId,
    bookTitle,
    bookAuthor,
    bookImageUrl,
    requestType,
    actionUserId,
    actionUserName,
    rentalPeriodInDays,
  ];
}
