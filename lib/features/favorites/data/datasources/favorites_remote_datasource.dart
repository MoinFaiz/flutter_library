import 'package:dio/dio.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<String>> getFavoriteBookIds();
  Future<void> addToFavorites(String bookId);
  Future<void> removeFromFavorites(String bookId);
  Future<bool> isFavorite(String bookId);
  Future<void> syncFavorites(List<String> localFavoriteIds);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final Dio dio;
  
  FavoritesRemoteDataSourceImpl({required this.dio});
  
  @override
  Future<List<String>> getFavoriteBookIds() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In a real app, you would make an API call to get user's favorites
    // final response = await dio.get('/user/favorites');
    // return List<String>.from(response.data['favoriteBookIds']);
    
    // Mock data - simulate server favorites
    // In production, this would fetch from the authenticated user's profile
    return _mockServerFavorites;
  }

  @override
  Future<void> addToFavorites(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // In a real app, you would make an API call to add to favorites
    // await dio.post('/user/favorites', data: {'bookId': bookId});
    
    // Mock implementation - add to server favorites
    if (!_mockServerFavorites.contains(bookId)) {
      _mockServerFavorites.add(bookId);
    }
  }

  @override
  Future<void> removeFromFavorites(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // In a real app, you would make an API call to remove from favorites
    // await dio.delete('/user/favorites/$bookId');
    
    // Mock implementation - remove from server favorites
    _mockServerFavorites.remove(bookId);
  }

  @override
  Future<bool> isFavorite(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Validate input
    if (bookId.isEmpty) {
      return false;
    }
    
    // In a real app, you would make an API call to check favorite status
    // final response = await dio.get('/user/favorites/$bookId');
    // return response.data['isFavorite'] as bool;
    
    // Mock implementation
    return _mockServerFavorites.contains(bookId);
  }

  @override
  Future<void> syncFavorites(List<String> localFavoriteIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real app, you would sync local favorites with server
    // This would typically involve:
    // 1. Sending local favorites to server
    // 2. Getting server favorites
    // 3. Resolving conflicts (usually server wins)
    // 
    // await dio.put('/user/favorites/sync', data: {
    //   'localFavorites': localFavoriteIds,
    //   'timestamp': DateTime.now().toIso8601String()
    // });
    
    // Mock implementation - merge favorites (simple union)
    final serverFavorites = await getFavoriteBookIds();
    final mergedFavorites = <String>{...serverFavorites, ...localFavoriteIds}.toList();
    
    // Update server with merged favorites
    _mockServerFavorites.clear();
    _mockServerFavorites.addAll(mergedFavorites);
  }
}

// Mock server favorites - in production this would be stored on the server
// This simulates the user's favorites stored in their profile on the server
final List<String> _mockServerFavorites = [
  // Start with some sample favorites to demonstrate cross-device sync
  '2', // Clean Architecture
  '5', // State Management in Flutter
];
