import 'package:equatable/equatable.dart';

/// Review entity representing a book review with ratings, voting, and reporting
class Review extends Equatable {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String reviewText;
  final double rating;
  final int helpfulCount;
  final int unhelpfulCount;
  final bool isReported;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? currentUserVote; // 'helpful', 'unhelpful', or null

  const Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.reviewText,
    required this.rating,
    this.helpfulCount = 0,
    this.unhelpfulCount = 0,
    this.isReported = false,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
    this.currentUserVote,
  });

  /// Check if current user is the author
  bool isAuthor(String? currentUserId) {
    return currentUserId != null && userId == currentUserId;
  }

  /// Get net helpfulness score
  int get netHelpfulness => helpfulCount - unhelpfulCount;

  /// Check if review has been voted on
  bool get hasVotes => helpfulCount > 0 || unhelpfulCount > 0;

  /// Check if current user has voted
  bool get hasUserVoted => currentUserVote != null;

  /// Returns a human-readable relative time string (e.g. "Just now", "5 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m == 1 ? '1 minute ago' : '$m minutes ago';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? '1 hour ago' : '$h hours ago';
    } else if (diff.inDays < 30) {
      final d = diff.inDays;
      return d == 1 ? '1 day ago' : '$d days ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (diff.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  Review copyWith({
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
    return Review(
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

  @override
  List<Object?> get props => [
    id,
    bookId,
    userId,
    userName,
    userAvatarUrl,
    reviewText,
    rating,
    helpfulCount,
    unhelpfulCount,
    isReported,
    isEdited,
    createdAt,
    updatedAt,
    currentUserVote,
  ];
}
