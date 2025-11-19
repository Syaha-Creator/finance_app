import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../routes/route_paths.dart';
import '../theme/app_colors.dart';
import '../utils/logger.dart';

// Custom notification priority enum to avoid conflicts
enum LocalNotificationPriority { low, medium, high, urgent }

// Notification action types for navigation
enum NotificationActionType {
  viewBudget,
  viewGoal,
  viewDebt,
  markDebtPaid,
  viewAsset,
  viewTransaction,
  dismiss,
}

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Global navigator key untuk akses context dari service
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> init() async {
    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    AppLogger.info('Notification tapped: ${response.payload}');

    // Parse payload untuk mendapatkan informasi navigasi
    final navigationData = _parseNotificationPayload(response.payload);
    if (navigationData != null) {
      _navigateToScreen(navigationData);
    }
  }

  /// Public method untuk handle navigation dari FCM atau external sources
  void handleNavigationFromPayload(String? payload) {
    if (payload == null) return;
    
    final navigationData = _parseNotificationPayload(payload);
    if (navigationData != null) {
      _navigateToScreen(navigationData);
    }
  }

  // Parse payload notifikasi untuk mendapatkan data navigasi
  Map<String, dynamic>? _parseNotificationPayload(String? payload) {
    if (payload == null) return null;

    try {
      // Format payload: "type:action:data"
      final parts = payload.split(':');
      if (parts.length >= 2) {
        return {
          'type': parts[0],
          'action': parts[1],
          'data': parts.length > 2 ? parts[2] : null,
        };
      }
    } catch (e) {
      AppLogger.error('Error parsing notification payload', e);
    }
    return null;
  }

  // Navigation routing configuration
  static final Map<String, Map<String, Function(String?, GoRouter)>>
  _navigationRoutes = {
    'budget': {
      'view': (data, router) => router.go(RoutePaths.budget),
      'warning':
          (data, router) =>
              router.go(RoutePaths.budget, extra: {'highlightCategory': data}),
      'exceeded':
          (data, router) => router.go(
            RoutePaths.budget,
            extra: {'highlightCategory': data, 'status': 'exceeded'},
          ),
    },
    'goal': {
      'view': (data, router) => router.go(RoutePaths.goals),
      'progress':
          (data, router) =>
              router.go(RoutePaths.goals, extra: {'highlightGoal': data}),
      'deadline':
          (data, router) => router.go(
            RoutePaths.goals,
            extra: {'highlightGoal': data, 'status': 'deadline'},
          ),
    },
    'debt': {
      'view': (data, router) => router.go(RoutePaths.debt),
      'due_soon':
          (data, router) => router.go(
            RoutePaths.debt,
            extra: {'highlightDebt': data, 'status': 'due_soon'},
          ),
      'overdue':
          (data, router) => router.go(
            RoutePaths.debt,
            extra: {'highlightDebt': data, 'status': 'overdue'},
          ),
      'mark_paid':
          (data, router) => router.go(
            RoutePaths.debt,
            extra: {'highlightDebt': data, 'action': 'mark_paid'},
          ),
    },
    'asset': {
      'view': (data, router) => router.go(RoutePaths.assets),
      'investment_suggestion':
          (data, router) => router.go(
            RoutePaths.assets,
            extra: {'highlightType': 'investment'},
          ),
    },
    'transaction': {
      'view': (data, router) => router.go(RoutePaths.transactions),
      'spending_pattern':
          (data, router) => router.go(
            RoutePaths.reports,
            extra: {'highlightSection': 'spending_pattern'},
          ),
      'income_reminder':
          (data, router) =>
              router.go(RoutePaths.addTransaction, extra: {'type': 'income'}),
    },
    'investment': {
      'view': (data, router) => router.go(RoutePaths.assets),
      'suggestion':
          (data, router) => router.go(
            RoutePaths.assets,
            extra: {'focus': 'investment', 'showGuide': true},
          ),
    },
  };

  // Navigate ke screen berdasarkan tipe notifikasi
  void _navigateToScreen(Map<String, dynamic> navigationData) {
    final type = navigationData['type'] as String?;
    final action = navigationData['action'] as String?;
    final data = navigationData['data'] as String?;

    // Pastikan navigator key tersedia
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      AppLogger.warn('Navigator not available');
      return;
    }

    try {
      final router = GoRouter.of(ctx);
      final typeRoutes = _navigationRoutes[type];

      if (typeRoutes == null) {
        AppLogger.warn('Unknown notification type: $type');
        return;
      }

      // Get handler for specific action, fallback to 'view'
      final handler = typeRoutes[action] ?? typeRoutes['view'];
      if (handler != null) {
        handler(data, router);
      } else {
        // Fallback to default view
        final defaultHandler = typeRoutes['view'];
        if (defaultHandler != null) {
          defaultHandler(data, router);
        }
      }
    } catch (e) {
      AppLogger.error('Error navigating to screen', e);
    }
  }

  // Generate payload untuk notifikasi dengan navigasi
  String generateNavigationPayload({
    required String type,
    required String action,
    String? data,
  }) {
    final parts = [type, action];
    if (data != null) {
      parts.add(data);
    }
    return parts.join(':');
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    LocalNotificationPriority priority = LocalNotificationPriority.high,
    Color? color,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'finance_app_channel',
          'Finance App Notifications',
          channelDescription: 'Smart financial notifications and reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          color: AppColors.primary,
          enableLights: true,
          ledColor: AppColors.primary,
          ledOnMs: 1000,
          ledOffMs: 500,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Show smart notification with priority-based styling
  Future<void> showSmartNotification({
    required int id,
    required String title,
    required String body,
    required LocalNotificationPriority priority,
    String? payload,
    Color? color,
    String? categoryIdentifier,
  }) async {
    Color notificationColor = color ?? _getPriorityColor(priority);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'finance_app_smart_channel',
          'Smart Finance Notifications',
          channelDescription: 'Intelligent financial insights and alerts',
          importance: _getPriorityImportance(priority),
          priority: _getPriorityPriority(priority),
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          color: AppColors.primary,
          enableLights: true,
          ledColor: notificationColor,
          ledOnMs: priority == LocalNotificationPriority.urgent ? 2000 : 1000,
          ledOffMs: priority == LocalNotificationPriority.urgent ? 500 : 500,
          channelShowBadge: true,
          number: 1,
          // Android action buttons
          actions: [
            const AndroidNotificationAction(
              'VIEW_DETAILS',
              'Lihat Detail',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'DISMISS',
              'Tutup',
              cancelNotification: true,
            ),
          ],
        );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
          categoryIdentifier: categoryIdentifier, // iOS notification category
          // iOS specific settings
          interruptionLevel:
              priority == LocalNotificationPriority.urgent
                  ? InterruptionLevel.critical
                  : InterruptionLevel.active,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Show notification with specific category identifier.
  ///
  /// [category] - The notification category (e.g., 'BUDGET_CATEGORY', 'GOAL_CATEGORY', 'DEBT_CATEGORY')
  Future<void> showCategoryNotification({
    required int id,
    required String title,
    required String body,
    required LocalNotificationPriority priority,
    required String category,
    String? payload,
    Color? color,
  }) async {
    await showSmartNotification(
      id: id,
      title: title,
      body: body,
      priority: priority,
      payload: payload,
      color: color,
      categoryIdentifier: category,
    );
  }

  // Convenience methods for specific categories (backward compatibility)
  Future<void> showBudgetNotification({
    required int id,
    required String title,
    required String body,
    required LocalNotificationPriority priority,
    String? payload,
    Color? color,
  }) async {
    await showCategoryNotification(
      id: id,
      title: title,
      body: body,
      priority: priority,
      category: 'BUDGET_CATEGORY',
      payload: payload,
      color: color,
    );
  }

  Future<void> showGoalNotification({
    required int id,
    required String title,
    required String body,
    required LocalNotificationPriority priority,
    String? payload,
    Color? color,
  }) async {
    await showCategoryNotification(
      id: id,
      title: title,
      body: body,
      priority: priority,
      category: 'GOAL_CATEGORY',
      payload: payload,
      color: color,
    );
  }

  Future<void> showDebtNotification({
    required int id,
    required String title,
    required String body,
    required LocalNotificationPriority priority,
    String? payload,
    Color? color,
  }) async {
    await showCategoryNotification(
      id: id,
      title: title,
      body: body,
      priority: priority,
      category: 'DEBT_CATEGORY',
      payload: payload,
      color: color,
    );
  }

  Color _getPriorityColor(LocalNotificationPriority priority) {
    switch (priority) {
      case LocalNotificationPriority.urgent:
        return AppColors.error;
      case LocalNotificationPriority.high:
        return AppColors.warning;
      case LocalNotificationPriority.medium:
        return AppColors.primary;
      case LocalNotificationPriority.low:
        return AppColors.success;
    }
  }

  Importance _getPriorityImportance(LocalNotificationPriority priority) {
    switch (priority) {
      case LocalNotificationPriority.urgent:
        return Importance.max;
      case LocalNotificationPriority.high:
        return Importance.high;
      case LocalNotificationPriority.medium:
        return Importance.defaultImportance;
      case LocalNotificationPriority.low:
        return Importance.low;
    }
  }

  Priority _getPriorityPriority(LocalNotificationPriority priority) {
    switch (priority) {
      case LocalNotificationPriority.urgent:
        return Priority.max;
      case LocalNotificationPriority.high:
        return Priority.high;
      case LocalNotificationPriority.medium:
        return Priority.defaultPriority;
      case LocalNotificationPriority.low:
        return Priority.low;
    }
  }
}
