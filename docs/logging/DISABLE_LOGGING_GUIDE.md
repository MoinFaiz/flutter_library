# How Logging Can Be Disabled - Complete Explanation

## Overview

The logging system provides multiple ways to disable logging at different levels, from completely turning it off to fine-grained control per feature or user. This document explains all the mechanisms.

---

## 1. Complete Disable (No Logs at All)

### Method 1: Server Configuration - Set `enabled: false`

**Server sends:**
```json
{
  "enabled": false
}
```

**What happens:**
- ✅ No log entries are created
- ✅ No performance tracking happens
- ✅ No audit events are created
- ✅ No data is stored locally
- ✅ No data is sent to server
- ✅ Zero performance overhead

**Code flow:**
```dart
// In LogMessage use case
if (!config.enabled) {
  return const Right(null);  // Early return, nothing is logged
}

// In TrackPerformance use case
if (!config.enabled || !config.performanceTrackingEnabled) {
  return const Right(null);  // No tracking
}

// In TrackAuditEvent use case
if (!config.enabled || !config.auditTrackingEnabled) {
  return const Right(null);  // No audit
}
```

### Method 2: Set Level to NONE

**Server sends:**
```json
{
  "enabled": true,
  "global_level": "none"
}
```

**What happens:**
- ✅ No logs are created (LogLevel.none has value 0)
- ✅ Performance and audit still work (unless explicitly disabled)

**Code flow:**
```dart
// In LogLevel.shouldLog()
bool shouldLog(LogLevel configuredLevel) {
  return value <= configuredLevel.value;
}

// If configuredLevel is NONE (0), nothing passes this check
// because all other levels have value >= 1
```

---

## 2. Disable Remote Logging Only

Keep logs locally but don't send to server:

```json
{
  "enabled": true,
  "remote_logging_enabled": false,
  "local_logging_enabled": true
}
```

**What happens:**
- ✅ Logs are created
- ✅ Logs are stored locally
- ❌ Logs are NOT sent to server
- ❌ Sync operations are skipped

**Code flow:**
```dart
// In SyncLogs use case
if (!config.enabled || !config.remoteLoggingEnabled) {
  return const Right(null);  // Skip sync
}

// In LogMessage use case
if (config.localLoggingEnabled) {
  await repository.saveLogEntry(entry);  // Only saves locally
}
```

---

## 3. Disable Local Logging Only

Send to server but don't store locally:

```json
{
  "enabled": true,
  "remote_logging_enabled": true,
  "local_logging_enabled": false
}
```

**What happens:**
- ✅ Logs are created in memory
- ✅ Logs are sent to server
- ❌ Logs are NOT stored locally
- ✅ No local storage usage

**Good for:** Production apps where you don't want local storage usage

---

## 4. Disable Specific Features

Turn off logging for specific parts of the app:

```json
{
  "enabled": true,
  "global_level": "info",
  "feature_levels": {
    "books": "none",      // Books feature: disabled
    "cart": "debug",      // Cart feature: debug level
    "favorites": "error"  // Favorites: only errors
  }
}
```

**What happens:**
- Books feature: No logs
- Cart feature: Debug, info, warning, error logs
- Favorites: Only error logs
- Other features: Default to global level (info)

**Code flow:**
```dart
// In LogConfig.getLevelForFeature()
LogLevel getLevelForFeature(String? feature) {
  if (!enabled) return LogLevel.none;
  if (feature == null) return globalLevel;
  return featureLevels[feature] ?? globalLevel;
}
```

---

## 5. Disable Performance Tracking

Keep logging but disable performance monitoring:

```json
{
  "enabled": true,
  "performance_tracking_enabled": false,
  "audit_tracking_enabled": true
}
```

**What happens:**
- ✅ Regular logs still work
- ✅ Audit events still work
- ❌ Performance metrics are not tracked
- ❌ `trackPerformanceAsync()` does nothing

**Code flow:**
```dart
// In TrackPerformance use case
if (!config.enabled || !config.performanceTrackingEnabled) {
  return const Right(null);  // Skip performance tracking
}
```

---

## 6. Disable Audit Tracking

Keep logging but disable user action tracking:

```json
{
  "enabled": true,
  "performance_tracking_enabled": true,
  "audit_tracking_enabled": false
}
```

**What happens:**
- ✅ Regular logs still work
- ✅ Performance tracking still works
- ❌ Audit events are not tracked
- ❌ `logger.audit()` does nothing

---

## 7. Enable Tracing for Specific Users Only

Disable tracing globally but enable for specific users:

```json
{
  "enabled": true,
  "global_level": "info",
  "tracing_enabled_for_users": ["user123", "user456"]
}
```

**What happens:**
- Most users: INFO level logging
- user123 and user456: TRACE level logging (if code calls trace/debug)
- Useful for debugging production issues for specific users

**Code flow:**
```dart
// In LogConfig.isTracingEnabledForUser()
bool isTracingEnabledForUser(String? userId) {
  if (!enabled) return false;
  if (tracingEnabledForUsers.isEmpty) return true;
  if (userId == null) return false;
  return tracingEnabledForUsers.contains(userId);
}

// Usage in AppLogger
// When userId is set: logger.setUserId('user123')
// The system can check if tracing should be enabled for this user
```

---

## 8. Performance Threshold

Only log slow operations:

```json
{
  "enabled": true,
  "performance_tracking_enabled": true,
  "performance_threshold": 500.0
}
```

**What happens:**
- Fast operations (< 500ms): Not logged
- Slow operations (>= 500ms): Logged

**Code flow:**
```dart
// In TrackPerformance use case
if (durationMs < config.performanceThreshold) {
  return const Right(null);  // Don't log fast operations
}
```

---

## 9. Environment-Specific Configurations

### Development
```json
{
  "enabled": true,
  "global_level": "debug",
  "remote_logging_enabled": false,
  "local_logging_enabled": true
}
```
- All logs visible
- Stored locally for inspection
- Not sent to server (faster development)

### Staging
```json
{
  "enabled": true,
  "global_level": "info",
  "remote_logging_enabled": true,
  "local_logging_enabled": true
}
```
- Moderate logging
- Sent to server for testing
- Also stored locally

### Production
```json
{
  "enabled": true,
  "global_level": "warning",
  "remote_logging_enabled": true,
  "local_logging_enabled": false,
  "performance_threshold": 1000.0
}
```
- Only warnings and errors
- Sent to server only
- Only very slow operations logged

### Production (Privacy Mode)
```json
{
  "enabled": false
}
```
- Complete disable
- Zero data collection
- Maximum privacy

---

## 10. How Configuration is Applied

### Fetch and Apply Flow

```
1. App starts
   ↓
2. LoggingConfigService.start() called
   ↓
3. Fetch config from server (GET /logging/config)
   ↓
4. Cache config locally in SharedPreferences
   ↓
5. Config timer starts (refresh every 5 minutes)
   ↓
6. On every log/audit/performance call:
   - Check if enabled
   - Check if level allows it
   - Check if feature allows it
   - Check if user allows it
   ↓
7. Config changes apply immediately
   (no app restart needed)
```

### Fallback Behavior

```dart
// If server is unreachable:
try {
  config = await fetchRemoteConfig();
} catch (e) {
  // Use cached config
  config = getCachedConfig();
  
  if (config == null) {
    // Use default config
    config = LogConfig(); // enabled: true, level: info
  }
}
```

**This means:**
- App works offline with cached config
- App works even if server endpoint doesn't exist
- Default config is reasonable (enabled, info level)

---

## 11. Programmatic Disable

You can also disable logging programmatically (though not recommended):

```dart
// Don't use the logger
class MyBloc {
  // Simply don't inject or use logger
  MyBloc({
    required this.useCase,
    // No logger parameter
  });
}
```

This is not recommended because:
- Loses all monitoring capabilities
- Can't enable remotely for debugging
- Loses audit trail

---

## 12. Network Efficiency

The system is designed to be network-efficient:

### Batching
```dart
// Logs are batched before sending
await repository.syncLogsToServer(logs); // Sends all at once
```

### Configurable Sync Interval
```json
{
  "sync_interval_seconds": 300  // Only sync every 5 minutes
}
```

### Log Rotation
```json
{
  "max_local_entries": 1000  // Auto-delete old logs
}
```

### Retry Mechanism
```dart
// If sync fails, logs stay local
// Will retry on next sync cycle
```

---

## Summary: Ways to Disable

| Method | Config | Effect |
|--------|--------|--------|
| **Complete disable** | `"enabled": false` | No logging at all |
| **Level NONE** | `"global_level": "none"` | No log messages |
| **Disable remote** | `"remote_logging_enabled": false` | No server transmission |
| **Disable local** | `"local_logging_enabled": false` | No local storage |
| **Per feature** | `"feature_levels": {"books": "none"}` | Disable specific features |
| **Disable performance** | `"performance_tracking_enabled": false` | No performance tracking |
| **Disable audit** | `"audit_tracking_enabled": false` | No audit events |
| **High threshold** | `"performance_threshold": 999999` | Only extreme cases |
| **User-specific** | `"tracing_enabled_for_users": []` | Control per user |

---

## Best Practice Recommendations

### For Privacy Compliance (GDPR, CCPA)

1. **Provide user choice:**
```dart
if (userConsentedToAnalytics) {
  // Server returns enabled: true
} else {
  // Server returns enabled: false
}
```

2. **Don't log PII:**
```dart
// ❌ Bad
logger.audit(parameters: {'email': user.email});

// ✅ Good  
logger.audit(parameters: {'user_id': user.id});
```

3. **Clear data on request:**
```dart
await loggingRepository.clearLocalLogs();
```

### For Production

Start conservative, enable as needed:
```json
{
  "enabled": true,
  "global_level": "warning",  // Only warnings and errors
  "remote_logging_enabled": true,
  "local_logging_enabled": false,
  "performance_threshold": 1000.0,
  "tracing_enabled_for_users": []  // Empty = no tracing
}
```

Then when you need to debug:
```json
{
  "tracing_enabled_for_users": ["problematic_user_id"]
}
```

This user gets TRACE logging while others stay at WARNING.

---

## Conclusion

The logging system provides **complete control** at multiple levels:
- Global on/off
- Per-component (logging, performance, audit)
- Per-feature
- Per-user
- Per-log-level
- Network transmission control
- Local storage control

All controlled remotely without app updates, with sensible defaults and fallbacks.
