import 'dart:convert';

import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BookLocalDataSource {
  Future<List<BookModel>> getCachedBooks();
  Future<void> cacheBooks(List<BookModel> books);
  Future<bool> isCacheValid();
  Future<void> invalidateCache();
  Future<DateTime?> getLastCacheTime();
}

class BookLocalDataSourceImpl implements BookLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String cachedBooksKey = 'CACHED_BOOKS';
  static const String cacheTimestampKey = 'CACHE_TIMESTAMP';
  static const Duration cacheValidityDuration = Duration(hours: 1); // Cache valid for 1 hour
  
  BookLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<BookModel>> getCachedBooks() async {
    final jsonString = sharedPreferences.getString(cachedBooksKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => BookModel.fromJson(json)).toList();
    } else {
      throw CacheException('No cached books found');
    }
  }

  @override
  Future<void> cacheBooks(List<BookModel> books) async {
    final jsonString = json.encode(books.map((book) => book.toJson()).toList());
    await sharedPreferences.setString(cachedBooksKey, jsonString);
    // Store cache timestamp
    await sharedPreferences.setInt(cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<bool> isCacheValid() async {
    final timestamp = sharedPreferences.getInt(cacheTimestampKey);
    if (timestamp == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    return now.difference(cacheTime) < cacheValidityDuration;
  }

  @override
  Future<void> invalidateCache() async {
    await sharedPreferences.remove(cachedBooksKey);
    await sharedPreferences.remove(cacheTimestampKey);
  }

  @override
  Future<DateTime?> getLastCacheTime() async {
    final timestamp = sharedPreferences.getInt(cacheTimestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
