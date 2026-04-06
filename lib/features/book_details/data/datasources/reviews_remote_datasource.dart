import 'package:flutter_library/features/book_details/data/models/review_model.dart';
import 'package:flutter_library/features/book_details/data/models/book_rating_model.dart';

/// Remote data source for reviews and ratings
abstract class ReviewsRemoteDataSource {
  /// Get reviews for a book
  Future<List<ReviewModel>> getReviews(String bookId);
  
  /// Submit a new review for a book
  Future<ReviewModel> submitReview({
    required String bookId,
    required String reviewText,
    required double rating,
  });
  
  /// Update an existing review
  Future<ReviewModel> updateReview({
    required String reviewId,
    required String reviewText,
    required double rating,
  });
  
  /// Delete a review
  Future<void> deleteReview(String reviewId);

  /// Submit or update a rating without review
  Future<BookRatingModel> submitRating({
    required String bookId,
    required double rating,
  });

  /// Get user's rating for a book
  Future<BookRatingModel?> getUserRating(String bookId);

  /// Vote on a review as helpful
  Future<ReviewModel> voteHelpful(String reviewId);

  /// Vote on a review as unhelpful
  Future<ReviewModel> voteUnhelpful(String reviewId);

  /// Remove vote from a review
  Future<ReviewModel> removeVote(String reviewId);

  /// Report a review as inappropriate
  Future<void> reportReview({
    required String reviewId,
    required String reason,
  });

  /// Get user's review for a specific book
  Future<ReviewModel?> getUserReview(String bookId);
}

/// Mock implementation of ReviewsRemoteDataSource
class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  // Mock current user ID (in real app, this would come from auth service)
  static const String _currentUserId = 'current_user_123';
  static const String _currentUserName = 'Current User';

  // In-memory storage for demo purposes
  final List<ReviewModel> _reviews = [];
  final Map<String, BookRatingModel> _ratings = {};
  final Map<String, String> _userVotes = {}; // reviewId_userId -> 'helpful' or 'unhelpful'

  ReviewsRemoteDataSourceImpl() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Pre-populate with some mock reviews for different books
    _reviews.addAll([
      ReviewModel(
        id: 'review_1',
        bookId: 'book_1',
        userId: 'user_1',
        userName: 'Alice Johnson',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
        reviewText: 'An absolutely captivating read! The author\'s storytelling ability is exceptional. I couldn\'t put it down from start to finish.',
        rating: 5.0,
        helpfulCount: 42,
        unhelpfulCount: 3,
        isEdited: false,
        isReported: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ReviewModel(
        id: 'review_2',
        bookId: 'book_1',
        userId: 'user_2',
        userName: 'Bob Smith',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=2',
        reviewText: 'Good book with interesting characters. The plot was engaging, though I felt the pacing could have been better in the middle section. Overall, definitely worth reading.',
        rating: 3.5,
        helpfulCount: 18,
        unhelpfulCount: 5,
        isEdited: false,
        isReported: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ReviewModel(
        id: 'review_3',
        bookId: 'book_1',
        userId: 'user_3',
        userName: 'Carol Davis',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=3',
        reviewText: 'One of the best books I\'ve read this year! The depth of the characters and the intricate plot kept me engaged throughout. Highly recommend to anyone who enjoys this genre.',
        rating: 4.5,
        helpfulCount: 28,
        unhelpfulCount: 2,
        isEdited: false,
        isReported: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ]);
  }

  @override
  Future<List<ReviewModel>> getReviews(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter reviews by bookId and sort by helpfulness
    final bookReviews = _reviews
        .where((review) => review.bookId == bookId)
        .toList()
      ..sort((a, b) => b.netHelpfulness.compareTo(a.netHelpfulness));
    
    return bookReviews;
  }

  @override
  Future<ReviewModel> submitReview({
    required String bookId,
    required String reviewText,
    required double rating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user already has a review for this book
    final existingReview = _reviews.firstWhere(
      (review) => review.bookId == bookId && review.userId == _currentUserId,
      orElse: () => ReviewModel(
        id: '',
        bookId: '',
        userId: '',
        userName: '',
        reviewText: '',
        rating: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (existingReview.id.isNotEmpty) {
      throw Exception('You have already reviewed this book. Please update your existing review instead.');
    }

    final newReview = ReviewModel(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      bookId: bookId,
      userId: _currentUserId,
      userName: _currentUserName,
      userAvatarUrl: 'https://i.pravatar.cc/150?img=10',
      reviewText: reviewText,
      rating: rating,
      helpfulCount: 0,
      unhelpfulCount: 0,
      isEdited: false,
      isReported: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _reviews.add(newReview);
    return newReview;
  }

  @override
  Future<ReviewModel> updateReview({
    required String reviewId,
    required String reviewText,
    required double rating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final index = _reviews.indexWhere((review) => review.id == reviewId);
    
    if (index == -1) {
      throw Exception('Review not found');
    }

    final review = _reviews[index];
    
    // Check if user owns this review
    if (review.userId != _currentUserId) {
      throw Exception('You can only edit your own reviews');
    }

    final updatedReview = review.copyWith(
      reviewText: reviewText,
      rating: rating,
      isEdited: true,
      updatedAt: DateTime.now(),
    );

    _reviews[index] = updatedReview;
    return updatedReview;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final review = _reviews.firstWhere(
      (review) => review.id == reviewId,
      orElse: () => throw Exception('Review not found'),
    );

    // Check if user owns this review
    if (review.userId != _currentUserId) {
      throw Exception('You can only delete your own reviews');
    }

    _reviews.removeWhere((review) => review.id == reviewId);
  }

  @override
  Future<BookRatingModel> submitRating({
    required String bookId,
    required double rating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final existingRating = _ratings['${bookId}_$_currentUserId'];
    final now = DateTime.now();

    final newRating = BookRatingModel(
      id: existingRating?.id ?? 'rating_${now.millisecondsSinceEpoch}',
      bookId: bookId,
      userId: _currentUserId,
      rating: rating,
      createdAt: existingRating?.createdAt ?? now,
      updatedAt: now,
    );

    _ratings['${bookId}_$_currentUserId'] = newRating;
    return newRating;
  }

  @override
  Future<BookRatingModel?> getUserRating(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _ratings['${bookId}_$_currentUserId'];
  }

  @override
  Future<ReviewModel> voteHelpful(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _reviews.indexWhere((review) => review.id == reviewId);
    if (index == -1) {
      throw Exception('Review not found');
    }

    final review = _reviews[index];
    final voteKey = '${reviewId}_$_currentUserId';
    final existingVote = _userVotes[voteKey];

    ReviewModel updatedReview;
    
    if (existingVote == 'helpful') {
      // Remove helpful vote
      updatedReview = review.copyWith(
        helpfulCount: review.helpfulCount - 1,
        currentUserVote: null,
        clearCurrentUserVote: true,
      );
      _userVotes.remove(voteKey);
    } else if (existingVote == 'unhelpful') {
      // Change from unhelpful to helpful
      updatedReview = review.copyWith(
        helpfulCount: review.helpfulCount + 1,
        unhelpfulCount: review.unhelpfulCount - 1,
        currentUserVote: 'helpful',
      );
      _userVotes[voteKey] = 'helpful';
    } else {
      // Add new helpful vote
      updatedReview = review.copyWith(
        helpfulCount: review.helpfulCount + 1,
        currentUserVote: 'helpful',
      );
      _userVotes[voteKey] = 'helpful';
    }

    _reviews[index] = updatedReview;
    return updatedReview;
  }

  @override
  Future<ReviewModel> voteUnhelpful(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _reviews.indexWhere((review) => review.id == reviewId);
    if (index == -1) {
      throw Exception('Review not found');
    }

    final review = _reviews[index];
    final voteKey = '${reviewId}_$_currentUserId';
    final existingVote = _userVotes[voteKey];

    ReviewModel updatedReview;
    
    if (existingVote == 'unhelpful') {
      // Remove unhelpful vote
      updatedReview = review.copyWith(
        unhelpfulCount: review.unhelpfulCount - 1,
        currentUserVote: null,
        clearCurrentUserVote: true,
      );
      _userVotes.remove(voteKey);
    } else if (existingVote == 'helpful') {
      // Change from helpful to unhelpful
      updatedReview = review.copyWith(
        helpfulCount: review.helpfulCount - 1,
        unhelpfulCount: review.unhelpfulCount + 1,
        currentUserVote: 'unhelpful',
      );
      _userVotes[voteKey] = 'unhelpful';
    } else {
      // Add new unhelpful vote
      updatedReview = review.copyWith(
        unhelpfulCount: review.unhelpfulCount + 1,
        currentUserVote: 'unhelpful',
      );
      _userVotes[voteKey] = 'unhelpful';
    }

    _reviews[index] = updatedReview;
    return updatedReview;
  }

  @override
  Future<ReviewModel> removeVote(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _reviews.indexWhere((review) => review.id == reviewId);
    if (index == -1) {
      throw Exception('Review not found');
    }

    final review = _reviews[index];
    final voteKey = '${reviewId}_$_currentUserId';
    final existingVote = _userVotes[voteKey];

    if (existingVote == null) {
      return review; // No vote to remove
    }

    ReviewModel updatedReview;
    
    if (existingVote == 'helpful') {
      updatedReview = review.copyWith(
        helpfulCount: review.helpfulCount - 1,
        currentUserVote: null,
        clearCurrentUserVote: true,
      );
    } else {
      updatedReview = review.copyWith(
        unhelpfulCount: review.unhelpfulCount - 1,
        currentUserVote: null,
        clearCurrentUserVote: true,
      );
    }

    _userVotes.remove(voteKey);
    _reviews[index] = updatedReview;
    return updatedReview;
  }

  @override
  Future<void> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _reviews.indexWhere((review) => review.id == reviewId);
    if (index == -1) {
      throw Exception('Review not found');
    }

    // In a real app, this would send the report to moderation
    // For demo purposes, we'll just mark it as reported
    final review = _reviews[index];
    _reviews[index] = review.copyWith(isReported: true);
  }

  @override
  Future<ReviewModel?> getUserReview(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _reviews.firstWhere(
        (review) => review.bookId == bookId && review.userId == _currentUserId,
      );
    } catch (e) {
      return null;
    }
  }
}
