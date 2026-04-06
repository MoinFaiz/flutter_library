# Logging System - Quick Reference

## Basic Usage

### Inject Logger
```dart
class MyBloc {
  final AppLogger logger;
  MyBloc({required this.logger});
}
```

### Log Messages
```dart
await logger.trace('Very detailed', feature: 'feature_name');
await logger.debug('Debug info', feature: 'feature_name');
await logger.info('General info', feature: 'feature_name');
await logger.warning('Warning', feature: 'feature_name');
await logger.error('Error occurred', feature: 'feature_name', error: e);
```

### Track Performance
```dart
// Automatic
final result = await logger.trackPerformanceAsync(
  operation: 'operation_name',
  feature: 'feature_name',
  fn: () => myAsyncOperation(),
);

// Manual
final tracker = logger.trackPerformance(operation: 'op_name');
await doWork();
await tracker.stop();
```

### Track User Actions
```dart
await logger.audit(
  feature: 'feature_name',
  action: 'action_name',
  parameters: {'key': 'value'},
  success: true,
);
```

## Configuration (Server-Side)

### Completely Disable
```json
{"enabled": false}
```

### Set Level
```json
{
  "enabled": true,
  "global_level": "info"  // none, error, warning, info, debug, trace
}
```

### Per-Feature Levels
```json
{
  "global_level": "info",
  "feature_levels": {
    "books": "debug",
    "cart": "trace",
    "favorites": "none"
  }
}
```

### Enable Tracing for Specific Users
```json
{
  "global_level": "info",
  "tracing_enabled_for_users": ["user_id_1", "user_id_2"]
}
```

### Disable Remote Logging
```json
{
  "enabled": true,
  "remote_logging_enabled": false,
  "local_logging_enabled": true
}
```

## Server Endpoints

```
GET  /logging/config    # Return configuration JSON
POST /logging/logs      # Receive log batches
POST /logging/audit     # Receive audit events
```

## Log Levels (Least to Most Verbose)

1. **NONE** - Disabled
2. **ERROR** - Critical errors only
3. **WARNING** - Warnings + errors
4. **INFO** - General info (default)
5. **DEBUG** - Detailed debugging
6. **TRACE** - Very verbose

## Common Patterns

### In BLoC Event Handlers
```dart
Future<void> _onEvent(event, emit) async {
  await logger.info('Event received', feature: 'feature');
  
  final result = await logger.trackPerformanceAsync(
    operation: 'event_handler',
    feature: 'feature',
    fn: () => useCase(),
  );

  result.fold(
    (failure) => logger.error('Failed', feature: 'feature'),
    (data) {
      logger.info('Success', feature: 'feature');
      logger.audit(feature: 'feature', action: 'event');
    },
  );
}
```

### In Repository
```dart
@override
Future<Either<Failure, Data>> getData() async {
  await logger.debug('Fetching data', feature: 'feature');
  
  try {
    final data = await logger.trackPerformanceAsync(
      operation: 'api_call',
      feature: 'feature',
      fn: () => remoteDataSource.getData(),
    );
    return Right(data);
  } catch (e) {
    await logger.error('Fetch failed', feature: 'feature', error: e);
    return Left(ServerFailure());
  }
}
```

## Access via DI

```dart
// Get logger anywhere
final logger = sl<AppLogger>();

// Or inject in constructor
MyClass({required AppLogger logger});
```

## Manual Sync

```dart
final loggingService = sl<LoggingConfigService>();
await loggingService.syncLogs();        // Sync logs
await loggingService.refreshConfig();   // Refresh config
```

## Best Practices

✅ Always include `feature` parameter
✅ Use appropriate log levels
✅ Don't log PII (emails, passwords, etc.)
✅ Track all user actions with `audit()`
✅ Use performance tracking for slow operations
✅ Include meaningful metadata
✅ Handle errors with `logger.error()`

❌ Don't log in tight loops
❌ Don't log sensitive data
❌ Don't use TRACE in production (use remote config)
❌ Don't block on logging (all async)
