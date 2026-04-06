import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

/// Data model for feedback
class FeedbackModel extends Feedback {
  const FeedbackModel({
    required super.id,
    required super.type,
    required super.message,
    required super.createdAt,
    required super.status,
  });

  /// Create FeedbackModel from JSON
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      type: FeedbackType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => FeedbackType.general,
      ),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => FeedbackStatus.pending,
      ),
    );
  }

  /// Convert FeedbackModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  /// Create a copy with updated values
  @override
  FeedbackModel copyWith({
    String? id,
    FeedbackType? type,
    String? message,
    DateTime? createdAt,
    FeedbackStatus? status,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
