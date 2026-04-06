import 'package:shared_preferences/shared_preferences.dart';

/// Data source responsible for user favorites management
abstract class FavoritesLocalDataSource {
  Future<List<String>> getFavoriteBookIds();
  Future<void> saveFavoriteBookIds(List<String> favoriteIds);
  Future<bool> isFavorite(String bookId);
  Future<void> addToFavorites(String bookId);
  Future<void> removeFromFavorites(String bookId);
  Future<bool> isFavoritesCacheValid();
  Future<void> invalidateFavoritesCache();
  Future<DateTime?> getLastFavoritesCacheTime();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String favoriteIdsKey = 'FAVORITE_BOOK_IDS';
  static const String favoritesTimestampKey = 'FAVORITES_TIMESTAMP';
  static const Duration favoritesValidityDuration = Duration(minutes: 30);

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getFavoriteBookIds() async {
    final favoriteIds = sharedPreferences.getStringList(favoriteIdsKey) ?? [];
    return favoriteIds;
  }

  @override
  Future<void> saveFavoriteBookIds(List<String> favoriteIds) async {
    await sharedPreferences.setStringList(favoriteIdsKey, favoriteIds);
    await sharedPreferences.setInt(favoritesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<bool> isFavorite(String bookId) async {
    final favoriteIds = await getFavoriteBookIds();
    return favoriteIds.contains(bookId);
  }

  @override
  Future<void> addToFavorites(String bookId) async {
    final favoriteIds = await getFavoriteBookIds();
    if (!favoriteIds.contains(bookId)) {
      favoriteIds.add(bookId);
      await saveFavoriteBookIds(favoriteIds);
    }
  }

  @override
  Future<void> removeFromFavorites(String bookId) async {
    final favoriteIds = await getFavoriteBookIds();
    if (favoriteIds.contains(bookId)) {
      favoriteIds.remove(bookId);
      await saveFavoriteBookIds(favoriteIds);
    }
  }

  @override
  Future<bool> isFavoritesCacheValid() async {
    final timestamp = sharedPreferences.getInt(favoritesTimestampKey);
    if (timestamp == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    return now.difference(cacheTime) < favoritesValidityDuration;
  }

  @override
  Future<void> invalidateFavoritesCache() async {
    await sharedPreferences.remove(favoriteIdsKey);
    await sharedPreferences.remove(favoritesTimestampKey);
  }

  @override
  Future<DateTime?> getLastFavoritesCacheTime() async {
    final timestamp = sharedPreferences.getInt(favoritesTimestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}
