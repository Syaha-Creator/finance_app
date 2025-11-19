import '../../../../core/services/local_notification_service.dart';
import '../data/models/smart_notification_model.dart';

/// Service untuk mengirim local notifications dari smart notifications
class NotificationSenderService {
  /// Send local notifications untuk urgent dan high priority notifications
  static void sendLocalNotifications(List<SmartNotification> notifications) {
    final notificationService = LocalNotificationService();

    for (final notification in notifications) {
      // Only send local notifications for urgent and high priority
      if (notification.priority == NotificationPriority.urgent ||
          notification.priority == NotificationPriority.high) {
        // Convert priority to local notification priority
        final localPriority = _convertToLocalPriority(notification.priority);

        // Generate navigation payload based on notification type
        final payload = _generateNavigationPayload(notification);

        // Use category-specific notification methods based on type
        switch (notification.type) {
          case NotificationType.budget:
            notificationService.showBudgetNotification(
              id: _generateNotificationId(notification),
              title: notification.title,
              body: notification.message,
              priority: localPriority,
              payload: payload,
              color: notification.color,
            );
            break;
          case NotificationType.goal:
            notificationService.showGoalNotification(
              id: _generateNotificationId(notification),
              title: notification.title,
              body: notification.message,
              priority: localPriority,
              payload: payload,
              color: notification.color,
            );
            break;
          case NotificationType.debt:
            notificationService.showDebtNotification(
              id: _generateNotificationId(notification),
              title: notification.title,
              body: notification.message,
              priority: localPriority,
              payload: payload,
              color: notification.color,
            );
            break;
          default:
            // Use generic smart notification for other types
            notificationService.showSmartNotification(
              id: _generateNotificationId(notification),
              title: notification.title,
              body: notification.message,
              priority: localPriority,
              payload: payload,
              color: notification.color,
            );
            break;
        }
      }
    }
  }

  /// Generate navigation payload for smart notifications
  static String _generateNavigationPayload(SmartNotification notification) {
    final notificationService = LocalNotificationService();

    switch (notification.type) {
      case NotificationType.budget:
        // Extract category from notification ID
        final category = notification.id
            .replaceFirst('budget_warning_', '')
            .replaceFirst('budget_exceeded_', '');
        final action =
            notification.id.contains('exceeded') ? 'exceeded' : 'warning';
        return notificationService.generateNavigationPayload(
          type: 'budget',
          action: action,
          data: category,
        );

      case NotificationType.goal:
        // Extract goal name from notification ID
        final goalName = notification.id
            .replaceFirst('goal_halfway_', '')
            .replaceFirst('goal_near_complete_', '')
            .replaceFirst('goal_deadline_', '')
            .replaceFirst('goal_overdue_', '');

        String action;
        if (notification.id.contains('overdue')) {
          action = 'deadline';
        } else if (notification.id.contains('deadline')) {
          action = 'deadline';
        } else if (notification.id.contains('near_complete')) {
          action = 'progress';
        } else {
          action = 'progress';
        }

        return notificationService.generateNavigationPayload(
          type: 'goal',
          action: action,
          data: goalName,
        );

      case NotificationType.debt:
        // Extract person name from notification ID
        final personName = notification.id
            .replaceFirst('debt_due_soon_', '')
            .replaceFirst('debt_overdue_', '');

        final action =
            notification.id.contains('overdue') ? 'overdue' : 'due_soon';

        return notificationService.generateNavigationPayload(
          type: 'debt',
          action: action,
          data: personName,
        );

      case NotificationType.investment:
        return notificationService.generateNavigationPayload(
          type: 'investment',
          action: 'suggestion',
        );

      case NotificationType.spending:
        return notificationService.generateNavigationPayload(
          type: 'transaction',
          action: 'spending_pattern',
        );

      case NotificationType.income:
        return notificationService.generateNavigationPayload(
          type: 'transaction',
          action: 'income_reminder',
        );

      default:
        return notificationService.generateNavigationPayload(
          type: 'reminder',
          action: 'view',
        );
    }
  }

  /// Convert smart notification priority to local notification priority
  static LocalNotificationPriority _convertToLocalPriority(
    NotificationPriority priority,
  ) {
    switch (priority) {
      case NotificationPriority.urgent:
        return LocalNotificationPriority.urgent;
      case NotificationPriority.high:
        return LocalNotificationPriority.high;
      case NotificationPriority.medium:
        return LocalNotificationPriority.medium;
      case NotificationPriority.low:
        return LocalNotificationPriority.low;
    }
  }

  /// Generate unique notification ID
  static int _generateNotificationId(SmartNotification notification) {
    // Use hash of notification ID to generate unique integer ID
    return notification.id.hashCode;
  }
}
