import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';
import 'package:flutter_library/features/notifications/data/models/notification_data_converter.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.timestamp,
    required super.type,
    super.isRead = false,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = NotificationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => NotificationType.information,
    );
    
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: type,
      isRead: json['isRead'] as bool? ?? false,
      data: NotificationDataConverter.fromJson(
        json['data'] as Map<String, dynamic>?, 
        type,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'data': NotificationDataConverter.toJson(data),
    };
  }

  @override
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    NotificationData? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

class BookRequestNotificationModel extends NotificationModel implements BookRequestNotification {
  @override
  BookRequestData? get bookData => data as BookRequestData?;

  const BookRequestNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.timestamp,
    required super.type,
    super.isRead = false,
    BookRequestData? bookRequestData,
  }) : super(data: bookRequestData);

  factory BookRequestNotificationModel.fromJson(Map<String, dynamic> json) {
    final type = NotificationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => NotificationType.bookRequest,
    );
    
    return BookRequestNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: type,
      isRead: json['isRead'] as bool? ?? false,
      bookRequestData: NotificationDataConverter.fromJson(
        json['data'] as Map<String, dynamic>?, 
        type,
      ) as BookRequestData?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'data': NotificationDataConverter.toJson(data),
    };
  }

  @override
  BookRequestNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    NotificationData? data,
  }) {
    return BookRequestNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      bookRequestData: data as BookRequestData? ?? bookData,
    );
  }
}
