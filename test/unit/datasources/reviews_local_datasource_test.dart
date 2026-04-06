import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/data/datasources/reviews_local_datasource.dart';
import 'package:flutter_library/features/book_details/data/models/review_model.dart';

void main() {
  group('ReviewsLocalDataSource Tests', () {
    late ReviewsLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = ReviewsLocalDataSourceImpl();
    });

    final mockReview1 = ReviewModel(
      id: 'review_1',
      bookId: 'book_1',
      userId: 'user_1',
      userName: 'John Doe',
      rating: 4.5,
      reviewText: 'Great book!',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockReview2 = ReviewModel(
      id: 'review_2',
      bookId: 'book_1',
      userId: 'user_2',
      userName: 'Jane Smith',
      rating: 5.0,
      reviewText: 'Excellent read!',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockReview3 = ReviewModel(
      id: 'review_3',
      bookId: 'book_2',
      userId: 'user_1',
      userName: 'John Doe',
      rating: 3.0,
      reviewText: 'Okay book.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('CachedReviews', () {
      test('should not be expired when within TTL', () {
        final cached = CachedReviews(
          reviews: [mockReview1],
          cachedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ttl: const Duration(minutes: 10),
        );

        expect(cached.isExpired, isFalse);
      });

      test('should be expired when past TTL', () {
        final cached = CachedReviews(
          reviews: [mockReview1],
          cachedAt: DateTime.now().subtract(const Duration(minutes: 11)),
          ttl: const Duration(minutes: 10),
        );

        expect(cached.isExpired, isTrue);
      });

      test('should use default TTL of 10 minutes when not specified', () {
        final cached = CachedReviews(
          reviews: [mockReview1],
          cachedAt: DateTime.now(),
        );

        expect(cached.ttl, equals(const Duration(minutes: 10)));
      });
    });

    group('getCachedReviews', () {
      test('should return empty list when cache is empty', () async {
        final result = await dataSource.getCachedReviews('book_1');
        expect(result, isEmpty);
      });

      test('should return cached reviews when not expired', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(2));
        expect(result, containsAll([mockReview1, mockReview2]));
      });

      test('should return empty list and remove expired entry', () async {
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1, mockReview2],
          ttl: const Duration(milliseconds: 1),
        );
        
        await Future.delayed(const Duration(milliseconds: 10));
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, isEmpty);
      });

      test('should return empty list for non-existent book ID', () async {
        await dataSource.cacheReviews('book_1', [mockReview1]);
        final result = await dataSource.getCachedReviews('non_existent_book');
        
        expect(result, isEmpty);
      });
    });

    group('cacheReviews', () {
      test('should cache reviews with default TTL', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(2));
        expect(result, containsAll([mockReview1, mockReview2]));
      });

      test('should cache reviews with custom TTL', () async {
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1],
          ttl: const Duration(minutes: 20),
        );
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(1));
        expect(result.first, equals(mockReview1));
      });

      test('should overwrite existing cache entry', () async {
        await dataSource.cacheReviews('book_1', [mockReview1]);
        await dataSource.cacheReviews('book_1', [mockReview2]);
        
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(1));
        expect(result.first, equals(mockReview2));
      });

      test('should cache empty reviews list', () async {
        await dataSource.cacheReviews('book_1', []);
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, isEmpty);
      });

      test('should cache reviews for multiple books', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        await dataSource.cacheReviews('book_2', [mockReview3]);
        
        final result1 = await dataSource.getCachedReviews('book_1');
        final result2 = await dataSource.getCachedReviews('book_2');
        
        expect(result1, hasLength(2));
        expect(result2, hasLength(1));
        expect(result2.first, equals(mockReview3));
      });
    });

    group('addReviewToCache', () {
      test('should add review to existing cached reviews', () async {
        await dataSource.cacheReviews('book_1', [mockReview1]);
        await dataSource.addReviewToCache(mockReview2);
        
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(2));
        expect(result, containsAll([mockReview1, mockReview2]));
      });

      test('should create new cache entry when book not cached', () async {
        await dataSource.addReviewToCache(mockReview1);
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(1));
        expect(result.first, equals(mockReview1));
      });

      test('should not add duplicate review', () async {
        await dataSource.cacheReviews('book_1', [mockReview1]);
        await dataSource.addReviewToCache(mockReview1);
        
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(1));
        expect(result.first, equals(mockReview1));
      });

      test('should add review to expired cache and refresh TTL', () async {
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1],
          ttl: const Duration(milliseconds: 1),
        );
        
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.addReviewToCache(mockReview2);
        
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(1));
        expect(result.first, equals(mockReview2));
      });
    });

    group('updateReviewInCache', () {
      test('should update existing review in cache', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        
        final updatedReview = ReviewModel(
          id: 'review_1',
          bookId: 'book_1',
          userId: 'user_1',
          userName: 'John Doe',
          rating: 3.0,
          reviewText: 'Updated comment',
          createdAt: mockReview1.createdAt,
          updatedAt: DateTime.now(),
        );
        
        await dataSource.updateReviewInCache(updatedReview);
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(2));
        expect(result.any((r) => r.id == 'review_1' && r.reviewText == 'Updated comment'), isTrue);
      });

      test('should do nothing when review not found in cache', () async {
        await dataSource.cacheReviews('book_1', [mockReview1]);
        
        final nonExistentReview = ReviewModel(
          id: 'review_999',
          bookId: 'book_1',
          userId: 'user_999',
          userName: 'Non Existent',
          rating: 1.0,
          reviewText: 'Not found',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await dataSource.updateReviewInCache(nonExistentReview);
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(1));
        expect(result.first, equals(mockReview1));
      });

      test('should do nothing when book not cached', () async {
        await dataSource.updateReviewInCache(mockReview1);
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, isEmpty);
      });
    });

    group('removeReviewFromCache', () {
      test('should remove review from cache', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        await dataSource.removeReviewFromCache('review_1');
        
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(1));
        expect(result.first.id, equals('review_2'));
      });

      test('should do nothing when review not found', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        await dataSource.removeReviewFromCache('review_999');
        
        final result = await dataSource.getCachedReviews('book_1');
        
        expect(result, hasLength(2));
      });

      test('should handle removing from empty cache', () async {
        await expectLater(dataSource.removeReviewFromCache('review_1'), completes);
      });
    });

    group('clearCache', () {
      test('should remove all cached reviews', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        await dataSource.cacheReviews('book_2', [mockReview3]);
        
        await dataSource.clearCache();
        
        final result1 = await dataSource.getCachedReviews('book_1');
        final result2 = await dataSource.getCachedReviews('book_2');
        
        expect(result1, isEmpty);
        expect(result2, isEmpty);
      });

      test('should work when cache is already empty', () async {
        await expectLater(dataSource.clearCache(), completes);
      });
    });

    group('clearCacheForBook', () {
      test('should remove cache for specific book only', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        await dataSource.cacheReviews('book_2', [mockReview3]);
        
        await dataSource.clearCacheForBook('book_1');
        
        final result1 = await dataSource.getCachedReviews('book_1');
        final result2 = await dataSource.getCachedReviews('book_2');
        
        expect(result1, isEmpty);
        expect(result2, hasLength(1));
        expect(result2.first, equals(mockReview3));
      });

      test('should work when book is not cached', () async {
        await expectLater(dataSource.clearCacheForBook('non_existent'), completes);
      });
    });

    group('clearExpiredCache', () {
      test('should remove only expired entries', () async {
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1],
          ttl: const Duration(milliseconds: 1),
        );
        await dataSource.cacheReviews('book_2', [mockReview3]);
        
        await Future.delayed(const Duration(milliseconds: 10));
        await dataSource.clearExpiredCache();
        
        final result1 = await dataSource.getCachedReviews('book_1');
        final result2 = await dataSource.getCachedReviews('book_2');
        
        expect(result1, isEmpty);
        expect(result2, hasLength(1));
        expect(result2.first, equals(mockReview3));
      });

      test('should work when no entries are expired', () async {
        await dataSource.cacheReviews('book_1', [mockReview1]);
        await dataSource.cacheReviews('book_2', [mockReview3]);
        
        await dataSource.clearExpiredCache();
        
        final result1 = await dataSource.getCachedReviews('book_1');
        final result2 = await dataSource.getCachedReviews('book_2');
        
        expect(result1, hasLength(1));
        expect(result2, hasLength(1));
      });

      test('should work when cache is empty', () async {
        await expectLater(dataSource.clearExpiredCache(), completes);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle updateReviewInCache when cache is expired', () async {
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1],
          ttl: const Duration(milliseconds: 1),
        );
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        final updatedReview = ReviewModel(
          id: 'review_1',
          bookId: 'book_1',
          userId: 'user_1',
          userName: 'John Doe',
          rating: 3.0,
          reviewText: 'Updated comment',
          createdAt: mockReview1.createdAt,
          updatedAt: DateTime.now(),
        );
        
        await dataSource.updateReviewInCache(updatedReview);
        final result = await dataSource.getCachedReviews('book_1');
        
        // Should remain empty since cache was expired
        expect(result, isEmpty);
      });

      test('should handle removeReviewFromCache across multiple books', () async {
        await dataSource.cacheReviews('book_1', [mockReview1, mockReview2]);
        await dataSource.cacheReviews('book_2', [mockReview3]);
        
        // Add a review with same ID to book_2 (edge case)
        final duplicateIdReview = ReviewModel(
          id: 'review_1', // Same ID as mockReview1
          bookId: 'book_2',
          userId: 'user_3',
          userName: 'User Three',
          rating: 2.0,
          reviewText: 'Duplicate ID review',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await dataSource.addReviewToCache(duplicateIdReview);
        
        // Remove review should affect both books
        await dataSource.removeReviewFromCache('review_1');
        
        final result1 = await dataSource.getCachedReviews('book_1');
        final result2 = await dataSource.getCachedReviews('book_2');
        
        expect(result1, hasLength(1));
        expect(result1.first.id, equals('review_2'));
        expect(result2, hasLength(1));
        expect(result2.first.id, equals('review_3'));
      });

      test('should handle removeReviewFromCache with expired entries', () async {
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1, mockReview2],
          ttl: const Duration(milliseconds: 1),
        );
        await dataSource.cacheReviews('book_2', [mockReview3]);
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        // This should skip expired entries
        await dataSource.removeReviewFromCache('review_1');
        
        final result1 = await dataSource.getCachedReviews('book_1');
        final result2 = await dataSource.getCachedReviews('book_2');
        
        expect(result1, isEmpty); // Was expired, now removed
        expect(result2, hasLength(1));
        expect(result2.first.id, equals('review_3'));
      });

      test('should preserve cache timestamps when adding non-duplicate reviews', () async {
        // Cache initial review
        await dataSource.cacheReviews('book_1', [mockReview1]);
        
        // Add different review
        await dataSource.addReviewToCache(mockReview2);
        
        final result = await dataSource.getCachedReviews('book_1');
        expect(result, hasLength(2));
        expect(result, containsAll([mockReview1, mockReview2]));
      });

      test('should handle clearExpiredCache with mixed expired and non-expired entries', () async {
        // Create one expired entry
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1],
          ttl: const Duration(milliseconds: 1),
        );
        
        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 10));
        
        // Create fresh entry
        await dataSource.cacheReviews('book_2', [mockReview2]);
        
        // Create another expired entry
        await dataSource.cacheReviews(
          'book_3',
          [mockReview3],
          ttl: const Duration(milliseconds: 1),
        );
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        await dataSource.clearExpiredCache();
        
        final result1 = await dataSource.getCachedReviews('book_1');
        final result2 = await dataSource.getCachedReviews('book_2');
        final result3 = await dataSource.getCachedReviews('book_3');
        
        expect(result1, isEmpty); // Expired
        expect(result2, hasLength(1)); // Still fresh
        expect(result3, isEmpty); // Expired
      });

      test('should handle zero-duration TTL (immediately expired)', () async {
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1],
          ttl: Duration.zero,
        );
        
        // Add a small delay to ensure the time check passes
        await Future.delayed(const Duration(milliseconds: 1));
        
        final result = await dataSource.getCachedReviews('book_1');
        expect(result, isEmpty);
      });

      test('should handle very long TTL', () async {
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1],
          ttl: const Duration(days: 365),
        );
        
        final result = await dataSource.getCachedReviews('book_1');
        expect(result, hasLength(1));
        expect(result.first, equals(mockReview1));
      });

      test('should handle addReviewToCache preserving original cache time for non-expired entries', () async {
        // Cache initial review
        await dataSource.cacheReviews('book_1', [mockReview1]);
        
        // Add another review - should preserve original cache time
        await dataSource.addReviewToCache(mockReview2);
        
        final result = await dataSource.getCachedReviews('book_1');
        expect(result, hasLength(2));
        expect(result, containsAll([mockReview1, mockReview2]));
      });
    });

    group('Integration Tests', () {
      test('should handle complex review operations', () async {
        // Initial cache
        await dataSource.cacheReviews('book_1', [mockReview1]);
        
        // Add a review
        await dataSource.addReviewToCache(mockReview2);
        expect((await dataSource.getCachedReviews('book_1')), hasLength(2));
        
        // Update a review
        final updatedReview = ReviewModel(
          id: 'review_1',
          bookId: 'book_1',
          userId: 'user_1',
          userName: 'John Doe',
          rating: 5.0,
          reviewText: 'Amazing book!',
          createdAt: mockReview1.createdAt,
          updatedAt: DateTime.now(),
        );
        await dataSource.updateReviewInCache(updatedReview);
        
        final afterUpdate = await dataSource.getCachedReviews('book_1');
        expect(afterUpdate.any((r) => r.reviewText == 'Amazing book!'), isTrue);
        
        // Remove a review
        await dataSource.removeReviewFromCache('review_2');
        expect((await dataSource.getCachedReviews('book_1')), hasLength(1));
        
        // Clear cache for book
        await dataSource.clearCacheForBook('book_1');
        expect((await dataSource.getCachedReviews('book_1')), isEmpty);
      });

      test('should handle cache lifecycle with multiple operations and expiration', () async {
        // Cache reviews with short TTL
        await dataSource.cacheReviews(
          'book_1',
          [mockReview1],
          ttl: const Duration(milliseconds: 50),
        );
        
        // Add review while cache is fresh
        await dataSource.addReviewToCache(mockReview2);
        expect((await dataSource.getCachedReviews('book_1')), hasLength(2));
        
        // Wait for cache to expire
        await Future.delayed(const Duration(milliseconds: 60));
        
        // Try to update - should not work on expired cache
        final updatedReview = ReviewModel(
          id: 'review_1',
          bookId: 'book_1',
          userId: 'user_1',
          userName: 'John Doe',
          rating: 1.0,
          reviewText: 'Should not update',
          createdAt: mockReview1.createdAt,
          updatedAt: DateTime.now(),
        );
        await dataSource.updateReviewInCache(updatedReview);
        
        // Cache should be empty due to expiration
        expect((await dataSource.getCachedReviews('book_1')), isEmpty);
        
        // Add review to expired cache - should create new entry with default TTL
        final newReview = ReviewModel(
          id: 'review_4',
          bookId: 'book_1', // Same book as the expired cache
          userId: 'user_4',
          userName: 'User Four',
          rating: 4.0,
          reviewText: 'New review after expiration',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await dataSource.addReviewToCache(newReview);
        final result = await dataSource.getCachedReviews('book_1');
        expect(result, hasLength(1));
        expect(result.first, equals(newReview));
      });
    });
  });
}
