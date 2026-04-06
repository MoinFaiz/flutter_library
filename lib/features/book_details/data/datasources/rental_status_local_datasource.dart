import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';

/// Cache entry with expiration time
class CachedRentalStatus {
  final RentalStatusModel status;
  final DateTime cachedAt;
  final Duration ttl;

  CachedRentalStatus({
    required this.status,
    required this.cachedAt,
    this.ttl = const Duration(minutes: 5), // Default 5 minutes TTL
  });

  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));
}

/// Local data source for caching rental status
abstract class RentalStatusLocalDataSource {
  /// Get cached rental status for a book
  Future<RentalStatusModel?> getCachedRentalStatus(String bookId);
  
  /// Cache rental status for a book
  Future<void> cacheRentalStatus(RentalStatusModel status, {Duration? ttl});
  
  /// Get cached rental status for multiple books
  Future<List<RentalStatusModel>> getCachedRentalStatusBatch(List<String> bookIds);
  
  /// Clear all cached rental statuses
  Future<void> clearCache();
  
  /// Clear cached rental status for a specific book
  Future<void> clearCacheForBook(String bookId);
  
  /// Clear expired cache entries
  Future<void> clearExpiredCache();
}

/// Implementation of RentalStatusLocalDataSource using in-memory cache
class RentalStatusLocalDataSourceImpl implements RentalStatusLocalDataSource {
  final Map<String, CachedRentalStatus> _cache = {};

  @override
  Future<RentalStatusModel?> getCachedRentalStatus(String bookId) async {
    final cached = _cache[bookId];
    if (cached != null && !cached.isExpired) {
      return cached.status;
    }
    
    // Remove expired entry
    if (cached != null && cached.isExpired) {
      _cache.remove(bookId);
    }
    
    return null;
  }

  @override
  Future<void> cacheRentalStatus(RentalStatusModel status, {Duration? ttl}) async {
    _cache[status.bookId] = CachedRentalStatus(
      status: status,
      cachedAt: DateTime.now(),
      ttl: ttl ?? const Duration(minutes: 5),
    );
  }

  @override
  Future<List<RentalStatusModel>> getCachedRentalStatusBatch(List<String> bookIds) async {
    final statuses = <RentalStatusModel>[];
    
    for (final bookId in bookIds) {
      final cached = _cache[bookId];
      if (cached != null && !cached.isExpired) {
        statuses.add(cached.status);
      } else if (cached != null && cached.isExpired) {
        // Remove expired entry
        _cache.remove(bookId);
      }
    }
    
    return statuses;
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
