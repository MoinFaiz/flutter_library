# Data Architecture Improvements

## Issues Addressed

### 1. **Favorites Storage Strategy**

**Problem:** Favorites were only stored locally, causing data loss when users:
- Log out and log back in
- Reinstall the application
- Switch devices
- Use the web version

**Solution:** Server-First Approach
- **Server**: Primary source of truth for user favorites
- **Local**: Backup/cache for offline access
- **Sync**: Automatic synchronization between server and local storage
- **Fallback**: Local storage serves data when server is unavailable

### 2. **Cache Invalidation Strategy**

**Problem:** No cache invalidation mechanism led to:
- Stale data being served indefinitely
- No way to force refresh
- Poor user experience with outdated content
- Favorites not syncing across sessions

**Solution:** Multi-Tier Time-Based Cache with Manual Override
- **Books Cache**: Expires after 1 hour (less frequent changes)
- **Favorites Cache**: Expires after 30 minutes (frequent user changes)
- **Automatic Refresh**: Invalid cache triggers fresh remote fetch
- **Manual Invalidation**: Force refresh capability for both data types
- **Change-Based Invalidation**: Favorites cache refreshed on toggle operations
- **Offline Support**: Cache serves as fallback when network fails

## Implementation Details

### Cache Management
```dart
// Books cache validity check
final isCacheValid = await localDataSource.isCacheValid();

// Favorites cache validity check  
final isFavoritesCacheValid = await localDataSource.isFavoritesCacheValid();

// Manual cache invalidation
await repository.invalidateCache(); // Books cache
await repository.invalidateFavoritesCache(); // Favorites cache

// Cache timestamp tracking
await sharedPreferences.setInt(cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
await sharedPreferences.setInt(favoritesTimestampKey, DateTime.now().millisecondsSinceEpoch);
```

### Favorites Synchronization
```dart
// Smart caching with validity check
final isFavoritesCacheValid = await localDataSource.isFavoritesCacheValid();
if (isFavoritesCacheValid) {
  return await localDataSource.getFavoriteBookIds(); // Use cache
}

// Server-first approach for fresh data
final serverFavorites = await remoteDataSource.getFavoriteBookIds();
await localDataSource.saveFavoriteBookIds(serverFavorites); // Update cache

// Invalidate on changes
await localDataSource.invalidateFavoritesCache();
await localDataSource.saveFavoriteBookIds(currentFavorites); // Refresh with timestamp
```

### Data Flow
1. **Check cache validity** → Use cache if valid (different timeouts for books vs favorites)
2. **Fetch from server** → Update local cache with timestamp
3. **Sync favorites** → Server → Local backup (30min cache)
4. **Handle changes** → Invalidate relevant cache on modifications
5. **Handle errors** → Fallback to local data (even if expired)

## Benefits

### For Users
- **Cross-device sync**: Favorites available everywhere
- **Offline support**: App works without internet
- **Fresh content**: Automatic content updates
- **Fast loading**: Cached data for quick access

### For Developers
- **Clean architecture**: Clear separation of concerns
- **Error resilience**: Multiple fallback strategies
- **Performance**: Efficient caching reduces API calls
- **Maintainability**: Well-documented data flow

## Production Considerations

### API Endpoints Needed
```
GET /user/favorites - Get user's favorite book IDs
POST /books/{id}/favorite - Toggle book favorite status
GET /books - Get all books with user's favorite status
GET /books/search?q={query} - Search books
```

### Error Handling
- Network timeouts
- Server errors (5xx)
- Authentication failures
- Data corruption
- Cache inconsistencies

### Performance Optimizations
- Pagination for large book lists
- Incremental updates for favorites
- Background sync for favorites
- Optimistic UI updates

## Testing Strategy

### Unit Tests
- Cache validity logic
- Favorites synchronization
- Error handling scenarios
- Data transformation

### Integration Tests
- Server-local data sync
- Network failure scenarios
- Cache invalidation flows
- Cross-device consistency

## Favorites Cache Invalidation Implementation

### Cache Strategy Summary
- **Books Cache**: 1 hour validity (content changes less frequently)
- **Favorites Cache**: 30 minutes validity (user changes more frequently)

### Invalidation Triggers
1. **Time Expiry**: Automatic after 30 minutes for favorites
2. **User Actions**: Toggle favorite operations
3. **Manual Refresh**: Developer/user initiated refresh
4. **Server Sync**: When fetching fresh data from server

### Benefits
- **Responsive UI**: Quick access to frequently accessed favorites
- **Data Freshness**: Regular sync ensures up-to-date favorites
- **Cross-device Sync**: Changes propagate within 30 minutes
- **Offline Resilience**: Cached favorites available offline
- **Performance**: Reduced API calls for frequently accessed data

### Implementation Details
```dart
// Different cache durations
static const Duration cacheValidityDuration = Duration(hours: 1); // Books
static const Duration favoritesValidityDuration = Duration(minutes: 30); // Favorites

// Separate timestamp tracking
static const String cacheTimestampKey = 'CACHE_TIMESTAMP';
static const String favoritesTimestampKey = 'FAVORITES_TIMESTAMP';
```

This improved architecture provides a robust, scalable foundation for the library app with proper data management and user experience considerations.
