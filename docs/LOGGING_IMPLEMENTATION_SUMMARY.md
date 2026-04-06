# Logging, Tracing & Audit System - Implementation Summary

## Overview

A comprehensive logging, tracing, and audit system has been implemented for the Flutter Library app. The system provides complete control over logging from development to production with remote configuration capabilities.

---

## What Was Implemented

### 1. Core Logging Infrastructure

#### Domain Layer (`lib/core/logging/domain/`)
- **Entities**:
  - `LogLevel` - Hierarchical levels: NONE, ERROR, WARNING, INFO, DEBUG, TRACE
  - `LogEntry` - Complete log entry with metadata, timestamps, and context
  - `LogConfig` - Configuration entity with per-feature level control
  - `PerformanceMetric` - Performance measurement entity
  - `AuditEvent` - User action tracking entity

- **Repository Interface**: `LoggingRepository`
  - Config management
  - Log entry operations
  - Performance metrics
  - Audit events
  - Server sync operations

- **Use Cases**:
  - `LogMessage` - Log messages at different levels
  - `TrackAuditEvent` - Track user actions
  - `TrackPerformance` - Monitor performance
  - `SyncLogs` - Send logs to server
  - `FetchLoggingConfig` - Get remote configuration

#### Data Layer (`lib/core/logging/data/`)
- **Models**: JSON serializable versions of all entities
- **Local Data Source**: SharedPreferences-based local storage
- **Remote Data Source**: HTTP-based server communication
- **Repository Implementation**: Complete repository with error handling

#### Services Layer (`lib/core/logging/services/`)
- **AppLogger**: Main logging service with convenient methods
  - Level-specific methods: `trace()`, `debug()`, `info()`, `warning()`, `error()`
  - Audit tracking: `audit()`
  - Performance tracking: `trackPerformance()`, `trackPerformanceAsync()`, `trackPerformanceSync()`
  
- **LoggingConfigService**: Remote configuration manager
  - Periodic config fetching (every 5 minutes)
  - Automatic log syncing (configurable interval)
  - Manual refresh and sync capabilities

### 2. Dependency Injection

All logging services registered in `injection_container.dart`:
- Repository and data sources
- All use cases
- AppLogger service (singleton)
- LoggingConfigService (singleton)
- HTTP client for remote communication

### 3. App Integration

- Logging service auto-starts in `main.dart`
- Available throughout app via dependency injection: `sl<AppLogger>()`

---

## Key Features

### 🎚️ Hierarchical Logging Levels

```dart
LogLevel.none     // Completely disabled
LogLevel.error    // Critical errors only  
LogLevel.warning  // Warnings and errors
LogLevel.info     // General info (default)
LogLevel.debug    // Detailed debugging
LogLevel.trace    // Very verbose
```

### 🌐 Remote Configuration

Control logging from your server without app updates:

```json
{
  "enabled": true,
  "global_level": "info",
  "feature_levels": {
    "books": "debug",
    "cart": "trace"
  },
  "remote_logging_enabled": true,
  "performance_tracking_enabled": true,
  "tracing_enabled_for_users": ["user123"]
}
```

### 📊 Performance Monitoring

Track execution times automatically:

```dart
final books = await logger.trackPerformanceAsync(
  operation: 'fetch_books',
  feature: 'books',
  fn: () => fetchBooks(),
);
```

Only operations exceeding the threshold are logged (default: 100ms).

### 📝 Audit Tracking

Monitor user behavior and feature usage:

```dart
await logger.audit(
  feature: 'books',
  action: 'search',
  parameters: {'query': query, 'results': count},
  success: true,
);
```

### 📤 Remote Log Transmission

- Automatic batched syncing to server
- Configurable sync interval (default: 5 minutes)
- Retry mechanism for failures
- Local storage with automatic rotation

### 🔒 Privacy & Control

- **Complete Disable**: Set `enabled: false` remotely
- **Per-Feature Control**: Different levels for different features
- **Per-User Tracing**: Enable debug logs for specific users
- **Data Rotation**: Automatic cleanup of old logs
- **PII Safe**: No personal data logging by design

---

## How to Use

### Basic Logging

```dart
class SomeBloc {
  final AppLogger logger;
  
  SomeBloc({required this.logger});
  
  Future<void> doSomething() async {
    await logger.info('Starting operation', feature: 'feature_name');
    
    try {
      // Your code
      await logger.debug('Operation details', metadata: {...});
    } catch (e) {
      await logger.error('Failed', error: e, stackTrace: stackTrace);
    }
  }
}
```

### Performance Tracking

```dart
// Automatic tracking
final result = await logger.trackPerformanceAsync(
  operation: 'expensive_operation',
  feature: 'feature_name',
  fn: () async => await expensiveOperation(),
);

// Manual tracking
final tracker = logger.trackPerformance(operation: 'upload');
try {
  await doUpload();
  await tracker.stop(success: true);
} catch (e) {
  await tracker.stop(success: false);
}
```

### Audit Events

```dart
await logger.audit(
  feature: 'cart',
  action: 'add_item',
  parameters: {'book_id': bookId, 'price': price},
  success: true,
);
```

---

## Remote Configuration

### API Endpoints

Your server should implement:

```
GET  /logging/config    # Return configuration JSON
POST /logging/logs      # Receive log entries
POST /logging/audit     # Receive audit events
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | boolean | true | Master on/off switch |
| `global_level` | string | "info" | Default log level |
| `feature_levels` | object | {} | Per-feature levels |
| `remote_logging_enabled` | boolean | true | Send logs to server |
| `local_logging_enabled` | boolean | true | Store logs locally |
| `performance_tracking_enabled` | boolean | true | Track performance |
| `audit_tracking_enabled` | boolean | true | Track user actions |
| `performance_threshold` | number | 100.0 | Min ms to log |
| `tracing_enabled_for_users` | array | [] | User IDs for tracing |
| `max_local_entries` | number | 1000 | Max logs before rotation |
| `sync_interval_seconds` | number | 300 | Sync frequency |

---

## How to Disable Logging

### Complete Disable

**Server Configuration:**
```json
{"enabled": false}
```

This completely disables all logging - no logs are created, stored, or transmitted.

### Disable Only Remote Logging

```json
{
  "enabled": true,
  "remote_logging_enabled": false,
  "local_logging_enabled": true
}
```

Logs are stored locally but never sent to server.

### Disable for Specific Features

```json
{
  "feature_levels": {
    "books": "none",
    "cart": "info"
  }
}
```

### Production Configuration Example

```json
{
  "enabled": true,
  "global_level": "warning",
  "remote_logging_enabled": true,
  "local_logging_enabled": false,
  "performance_threshold": 500.0
}
```

Only warnings/errors logged, sent to server, not stored locally.

---

## Integration Examples

### In a BLoC

```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetBooksUseCase getBooksUseCase;
  final AppLogger logger;

  HomeBloc({
    required this.getBooksUseCase,
    required this.logger,  // Inject via DI
  }) : super(HomeInitial());

  Future<void> _onLoadBooks(event, emit) async {
    await logger.info('Loading books', feature: 'books');
    
    final result = await logger.trackPerformanceAsync(
      operation: 'load_books',
      feature: 'books',
      fn: () => getBooksUseCase(page: 1),
    );

    result.fold(
      (failure) {
        logger.error('Load failed', feature: 'books', error: failure);
      },
      (books) {
        logger.info('Loaded ${books.length} books', feature: 'books');
        logger.audit(
          feature: 'books',
          action: 'load',
          parameters: {'count': books.length},
        );
      },
    );
  }
}
```

### Update Injection

```dart
// In your BLoC registration
sl.registerFactory(() => HomeBloc(
  getBooksUseCase: sl(),
  logger: sl(),  // Add logger
));
```

---

## Files Created

### Domain Layer
- `lib/core/logging/domain/entities/log_level.dart`
- `lib/core/logging/domain/entities/log_entry.dart`
- `lib/core/logging/domain/entities/log_config.dart`
- `lib/core/logging/domain/entities/performance_metric.dart`
- `lib/core/logging/domain/entities/audit_event.dart`
- `lib/core/logging/domain/repositories/logging_repository.dart`
- `lib/core/logging/domain/usecases/log_message.dart`
- `lib/core/logging/domain/usecases/track_audit_event.dart`
- `lib/core/logging/domain/usecases/track_performance.dart`
- `lib/core/logging/domain/usecases/sync_logs.dart`
- `lib/core/logging/domain/usecases/fetch_logging_config.dart`

### Data Layer
- `lib/core/logging/data/models/log_config_model.dart`
- `lib/core/logging/data/models/log_entry_model.dart`
- `lib/core/logging/data/models/audit_event_model.dart`
- `lib/core/logging/data/models/performance_metric_model.dart`
- `lib/core/logging/data/datasources/logging_local_data_source.dart`
- `lib/core/logging/data/datasources/logging_local_data_source_impl.dart`
- `lib/core/logging/data/datasources/logging_remote_data_source.dart`
- `lib/core/logging/data/datasources/logging_remote_data_source_impl.dart`
- `lib/core/logging/data/repositories/logging_repository_impl.dart`

### Services
- `lib/core/logging/services/app_logger.dart`
- `lib/core/logging/services/logging_config_service.dart`

### Core
- `lib/core/usecase/usecase.dart` (base class for use cases)

### Documentation
- `docs/logging/LOGGING_SYSTEM_GUIDE.md` (comprehensive guide)

### Updated Files
- `lib/injection/injection_container.dart` (added logging dependencies)
- `lib/main.dart` (start logging service on app launch)

---

## Server Implementation Notes

### Configuration Endpoint

```
GET /logging/config
Authorization: Bearer <token>

Response:
{
  "enabled": true,
  "global_level": "info",
  // ... other config options
}
```

### Log Ingestion Endpoint

```
POST /logging/logs
Authorization: Bearer <token>
Content-Type: application/json

Body:
{
  "logs": [
    {
      "id": "1698765432000",
      "timestamp": "2025-10-31T10:30:32Z",
      "level": "info",
      "message": "Books loaded",
      "feature": "books",
      "metadata": {"count": 25}
    }
  ]
}

Response: 200 OK or 201 Created
```

### Audit Endpoint

```
POST /logging/audit
Authorization: Bearer <token>
Content-Type: application/json

Body:
{
  "events": [
    {
      "id": "1698765432001",
      "timestamp": "2025-10-31T10:30:33Z",
      "feature": "books",
      "action": "search",
      "parameters": {"query": "flutter"},
      "success": true
    }
  ]
}

Response: 200 OK or 201 Created
```

---

## Benefits

### For Development
- **Debug easily**: Enable TRACE for specific features
- **Local logs**: View logs in SharedPreferences
- **Performance insights**: Find slow operations

### For Production
- **Remote debugging**: Enable tracing for specific users
- **Error monitoring**: Track all errors automatically
- **Feature analytics**: Understand usage patterns
- **Performance monitoring**: Identify bottlenecks

### For Business
- **User behavior**: Audit trail of all actions
- **Feature adoption**: See what's being used
- **Error rates**: Monitor app health
- **Performance metrics**: Track app speed

---

## Next Steps

1. **Configure Server Endpoints**: Implement the 3 required API endpoints
2. **Set Base URL**: Update `LoggingRemoteDataSourceImpl` with your server URL
3. **Add to Features**: Inject `AppLogger` into your BLoCs/repositories
4. **Test Configuration**: Verify remote config works
5. **Monitor Logs**: Set up server-side log aggregation

---

## Example: Complete Feature Integration

```dart
// 1. Add to BLoC
class BookDetailBloc extends Bloc<BookDetailEvent, BookDetailState> {
  final AppLogger logger;
  
  BookDetailBloc({required this.logger});
  
  Future<void> _onLoadDetails(event, emit) async {
    // Log the action
    await logger.info(
      'Loading book details',
      feature: 'book_details',
      metadata: {'book_id': event.bookId},
    );
    
    // Track performance
    final result = await logger.trackPerformanceAsync(
      operation: 'load_book_details',
      feature: 'book_details',
      metadata: {'book_id': event.bookId},
      fn: () => repository.getBookDetails(event.bookId),
    );
    
    // Log result
    result.fold(
      (failure) {
        logger.error(
          'Failed to load book details',
          feature: 'book_details',
          metadata: {'book_id': event.bookId, 'error': failure.message},
        );
      },
      (book) {
        logger.info(
          'Book details loaded',
          feature: 'book_details',
          metadata: {'book_id': book.id, 'title': book.title},
        );
        
        // Audit the view
        logger.audit(
          feature: 'book_details',
          action: 'view',
          parameters: {'book_id': book.id},
        );
      },
    );
  }
}

// 2. Register in DI
sl.registerFactory(() => BookDetailBloc(logger: sl()));
```

---

## Summary

✅ **Complete logging infrastructure** with clean architecture
✅ **Remote configuration** for flexible control
✅ **Performance monitoring** with automatic tracking
✅ **Audit system** for user analytics
✅ **Privacy-focused** with complete disable option
✅ **Production-ready** with batching, rotation, and retry
✅ **Easy to use** with simple API
✅ **Fully documented** with comprehensive guide

The logging system is now ready to use! Just configure your server endpoints and start integrating the logger into your features.
