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
  ///
  /// Note: For debug builds, you need to register the debug token in Firebase Console.
  /// Call [printDebugToken] to get the debug token.
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

        // Print debug token for registration in Firebase Console
        // This token needs to be registered in Firebase Console > App Check > Apps
        _printDebugToken();
      } else {
        // Production providers
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.deviceCheck,
        );
        AppLogger.info('App Check initialized with PRODUCTION providers');
      }

      // Set token auto-refresh (but don't fail if this fails)
      try {
        await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      } catch (e) {
        AppLogger.warn('Failed to enable token auto-refresh: $e');
      }

      _initialized = true;
      AppLogger.info('App Check initialized successfully');
    } catch (e) {
      // Don't fail app initialization if App Check fails
      // App Check is important but not critical for app functionality
      AppLogger.warn(
        'App Check initialization failed. App will continue without App Check protection. '
        'Error: $e',
      );
      AppLogger.warn(
        'To fix: Register debug token in Firebase Console > App Check > Apps',
      );
      _initialized = false;
    }
  }

  /// Print debug token for registration in Firebase Console
  ///
  /// This token needs to be registered in:
  /// Firebase Console > App Check > Apps > [Your App] > Debug tokens
  Future<void> _printDebugToken() async {
    try {
      // Wait a bit for token to be generated
      await Future.delayed(const Duration(seconds: 2));

      // Note: In debug mode, App Check will generate a debug token
      // This token needs to be registered in Firebase Console
      AppLogger.info('═══════════════════════════════════════════════════');
      AppLogger.info('🔐 FIREBASE APP CHECK SETUP REQUIRED');
      AppLogger.info('═══════════════════════════════════════════════════');
      AppLogger.info('To enable App Check in debug mode:');
      AppLogger.info('1. Run the app and check logcat for debug token');
      AppLogger.info('2. Go to Firebase Console > App Check > Apps');
      AppLogger.info('3. Select your app and add the debug token');
      AppLogger.info('4. Restart the app');
      AppLogger.info('');
      AppLogger.info(
        'Note: App Check errors are expected until token is registered.',
      );
      AppLogger.info(
        'The app will continue to work without App Check protection.',
      );
      AppLogger.info('═══════════════════════════════════════════════════');
    } catch (e) {
      AppLogger.warn('Error printing debug token info: $e');
    }
  }

  /// Manually print debug token (for troubleshooting)
  Future<void> printDebugToken() async {
    await _printDebugToken();
  }

  /// Get App Check token (for custom verification)
  ///
  /// This is useful if you need to verify the token on your own backend
  ///
  /// [forceRefresh] - Force refresh the token (useful for debug tokens)
  Future<String?> getToken({bool forceRefresh = false}) async {
    try {
      // Note: Based on the API, getToken() returns AppCheckToken?
      // But the analyzer says it's String?, so we'll handle both cases
      final tokenResult = await FirebaseAppCheck.instance.getToken(
        forceRefresh,
      );
      // If tokenResult is AppCheckToken, access .token property
      // If tokenResult is String?, use it directly
      // Using dynamic to handle both cases
      if (tokenResult != null) {
        // Try to access as AppCheckToken first
        try {
          return (tokenResult as dynamic).token as String?;
        } catch (_) {
          // If that fails, treat as String
          return tokenResult as String?;
        }
      }
      return null;
    } catch (e) {
      // Don't log as error in debug mode - it's expected if token not registered
      if (kDebugMode) {
        AppLogger.warn(
          'App Check token not available. Register debug token in Firebase Console. Error: $e',
        );
      } else {
        AppLogger.error('Error getting App Check token', e);
      }
      return null;
    }
  }

  /// Force refresh App Check token
  Future<void> refreshToken() async {
    try {
      // Get token with force refresh
      await getToken(forceRefresh: true);
      AppLogger.info('App Check token refreshed');
    } catch (e) {
      if (kDebugMode) {
        AppLogger.warn(
          'App Check token refresh failed (expected if not registered): $e',
        );
      } else {
        AppLogger.error('Error refreshing App Check token', e);
      }
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
