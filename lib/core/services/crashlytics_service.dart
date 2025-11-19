import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Service untuk Firebase Crashlytics error reporting
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize Crashlytics service
  void init() {
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
      // Also log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(errorDetails);
      }
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    AppLogger.info('Crashlytics service initialized');
  }

  /// Record a non-fatal error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Set additional context if provided
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          _crashlytics.setCustomKey(key, value.toString());
        });
      }

      // Record the error
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      AppLogger.info('Error recorded to Crashlytics: $reason');
    } catch (e) {
      AppLogger.error('Error recording to Crashlytics', e);
    }
  }

  /// Log a message to Crashlytics
  void log(String message) {
    try {
      _crashlytics.log(message);
      AppLogger.info('Logged to Crashlytics: $message');
    } catch (e) {
      AppLogger.error('Error logging to Crashlytics', e);
    }
  }

  /// Set user identifier
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      AppLogger.info('Crashlytics user ID set: $userId');
    } catch (e) {
      AppLogger.error('Error setting Crashlytics user ID', e);
    }
  }

  /// Set custom key-value pair
  void setCustomKey(String key, dynamic value) {
    try {
      if (value is String) {
        _crashlytics.setCustomKey(key, value);
      } else if (value is int) {
        _crashlytics.setCustomKey(key, value);
      } else if (value is double) {
        _crashlytics.setCustomKey(key, value);
      } else if (value is bool) {
        _crashlytics.setCustomKey(key, value);
      } else {
        _crashlytics.setCustomKey(key, value.toString());
      }
      AppLogger.info('Crashlytics custom key set: $key = $value');
    } catch (e) {
      AppLogger.error('Error setting Crashlytics custom key', e);
    }
  }

  /// Set multiple custom keys at once
  void setCustomKeys(Map<String, dynamic> keys) {
    try {
      keys.forEach((key, value) {
        setCustomKey(key, value);
      });
    } catch (e) {
      AppLogger.error('Error setting Crashlytics custom keys', e);
    }
  }

  /// Check if Crashlytics is enabled
  bool get isCrashlyticsCollectionEnabled =>
      _crashlytics.isCrashlyticsCollectionEnabled;

  /// Enable/disable Crashlytics collection
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      AppLogger.info('Crashlytics collection enabled: $enabled');
    } catch (e) {
      AppLogger.error('Error setting Crashlytics collection enabled', e);
    }
  }

  /// Force a crash for testing (only in debug mode)
  void forceCrash() {
    if (kDebugMode) {
      _crashlytics.crash();
    } else {
      AppLogger.warn('Force crash is only available in debug mode');
    }
  }

  /// Send unsent reports
  Future<void> sendUnsentReports() async {
    try {
      await _crashlytics.sendUnsentReports();
      AppLogger.info('Unsent Crashlytics reports sent');
    } catch (e) {
      AppLogger.error('Error sending unsent Crashlytics reports', e);
    }
  }

  /// Delete unsent reports
  Future<void> deleteUnsentReports() async {
    try {
      await _crashlytics.deleteUnsentReports();
      AppLogger.info('Unsent Crashlytics reports deleted');
    } catch (e) {
      AppLogger.error('Error deleting unsent Crashlytics reports', e);
    }
  }
}

