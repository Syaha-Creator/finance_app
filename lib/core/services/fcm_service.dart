import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'local_notification_service.dart';

/// Top-level function untuk handle background messages
/// Harus top-level function, tidak bisa di dalam class
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Handling background message: ${message.messageId}');
  // Background message handling
  // Local notifications akan di-handle oleh onMessage handler
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM service
  Future<void> init() async {
    try {
      // Request permission untuk notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      AppLogger.info('FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        await _getFCMToken();

        // Setup message handlers
        _setupMessageHandlers();

        // Setup token refresh listener
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _saveTokenToFirestore(newToken);
          AppLogger.info('FCM Token refreshed: $newToken');
        });
      }
    } catch (e) {
      AppLogger.error('Error initializing FCM', e);
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        AppLogger.info('FCM Token: $_fcmToken');
        await _saveTokenToFirestore(_fcmToken!);
      }
    } catch (e) {
      AppLogger.error('Error getting FCM token', e);
    }
  }

  /// Save FCM token to Firestore (support multiple devices)
  /// Security: Token disimpan berdasarkan user.uid untuk isolasi per user
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Security: Token hanya bisa disimpan oleh user yang sudah authenticated
        // Token disimpan di users/{user.uid} untuk isolasi per user
        // Get device info
        final deviceId = await _getDeviceId();
        final deviceName = await _getDeviceName();
        final platform = _getPlatform();

        // Check if token already exists
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        final existingTokens =
            userDoc.data()?['fcmTokens'] as List<dynamic>? ?? [];

        // Check if this device already has a token (by deviceId or by token)
        // First check by deviceId (preferred)
        int existingTokenIndex = existingTokens.indexWhere(
          (t) => t['deviceId'] == deviceId,
        );
        
        // If not found by deviceId, check by token (in case deviceId changed)
        if (existingTokenIndex < 0) {
          existingTokenIndex = existingTokens.indexWhere(
            (t) => t['token'] == token,
          );
        }

        final now = Timestamp.now();

        final tokenData = {
          'token': token,
          'deviceId': deviceId,
          'deviceName': deviceName,
          'platform': platform,
          'lastUsed': now,
        };

        if (existingTokenIndex >= 0) {
          // Update existing token for this device
          // Preserve createdAt if exists
          final existingToken = existingTokens[existingTokenIndex];
          if (existingToken['createdAt'] != null) {
            tokenData['createdAt'] = existingToken['createdAt'];
          }
          existingTokens[existingTokenIndex] = tokenData;
          
          // Cleanup: Remove any duplicate tokens with same token value but different deviceId
          // This handles the case where same token was saved with different deviceIds
          existingTokens.removeWhere((t) => 
            t['token'] == token && 
            t['deviceId'] != deviceId
          );
        } else {
          // Add new token for this device
          tokenData['createdAt'] = now;
          existingTokens.add(tokenData);
        }

        // Save all tokens
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmTokens': existingTokens,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        AppLogger.info('FCM Token saved to Firestore for device: $deviceName');
      }
    } catch (e) {
      AppLogger.error('Error saving FCM token to Firestore', e);
    }
  }

  /// Get unique device ID (persistent across app restarts)
  Future<String> _getDeviceId() async {
    const String deviceIdKey = 'fcm_device_id';
    final prefs = await SharedPreferences.getInstance();
    
    // Check if deviceId already exists
    String? existingDeviceId = prefs.getString(deviceIdKey);
    
    if (existingDeviceId != null && existingDeviceId.isNotEmpty) {
      // Return existing deviceId
      return existingDeviceId;
    }
    
    // Generate new deviceId if doesn't exist
    final platform = _getPlatform();
    final newDeviceId = '${platform}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Save to SharedPreferences for persistence
    await prefs.setString(deviceIdKey, newDeviceId);
    
    AppLogger.info('Generated new deviceId: $newDeviceId');
    return newDeviceId;
  }

  /// Get device name
  Future<String> _getDeviceName() async {
    final platform = _getPlatform();
    // In production, use device_info_plus to get actual device name
    // For now, return platform name
    switch (platform) {
      case 'android':
        return 'Android Device';
      case 'ios':
        return 'iOS Device';
      case 'web':
        return 'Web Browser';
      default:
        return 'Unknown Device';
    }
  }

  /// Get platform name
  String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Received foreground message: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Notification opened app: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Check if app was opened from terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.info(
          'App opened from terminated state: ${message.messageId}',
        );
        _handleNotificationTap(message);
      }
    });
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show local notification for foreground messages
      await _localNotificationService.showSmartNotification(
        id: message.hashCode,
        title: notification.title ?? 'Finance App',
        body: notification.body ?? '',
        priority: _getPriorityFromData(data),
        payload: _generatePayload(data),
        color: _getColorFromData(data),
        categoryIdentifier: _getCategoryFromData(data),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final navigationData = _parseNotificationData(data);
    if (navigationData != null) {
      _navigateToScreen(navigationData);
    }
  }

  /// Parse notification data untuk navigasi
  Map<String, dynamic>? _parseNotificationData(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final action = data['action'] as String?;
      final notificationData = data['data'] as String?;

      if (type != null && action != null) {
        return {'type': type, 'action': action, 'data': notificationData};
      }
    } catch (e) {
      AppLogger.error('Error parsing notification data', e);
    }
    return null;
  }

  /// Navigate to screen based on notification data
  void _navigateToScreen(Map<String, dynamic> navigationData) {
    // Parse navigation data dan trigger navigation
    AppLogger.info('FCM Navigation data: $navigationData');

    // Generate payload
    final payload = _localNotificationService.generateNavigationPayload(
      type: navigationData['type'] as String,
      action: navigationData['action'] as String,
      data: navigationData['data'] as String?,
    );

    // Trigger navigation dengan delay kecil untuk memastikan app sudah ready
    Future.delayed(const Duration(milliseconds: 500), () {
      _localNotificationService.handleNavigationFromPayload(payload);
    });
  }

  /// Generate payload from notification data
  String? _generatePayload(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final action = data['action'] as String?;
      final notificationData = data['data'] as String?;

      if (type != null && action != null) {
        return _localNotificationService.generateNavigationPayload(
          type: type,
          action: action,
          data: notificationData,
        );
      }
    } catch (e) {
      AppLogger.error('Error generating payload', e);
    }
    return null;
  }

  /// Get priority from notification data
  LocalNotificationPriority _getPriorityFromData(Map<String, dynamic> data) {
    final priority = data['priority'] as String?;
    switch (priority) {
      case 'urgent':
        return LocalNotificationPriority.urgent;
      case 'high':
        return LocalNotificationPriority.high;
      case 'medium':
        return LocalNotificationPriority.medium;
      case 'low':
      default:
        return LocalNotificationPriority.low;
    }
  }

  /// Get color from notification data
  Color? _getColorFromData(Map<String, dynamic> data) {
    final colorString = data['color'] as String?;
    if (colorString == null) return null;

    // Try to parse color from hex string or use default based on priority
    try {
      // Remove # if present
      final hex = colorString.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      // If parsing fails, return null (will use default priority color)
      return null;
    }
  }

  /// Get category from notification data
  String? _getCategoryFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'budget':
        return 'BUDGET_CATEGORY';
      case 'goal':
        return 'GOAL_CATEGORY';
      case 'debt':
        return 'DEBT_CATEGORY';
      default:
        return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.info('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Error subscribing to topic', e);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic', e);
    }
  }

  /// Delete FCM token (on logout) - removes token from Firestore
  Future<void> deleteToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final deviceId = await _getDeviceId();

        // Remove this device's token from Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        final existingTokens =
            userDoc.data()?['fcmTokens'] as List<dynamic>? ?? [];
        existingTokens.removeWhere((t) => t['deviceId'] == deviceId);

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmTokens': existingTokens,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Also delete token from device
        await _firebaseMessaging.deleteToken();
        _fcmToken = null;

        AppLogger.info('FCM Token deleted for device: $deviceId');
      }
    } catch (e) {
      AppLogger.error('Error deleting FCM token', e);
    }
  }

  /// Get all FCM tokens for current user (for server-side sending)
  /// Security: Hanya mengembalikan token milik user yang sedang login
  Future<List<String>> getAllUserTokens() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Security: Hanya ambil token dari document user yang sedang login
        // Tidak bisa mengambil token user lain karena menggunakan user.uid
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        final tokens = userDoc.data()?['fcmTokens'] as List<dynamic>? ?? [];
        return tokens.map((t) => t['token'] as String).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Error getting user tokens', e);
      return [];
    }
  }
}
