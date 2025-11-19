import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Service untuk Firebase App Check
/// Digunakan untuk protect backend resources dari abuse dan bot attacks
class AppCheckService {
  static final AppCheckService _instance = AppCheckService._internal();
  factory AppCheckService() => _instance;
  AppCheckService._internal();

  bool _initialized = false;

  /// Initialize App Check service
  ///
  /// App Check helps protect your backend resources from abuse, such as
  /// billing fraud or phishing. It works with Cloud Firestore, Cloud Storage,
  /// and other Firebase services.
  Future<void> init() async {
    if (_initialized) {
      AppLogger.info('App Check already initialized');
      return;
    }

    try {
      // Initialize App Check
      // For debug builds, use debug provider
      // For release builds, use deviceCheck (iOS) or Play Integrity (Android)
      if (kDebugMode) {
        // Debug provider for development/testing
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
        AppLogger.info('App Check initialized with DEBUG provider');
      } else {
        // Production providers
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.deviceCheck,
        );
        AppLogger.info('App Check initialized with PRODUCTION providers');
      }

      // Set token auto-refresh
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

      _initialized = true;
      AppLogger.info('App Check initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing App Check', e);
      _initialized = false;
    }
  }

  /// Get App Check token (for custom verification)
  ///
  /// This is useful if you need to verify the token on your own backend
  Future<String?> getToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      if (token != null) {
        AppLogger.info('App Check token retrieved');
        return token;
      } else {
        AppLogger.warn('App Check token is null');
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting App Check token', e);
      return null;
    }
  }

  /// Force refresh App Check token
  Future<void> refreshToken() async {
    try {
      // Get token will automatically refresh if needed
      await FirebaseAppCheck.instance.getToken();
      AppLogger.info('App Check token refreshed');
    } catch (e) {
      AppLogger.error('Error refreshing App Check token', e);
    }
  }

  /// Check if App Check is initialized
  bool get isInitialized => _initialized;

  /// Enable/disable token auto-refresh
  Future<void> setTokenAutoRefreshEnabled(bool enabled) async {
    try {
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(enabled);
      AppLogger.info(
        'App Check token auto-refresh ${enabled ? "enabled" : "disabled"}',
      );
    } catch (e) {
      AppLogger.error('Error setting token auto-refresh', e);
    }
  }
}
