import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

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

  // Navigate ke screen berdasarkan tipe notifikasi
  void _navigateToScreen(Map<String, dynamic> navigationData) {
    final type = navigationData['type'];
    final action = navigationData['action'];
    final data = navigationData['data'];

    // Pastikan navigator key tersedia
    if (navigatorKey.currentState == null) {
      AppLogger.warn('Navigator not available');
      return;
    }

    try {
      switch (type) {
        case 'budget':
          _handleBudgetNavigation(action, data);
          break;
        case 'goal':
          _handleGoalNavigation(action, data);
          break;
        case 'debt':
          _handleDebtNavigation(action, data);
          break;
        case 'asset':
          _handleAssetNavigation(action, data);
          break;
        case 'transaction':
          _handleTransactionNavigation(action, data);
          break;
        case 'investment':
          _handleInvestmentNavigation(action, data);
          break;
        default:
          AppLogger.warn('Unknown notification type: $type');
      }
    } catch (e) {
      AppLogger.error('Error navigating to screen', e);
    }
  }

  // Handle navigasi untuk budget notifications
  void _handleBudgetNavigation(String action, String? data) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final router = GoRouter.of(ctx);
    switch (action) {
      case 'view':
        router.go('/budget');
        break;
      case 'warning':
        router.go('/budget', extra: {'highlightCategory': data});
        break;
      case 'exceeded':
        router.go(
          '/budget',
          extra: {'highlightCategory': data, 'status': 'exceeded'},
        );
        break;
      default:
        router.go('/budget');
    }
  }

  // Handle navigasi untuk goal notifications
  void _handleGoalNavigation(String action, String? data) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final router = GoRouter.of(ctx);
    switch (action) {
      case 'view':
        router.go('/goals');
        break;
      case 'progress':
        router.go('/goals', extra: {'highlightGoal': data});
        break;
      case 'deadline':
        router.go(
          '/goals',
          extra: {'highlightGoal': data, 'status': 'deadline'},
        );
        break;
      default:
        router.go('/goals');
    }
  }

  // Handle navigasi untuk debt notifications
  void _handleDebtNavigation(String action, String? data) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final router = GoRouter.of(ctx);
    switch (action) {
      case 'view':
        router.go('/debt');
        break;
      case 'due_soon':
        router.go(
          '/debt',
          extra: {'highlightDebt': data, 'status': 'due_soon'},
        );
        break;
      case 'overdue':
        router.go('/debt', extra: {'highlightDebt': data, 'status': 'overdue'});
        break;
      case 'mark_paid':
        router.go(
          '/debt',
          extra: {'highlightDebt': data, 'action': 'mark_paid'},
        );
        break;
      default:
        router.go('/debt');
    }
  }

  // Handle navigasi untuk asset notifications
  void _handleAssetNavigation(String action, String? data) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final router = GoRouter.of(ctx);
    switch (action) {
      case 'view':
        router.go('/assets');
        break;
      case 'investment_suggestion':
        router.go('/assets', extra: {'highlightType': 'investment'});
        break;
      default:
        router.go('/assets');
    }
  }

  // Handle navigasi untuk transaction notifications
  void _handleTransactionNavigation(String action, String? data) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final router = GoRouter.of(ctx);
    switch (action) {
      case 'view':
        router.go('/transactions');
        break;
      case 'spending_pattern':
        router.go('/reports', extra: {'highlightSection': 'spending_pattern'});
        break;
      case 'income_reminder':
        router.go('/add-transaction', extra: {'type': 'income'});
        break;
      default:
        router.go('/transactions');
    }
  }

  // Handle navigasi untuk investment notifications
  void _handleInvestmentNavigation(String action, String? data) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final router = GoRouter.of(ctx);
    switch (action) {
      case 'view':
        router.go('/assets');
        break;
      case 'suggestion':
        router.go('/assets', extra: {'focus': 'investment', 'showGuide': true});
        break;
      default:
        router.go('/assets');
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

  // Show budget notification with specific category
  Future<void> showBudgetNotification({
    required int id,
    required String title,
    required String body,
    required LocalNotificationPriority priority,
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
      categoryIdentifier: 'BUDGET_CATEGORY',
    );
  }

  // Show goal notification with specific category
  Future<void> showGoalNotification({
    required int id,
    required String title,
    required String body,
    required LocalNotificationPriority priority,
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
      categoryIdentifier: 'GOAL_CATEGORY',
    );
  }

  // Show debt notification with specific category
  Future<void> showDebtNotification({
    required int id,
    required String title,
    required String body,
    required LocalNotificationPriority priority,
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
      categoryIdentifier: 'DEBT_CATEGORY',
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
