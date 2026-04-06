import 'package:flutter_library/features/book_details/domain/entities/review.dart';

/// Data model for review with enhanced features
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.bookId,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.reviewText,
    required super.rating,
    super.helpfulCount = 0,
    super.unhelpfulCount = 0,
    super.isReported = false,
    super.isEdited = false,
    required super.createdAt,
    required super.updatedAt,
    super.currentUserVote,
  });

  /// Create model from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      reviewText: json['reviewText'] as String,
      rating: (json['rating'] as num).toDouble(),
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      unhelpfulCount: (json['unhelpfulCount'] as num?)?.toInt() ?? 0,
      isReported: json['isReported'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      currentUserVote: json['currentUserVote'] as String?,
    );
  }

  /// Create model from entity
  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      bookId: review.bookId,
      userId: review.userId,
      userName: review.userName,
      userAvatarUrl: review.userAvatarUrl,
      reviewText: review.reviewText,
      rating: review.rating,
      helpfulCount: review.helpfulCount,
      unhelpfulCount: review.unhelpfulCount,
      isReported: review.isReported,
      isEdited: review.isEdited,
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
      currentUserVote: review.currentUserVote,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'reviewText': reviewText,
      'rating': rating,
      'helpfulCount': helpfulCount,
      'unhelpfulCount': unhelpfulCount,
      'isReported': isReported,
      'isEdited': isEdited,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'currentUserVote': currentUserVote,
    };
  }

  /// Create a copy with updated fields
  @override
  ReviewModel copyWith({
    String? id,
    String? bookId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? reviewText,
    double? rating,
    int? helpfulCount,
    int? unhelpfulCount,
    bool? isReported,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currentUserVote,
    bool clearCurrentUserVote = false,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      reviewText: reviewText ?? this.reviewText,
      rating: rating ?? this.rating,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      unhelpfulCount: unhelpfulCount ?? this.unhelpfulCount,
      isReported: isReported ?? this.isReported,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentUserVote: clearCurrentUserVote ? null : (currentUserVote ?? this.currentUserVote),
    );
  }
}
