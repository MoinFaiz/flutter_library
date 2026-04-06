import 'package:equatable/equatable.dart';

/// Entity representing user feedback
class Feedback extends Equatable {
  final String id;
  final FeedbackType type;
  final String message;
  final DateTime createdAt;
  final FeedbackStatus status;

  const Feedback({
    required this.id,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props => [id, type, message, createdAt, status];

  Feedback copyWith({
    String? id,
    FeedbackType? type,
    String? message,
    DateTime? createdAt,
    FeedbackStatus? status,
  }) {
    return Feedback(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

/// Enum for feedback types
enum FeedbackType {
  general,
  bugReport,
  featureRequest,
  complaint,
}

/// Enum for feedback status
enum FeedbackStatus {
  pending,
  inReview,
  resolved,
  closed,
}

extension FeedbackTypeExtension on FeedbackType {
  String get displayName {
    switch (this) {
      case FeedbackType.general:
        return 'General Feedback';
      case FeedbackType.bugReport:
        return 'Bug Report';
      case FeedbackType.featureRequest:
        return 'Feature Request';
      case FeedbackType.complaint:
        return 'Complaint';
    }
  }

  String get description {
    switch (this) {
      case FeedbackType.general:
        return 'General comments and suggestions';
      case FeedbackType.bugReport:
        return 'Report technical issues or problems';
      case FeedbackType.featureRequest:
        return 'Suggest new features or improvements';
      case FeedbackType.complaint:
        return 'Report service or quality issues';
    }
  }
}
