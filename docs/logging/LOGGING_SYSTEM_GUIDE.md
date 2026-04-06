# Logging, Tracing & Audit System Documentation

## Overview

The Flutter Library app now has a comprehensive logging, tracing, and audit system that provides:

1. **Hierarchical Logging Levels** - Control verbosity from ERROR to TRACE
2. **Remote Configuration** - Enable/disable logging and tracing from server
3. **Performance Monitoring** - Track method execution times
4. **Audit Tracking** - Monitor user actions and feature usage
5. **Remote Log Transmission** - Send logs to server with batching
6. **Complete Disable Option** - Turn off all logging functionality

---

## Architecture

### Directory Structure

```
lib/core/logging/
├── domain/
│   ├── entities/
│   │   ├── log_level.dart          # Log level enum (NONE to TRACE)
│   │   ├── log_entry.dart          # Log entry entity
│   │   ├── log_config.dart         # Configuration entity
│   │   ├── performance_metric.dart  # Performance tracking
│   │   └── audit_event.dart        # User action tracking
│   ├── repositories/
│   │   └── logging_repository.dart
│   └── usecases/
│       ├── log_message.dart
│       ├── track_audit_event.dart
│       ├── track_performance.dart
│       ├── sync_logs.dart
│       └── fetch_logging_config.dart
├── data/
│   ├── models/
│   ├── datasources/
│   │   ├── logging_local_data_source.dart
│   │   ├── logging_remote_data_source.dart
│   │   └── implementations...
│   └── repositories/
│       └── logging_repository_impl.dart
└── services/
    ├── app_logger.dart              # Main logger service
    └── logging_config_service.dart  # Remote config manager
```

---

## Logging Levels

### Hierarchy (from least to most verbose):

```dart
LogLevel.none     // Completely disabled
LogLevel.error    // Critical errors only
LogLevel.warning  // Warnings and errors
LogLevel.info     // General app flow (default)
LogLevel.debug    // Detailed debugging
LogLevel.trace    // Very detailed traces
```

### Configuration

Logging levels can be set:
- **Globally** for entire app
- **Per Feature** (e.g., books, cart, favorites)
- **Per User** (enable tracing for specific users)

---

## How to Use the Logger

### 1. Inject AppLogger

```dart
class SomeBloc {
  final AppLogger logger;
  
  SomeBloc({required this.logger});
  
  // Access via dependency injection: sl<AppLogger>()
}
```

### 2. Basic Logging

```dart
// Trace - most detailed
await logger.trace(
  'User entered search query',
  feature: 'books',
  action: 'search_input',
  metadata: {'query': searchQuery},
);

// Debug
await logger.debug(
  'Fetching books from API',
  feature: 'books',
  metadata: {'page': 1, 'limit': 20},
);

// Info
await logger.info(
  'Books loaded successfully',
  feature: 'books',
  metadata: {'count': books.length},
);

// Warning
await logger.warning(
  'Cache miss for books',
  feature: 'books',
);

// Error
await logger.error(
  'Failed to load books',
  feature: 'books',
  error: exception,
  stackTrace: stackTrace,
  metadata: {'reason': failure.message},
);
```

### 3. Audit Tracking

Track user actions for analytics:

```dart
// Track when user searches
await logger.audit(
  feature: 'books',
  action: 'search',
  parameters: {
    'query': searchQuery,
    'results_count': results.length,
  },
);

// Track when user adds to cart
await logger.audit(
  feature: 'cart',
  action: 'add_item',
  parameters: {
    'book_id': book.id,
    'book_title': book.title,
  },
  success: true,
);

// Track when action fails
await logger.audit(
  feature: 'favorites',
  action: 'toggle_favorite',
  parameters: {'book_id': book.id},
  success: false,
);
```

### 4. Performance Tracking

#### Automatic Performance Tracking

```dart
// Track async operations
final books = await logger.trackPerformanceAsync(
  operation: 'fetch_books',
  feature: 'books',
  metadata: {'page': 1},
  fn: () async {
    // Your async code here
    return await bookRepository.getBooks();
  },
);

// Track synchronous operations
final result = logger.trackPerformanceSync(
  operation: 'filter_books',
  feature: 'books',
  fn: () {
    // Your sync code here
    return books.where((b) => b.rating > 4).toList();
  },
);
```

#### Manual Performance Tracking

```dart
// Start tracking
final tracker = logger.trackPerformance(
  operation: 'image_upload',
  feature: 'book_upload',
  metadata: {'size_mb': fileSizeMb},
);

try {
  // Your code here
  await uploadImage();
  await tracker.stop(success: true);
} catch (e) {
  await tracker.stop(success: false);
  rethrow;
}

// Check elapsed time
print('Elapsed: ${tracker.elapsedMs}ms');
```

---

## Remote Configuration

### How It Works

1. **Server Configuration**: Server provides JSON config
2. **Periodic Fetch**: App fetches config every 5 minutes
3. **Local Cache**: Config is cached locally
4. **Real-time Updates**: Changes apply without app restart

### Configuration JSON Format

```json
{
  "enabled": true,
  "global_level": "info",
  "feature_levels": {
    "books": "debug",
    "cart": "trace",
    "favorites": "info"
  },
  "remote_logging_enabled": true,
  "local_logging_enabled": true,
  "performance_tracking_enabled": true,
  "audit_tracking_enabled": true,
  "performance_threshold": 100.0,
  "tracing_enabled_for_users": ["user123", "user456"],
  "max_local_entries": 1000,
  "sync_interval_seconds": 300
}
```

### Configuration Options

| Option | Type | Description |
|--------|------|-------------|
| `enabled` | boolean | Master switch for all logging |
| `global_level` | string | Default level: error/warning/info/debug/trace |
| `feature_levels` | object | Per-feature log levels |
| `remote_logging_enabled` | boolean | Send logs to server |
| `local_logging_enabled` | boolean | Store logs locally |
| `performance_tracking_enabled` | boolean | Track performance metrics |
| `audit_tracking_enabled` | boolean | Track user actions |
| `performance_threshold` | number | Min duration (ms) to log |
| `tracing_enabled_for_users` | array | User IDs for tracing |
| `max_local_entries` | number | Max logs before rotation |
| `sync_interval_seconds` | number | How often to sync to server |

---

## How to Disable Logging

### Complete Disable (No Logs at All)

**Method 1: Server Configuration**
```json
{
  "enabled": false
}
```

**Method 2: Set Level to NONE**
```json
{
  "enabled": true,
  "global_level": "none"
}
```

### Disable Specific Features

```json
{
  "enabled": true,
  "global_level": "info",
  "feature_levels": {
    "books": "none",
    "cart": "info"
  }
}
```

### Disable Remote Logging Only

```json
{
  "enabled": true,
  "remote_logging_enabled": false,
  "local_logging_enabled": true
}
```

### Disable Performance Tracking

```json
{
  "enabled": true,
  "performance_tracking_enabled": false,
  "audit_tracking_enabled": true
}
```

---

## Log Transmission to Server

### Automatic Sync

- Logs are batched and sent to server every `sync_interval_seconds`
- Default: 5 minutes (300 seconds)
- Failed syncs are retried
- Local logs are cleared after successful sync

### Manual Sync

```dart
final loggingService = sl<LoggingConfigService>();
await loggingService.syncLogs();
```

### API Endpoints

The remote data source expects these endpoints:

```
GET  /logging/config        # Fetch configuration
POST /logging/logs          # Send log entries
POST /logging/audit         # Send audit events
```

### Request Format

```json
// POST /logging/logs
{
  "logs": [
    {
      "id": "1234567890",
      "timestamp": "2025-10-31T10:30:00Z",
      "level": "info",
      "message": "Books loaded successfully",
      "feature": "books",
      "action": "load_books",
      "metadata": {"count": 25},
      "user_id": "user123",
      "session_id": "session456"
    }
  ]
}
```

---

## Performance Monitoring Features

### What Gets Tracked

1. **Execution Time**: Duration of operations in milliseconds
2. **Success/Failure**: Whether operation completed successfully
3. **Metadata**: Additional context (page size, item count, etc.)
4. **Feature Attribution**: Which feature the operation belongs to

### Performance Threshold

Only operations exceeding the threshold are logged:

```json
{
  "performance_threshold": 100.0  // Only log if > 100ms
}
```

This prevents noise from fast operations.

### Use Cases

- API call performance
- Database query times
- Image processing duration
- Search operation speed
- Screen load times

---

## Audit Tracking Features

### What Gets Tracked

1. **User Actions**: Searches, favorites, cart operations
2. **Feature Usage**: Which features are being used
3. **Success Rate**: How often operations succeed
4. **Session Context**: User ID and session ID

### Example Audit Events

```dart
// User searches for books
logger.audit(
  feature: 'books',
  action: 'search',
  parameters: {'query': 'flutter', 'results': 15},
);

// User adds to favorites
logger.audit(
  feature: 'favorites',
  action: 'add',
  parameters: {'book_id': '123'},
);

// User completes purchase
logger.audit(
  feature: 'cart',
  action: 'checkout',
  parameters: {'total': 99.99, 'items': 3},
  success: true,
);
```

---

## Example Integration in Features

### In a BLoC

```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetBooksUseCase getBooksUseCase;
  final AppLogger logger;

  HomeBloc({
    required this.getBooksUseCase,
    required this.logger,
  }) : super(HomeInitial()) {
    on<LoadBooks>(_onLoadBooks);
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<HomeState> emit) async {
    await logger.info('Loading books', feature: 'books');
    
    // Track performance
    final result = await logger.trackPerformanceAsync(
      operation: 'load_books',
      feature: 'books',
      fn: () => getBooksUseCase(page: 1, limit: 20),
    );

    result.fold(
      (failure) {
        logger.error(
          'Failed to load books',
          feature: 'books',
          metadata: {'error': failure.message},
        );
        emit(HomeError(failure.message));
      },
      (books) {
        logger.info(
          'Books loaded successfully',
          feature: 'books',
          metadata: {'count': books.length},
        );
        
        // Track audit
        logger.audit(
          feature: 'books',
          action: 'load',
          parameters: {'count': books.length},
          success: true,
        );
        
        emit(HomeLoaded(books: books));
      },
    );
  }
}
```

### In a Repository

```dart
class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final AppLogger logger;

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    await logger.debug(
      'Fetching books from remote',
      feature: 'books',
      action: 'api_call',
    );

    try {
      final books = await logger.trackPerformanceAsync(
        operation: 'api_get_books',
        feature: 'books',
        fn: () => remoteDataSource.getBooks(),
      );

      return Right(books);
    } on ServerException catch (e) {
      await logger.error(
        'Server error fetching books',
        feature: 'books',
        error: e,
        metadata: {'message': e.message},
      );
      return Left(ServerFailure(message: e.message));
    }
  }
}
```

---

## Privacy & Compliance

### PII Filtering

**Important**: Do NOT log personally identifiable information:

```dart
// ❌ BAD - Don't log PII
logger.audit(
  feature: 'user',
  action: 'login',
  parameters: {
    'email': 'user@example.com',  // PII!
    'password': 'secret123',      // NEVER!
  },
);

// ✅ GOOD - Use IDs only
logger.audit(
  feature: 'user',
  action: 'login',
  parameters: {
    'user_id': 'user123',
  },
);
```

### User Consent

If required by regulations (GDPR, CCPA):

```dart
// Check user consent before enabling
if (userHasConsentedToAnalytics) {
  loggingService.start();
} else {
  // Keep logging disabled
}
```

### Data Retention

Configure `max_local_entries` for automatic rotation:

```json
{
  "max_local_entries": 1000  // Keep only last 1000 entries
}
```

---

## Debugging with Logs

### Enable Tracing for Specific Users

Perfect for debugging production issues:

```json
{
  "global_level": "info",
  "tracing_enabled_for_users": ["problematic_user_id"]
}
```

This user will get TRACE level logging while others stay at INFO.

### View Local Logs

```dart
final loggingRepository = sl<LoggingRepository>();

// Get recent logs
final result = await loggingRepository.getLocalLogs(limit: 100);

result.fold(
  (failure) => print('Error: $failure'),
  (logs) {
    for (final log in logs) {
      print('[${log.level.name}] ${log.message}');
    }
  },
);

// Get logs since timestamp
final result2 = await loggingRepository.getLocalLogs(
  since: DateTime.now().subtract(Duration(hours: 1)),
);
```

### Clear Logs

```dart
final loggingRepository = sl<LoggingRepository>();
await loggingRepository.clearLocalLogs();
```

---

## Best Practices

### 1. Use Appropriate Log Levels

- `ERROR`: Things that break functionality
- `WARNING`: Potential issues, fallbacks used
- `INFO`: Important app flow (default)
- `DEBUG`: Detailed debugging info
- `TRACE`: Very verbose, every detail

### 2. Include Context

Always include `feature` and meaningful `metadata`:

```dart
logger.info(
  'Search completed',
  feature: 'books',
  action: 'search',
  metadata: {
    'query': query,
    'results_count': results.length,
    'duration_ms': duration,
  },
);
```

### 3. Don't Over-Log

```dart
// ❌ BAD - Too verbose for production
for (final book in books) {
  await logger.trace('Processing book: ${book.title}');
}

// ✅ GOOD - Summary logging
await logger.debug(
  'Processing books batch',
  feature: 'books',
  metadata: {'count': books.length},
);
```

### 4. Track All User Actions

```dart
// Every user interaction should be audited
await logger.audit(
  feature: 'feature_name',
  action: 'action_name',
  parameters: {...},
);
```

### 5. Use Performance Tracking

```dart
// Wrap expensive operations
await logger.trackPerformanceAsync(
  operation: 'expensive_operation',
  feature: 'feature_name',
  fn: () => expensiveOperation(),
);
```

---

## Configuration by Environment

### Development

```json
{
  "enabled": true,
  "global_level": "debug",
  "remote_logging_enabled": false,
  "local_logging_enabled": true,
  "performance_tracking_enabled": true,
  "audit_tracking_enabled": true
}
```

### Staging

```json
{
  "enabled": true,
  "global_level": "info",
  "remote_logging_enabled": true,
  "local_logging_enabled": true,
  "performance_tracking_enabled": true,
  "audit_tracking_enabled": true
}
```

### Production

```json
{
  "enabled": true,
  "global_level": "warning",
  "remote_logging_enabled": true,
  "local_logging_enabled": false,
  "performance_tracking_enabled": true,
  "audit_tracking_enabled": true,
  "performance_threshold": 500.0
}
```

---

## Summary

The logging system provides:

✅ **Flexible Control** - Enable/disable remotely
✅ **Performance Insights** - Track slow operations
✅ **User Analytics** - Understand feature usage  
✅ **Remote Debugging** - Enable tracing for specific users
✅ **Complete Privacy** - Can be fully disabled
✅ **Production Ready** - Batching, rotation, retry logic

Configure it once from your server, and you have complete control over logging across all clients!
