# Favorites Remote Sync Architecture

## Overview

The favorites feature now supports both local persistence and remote synchronization, allowing users to access their favorites across devices and after app reinstallation.

## Architecture Components

### Data Sources

#### 1. `FavoritesLocalDataSource`
- **Purpose**: Local persistence using SharedPreferences
- **Responsibilities**:
  - Store/retrieve favorite book IDs locally
  - Provide immediate access for offline functionality
  - Cache management with timestamps

#### 2. `FavoritesRemoteDataSource` (NEW)
- **Purpose**: Server synchronization using API calls
- **Responsibilities**:
  - Sync favorites with remote server
  - Handle cross-device synchronization
  - Provide backup for app reinstallation scenarios

### Repository Layer

#### `FavoritesRepository`
- **Strategy**: Local-first with background sync
- **Data Flow**:
  1. All operations work with local storage first (immediate response)
  2. Remote operations happen in background (fire-and-forget)
  3. Manual sync available through `syncWithServer()`

### Sync Strategies

#### 1. **Immediate Local Updates**
```dart
// User adds favorite
await addToFavorites(bookId);
// ✅ Local storage updated immediately
// 🔄 Remote sync happens in background
```

#### 2. **Background Sync**
- Remote operations don't block UI
- Errors are logged but don't fail the operation
- Can implement retry logic or queue for later sync

#### 3. **Manual Sync**
```dart
// Explicit sync with server
await syncWithServer();
// Merges local and server favorites
// Server favorites take precedence in conflicts
```

## Usage Examples

### Basic Operations (Local + Remote)
```dart
// Add to favorites (local first, remote background)
await favoritesRepository.addToFavorites('book123');

// Remove from favorites (local first, remote background)
await favoritesRepository.removeFromFavorites('book123');

// Toggle favorite (local first, remote background)
await favoritesRepository.toggleFavorite('book123');
```

### Sync Operations
```dart
// Full sync with server (merge strategy)
await favoritesRepository.syncWithServer();

// Upload local favorites to server
await favoritesRepository.uploadFavoritesToServer();

// Get server favorites without affecting local
final serverFavorites = await favoritesRepository.getServerFavorites();
```

### Use Cases
```dart
// Sync on app start
final syncUseCase = SyncFavoritesUseCase(favoritesRepository);
await syncUseCase();

// Upload when setting up new account
final uploadUseCase = UploadFavoritesToServerUseCase(favoritesRepository);
await uploadUseCase();
```

## Benefits

1. **Cross-Device Sync**: Favorites available on all user devices
2. **Offline Support**: Works without internet connection
3. **App Reinstallation**: Favorites restored from server
4. **Immediate Response**: UI updates instantly with local operations
5. **Reliable Sync**: Background sync ensures data consistency

## Server API Endpoints (Production)

```http
GET /user/favorites
POST /user/favorites
DELETE /user/favorites/{bookId}
PATCH /user/favorites/{bookId}
PUT /user/favorites/sync
```

## Implementation Notes

- Mock server data provided for development
- Error handling includes retry strategies
- Conflict resolution favors server data
- Local cache serves as offline fallback
- Sync can be triggered manually or automatically
