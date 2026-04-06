import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/entities/log_config.dart';
import '../domain/usecases/fetch_logging_config.dart';
import '../domain/usecases/sync_logs.dart';
import '../../usecase/usecase.dart';

/// Service to manage remote logging configuration
/// 
/// Periodically fetches configuration from server and syncs logs
class LoggingConfigService {
  final FetchLoggingConfig _fetchConfig;
  final SyncLogs _syncLogs;

  Timer? _configTimer;
  Timer? _syncTimer;
  LogConfig? _currentConfig;

  LoggingConfigService({
    required FetchLoggingConfig fetchConfig,
    required SyncLogs syncLogs,
  })  : _fetchConfig = fetchConfig,
        _syncLogs = syncLogs;

  /// Start the configuration service
  /// 
  /// This will periodically fetch configuration and sync logs
  Future<void> start() async {
    // Fetch initial configuration
    await refreshConfig();

    // Setup periodic config refresh (every 5 minutes by default)
    _configTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => refreshConfig(),
    );

    // Setup periodic log sync based on config
    _setupLogSync();
  }

  /// Stop the configuration service
  void stop() {
    _configTimer?.cancel();
    _syncTimer?.cancel();
    _configTimer = null;
    _syncTimer = null;
  }

  /// Manually refresh configuration from server
  Future<LogConfig?> refreshConfig() async {
    if (kDebugMode) {
      debugPrint('[LoggingConfigService] Fetching remote configuration...');
    }

    final result = await _fetchConfig(const NoParams());
    
    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[LoggingConfigService] Failed to fetch config: ${failure.message}');
        }
        return _currentConfig;
      },
      (config) {
        if (kDebugMode) {
          debugPrint('[LoggingConfigService] Config updated - Enabled: ${config.enabled}');
        }
        _currentConfig = config;
        _setupLogSync(); // Reconfigure sync based on new config
        return config;
      },
    );
  }

  /// Manually sync logs to server
  Future<bool> syncLogs() async {
    if (kDebugMode) {
      debugPrint('[LoggingConfigService] Syncing logs to server...');
    }

    final result = await _syncLogs(const NoParams());
    
    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[LoggingConfigService] Failed to sync logs: ${failure.message}');
        }
        return false;
      },
      (_) {
        if (kDebugMode) {
          debugPrint('[LoggingConfigService] Logs synced successfully');
        }
        return true;
      },
    );
  }

  /// Get current configuration
  LogConfig? get currentConfig => _currentConfig;

  void _setupLogSync() {
    // Cancel existing timer
    _syncTimer?.cancel();

    // Only setup sync if config is available and remote logging is enabled
    if (_currentConfig == null || !_currentConfig!.remoteLoggingEnabled) {
      return;
    }

    final syncInterval = Duration(
      seconds: _currentConfig!.syncIntervalSeconds,
    );

    _syncTimer = Timer.periodic(syncInterval, (_) => syncLogs());
  }

  /// Dispose resources
  void dispose() {
    stop();
  }
}
