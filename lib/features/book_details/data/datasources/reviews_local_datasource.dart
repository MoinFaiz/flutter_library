import 'package:flutter_library/features/book_details/data/models/review_model.dart';

/// Cache entry with expiration time
class CachedReviews {
  final List<ReviewModel> reviews;
  final DateTime cachedAt;
  final Duration ttl;

  CachedReviews({
    required this.reviews,
    required this.cachedAt,
    this.ttl = const Duration(minutes: 10), // Default 10 minutes TTL for reviews
  });

  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));
}

/// Local data source for caching reviews
abstract class ReviewsLocalDataSource {
  /// Get cached reviews for a book
  Future<List<ReviewModel>> getCachedReviews(String bookId);
  
  /// Cache reviews for a book
  Future<void> cacheReviews(String bookId, List<ReviewModel> reviews, {Duration? ttl});
  
  /// Add a single review to cache
  Future<void> addReviewToCache(ReviewModel review);
  
  /// Update a review in cache
  Future<void> updateReviewInCache(ReviewModel review);
  
  /// Remove a review from cache
  Future<void> removeReviewFromCache(String reviewId);
  
  /// Clear all cached reviews
  Future<void> clearCache();
  
  /// Clear cached reviews for a specific book
  Future<void> clearCacheForBook(String bookId);
  
  /// Clear expired cache entries
  Future<void> clearExpiredCache();
}

/// Implementation of ReviewsLocalDataSource using in-memory cache
class ReviewsLocalDataSourceImpl implements ReviewsLocalDataSource {
  final Map<String, CachedReviews> _cache = {};

  @override
  Future<List<ReviewModel>> getCachedReviews(String bookId) async {
    final cached = _cache[bookId];
    if (cached != null && !cached.isExpired) {
      return cached.reviews;
    }
    
    // Remove expired entry
    if (cached != null && cached.isExpired) {
      _cache.remove(bookId);
    }
    
    return [];
  }

  @override
  Future<void> cacheReviews(String bookId, List<ReviewModel> reviews, {Duration? ttl}) async {
    _cache[bookId] = CachedReviews(
      reviews: reviews,
      cachedAt: DateTime.now(),
      ttl: ttl ?? const Duration(minutes: 10),
    );
  }

  @override
  Future<void> addReviewToCache(ReviewModel review) async {
    final cached = _cache[review.bookId];
    
    if (cached != null && !cached.isExpired) {
      // Check for duplicate before adding
      if (!cached.reviews.any((r) => r.id == review.id)) {
        final updatedReviews = [...cached.reviews, review];
        _cache[review.bookId] = CachedReviews(
          reviews: updatedReviews,
          cachedAt: cached.cachedAt,
          ttl: cached.ttl,
        );
      }
    } else {
      // Create new cache entry or refresh expired cache
      _cache[review.bookId] = CachedReviews(
        reviews: [review],
        cachedAt: DateTime.now(),
        ttl: const Duration(minutes: 10),
      );
    }
  }

  @override
  Future<void> updateReviewInCache(ReviewModel review) async {
    final cached = _cache[review.bookId];
    if (cached != null && !cached.isExpired) {
      final updatedReviews = cached.reviews.map((r) => r.id == review.id ? review : r).toList();
      _cache[review.bookId] = CachedReviews(
        reviews: updatedReviews,
        cachedAt: cached.cachedAt,
        ttl: cached.ttl,
      );
    }
  }

  @override
  Future<void> removeReviewFromCache(String reviewId) async {
    for (final bookId in _cache.keys) {
      final cached = _cache[bookId]!;
      if (!cached.isExpired) {
        final updatedReviews = cached.reviews.where((r) => r.id != reviewId).toList();
        _cache[bookId] = CachedReviews(
          reviews: updatedReviews,
          cachedAt: cached.cachedAt,
          ttl: cached.ttl,
        );
      }
    }
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
  }

  @override
  Future<void> clearCacheForBook(String bookId) async {
    _cache.remove(bookId);
  }

  @override
  Future<void> clearExpiredCache() async {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }
}
