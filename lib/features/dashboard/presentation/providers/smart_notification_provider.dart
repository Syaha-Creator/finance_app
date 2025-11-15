import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../asset/presentation/provider/asset_provider.dart';
import '../../../debt/presentation/provider/debt_provider.dart';

class SmartNotification {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final NotificationType type;
  final NotificationPriority priority;

  SmartNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.timestamp,
    required this.type,
    required this.priority,
  });
}

enum NotificationType {
  budget,
  goal,
  investment,
  debt,
  spending,
  income,
  reminder,
}

enum NotificationPriority { low, medium, high, urgent }

class SmartNotificationService {
  static List<SmartNotification> generateNotifications({
    required List<dynamic> transactions,
    required List<dynamic> budgets,
    required List<dynamic> goals,
    required List<dynamic> assets,
    required List<dynamic> debts,
  }) {
    final notifications = <SmartNotification>[];

    // 1. Budget Notifications
    notifications.addAll(_generateBudgetNotifications(budgets, transactions));

    // 2. Goal Progress Notifications
    notifications.addAll(_generateGoalNotifications(goals));

    // 3. Debt Reminders
    notifications.addAll(_generateDebtNotifications(debts));

    // 4. Spending Pattern Notifications
    notifications.addAll(_generateSpendingNotifications(transactions));

    // 5. Investment Suggestions
    notifications.addAll(
      _generateInvestmentNotifications(assets, transactions),
    );

    // 6. Income Reminders
    notifications.addAll(_generateIncomeNotifications(transactions));

    // Sort by priority and timestamp
    notifications.sort((a, b) {
      final priorityOrder = {
        NotificationPriority.urgent: 4,
        NotificationPriority.high: 3,
        NotificationPriority.medium: 2,
        NotificationPriority.low: 1,
      };

      final priorityDiff =
          priorityOrder[b.priority]! - priorityOrder[a.priority]!;
      if (priorityDiff != 0) return priorityDiff;

      return b.timestamp.compareTo(a.timestamp);
    });

    return notifications;
  }

  static List<SmartNotification> _generateBudgetNotifications(
    List<dynamic> budgets,
    List<dynamic> transactions,
  ) {
    final notifications = <SmartNotification>[];
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

    for (final budget in budgets) {
      try {
        final budgetAmount = budget['amount'] as double? ?? 0.0;
        final category = budget['category'] as String? ?? '';

        if (budgetAmount <= 0) continue;

        // Calculate spending for this category in current month
        final monthlyTransactions =
            transactions.where((t) {
              final txnDate = t['date'] as DateTime?;
              if (txnDate == null) return false;

              final txnMonth = DateTime(txnDate.year, txnDate.month);
              return txnMonth.isAtSameMomentAs(currentMonth) &&
                  t['category'] == category &&
                  t['type'] == 'expense';
            }).toList();

        final totalSpent = monthlyTransactions.fold<double>(
          0.0,
          (sum, t) => sum + (t['amount'] as double? ?? 0.0),
        );

        final percentageUsed = totalSpent / budgetAmount;

        if (percentageUsed >= 0.8 && percentageUsed < 1.0) {
          notifications.add(
            SmartNotification(
              id: 'budget_warning_$category',
              title: 'Peringatan Budget',
              message:
                  'Budget kategori "$category" sudah ${(percentageUsed * 100).toInt()}% terpakai',
              icon: Icons.account_balance_wallet,
              color: AppColors.warning,
              timestamp: DateTime.now(),
              type: NotificationType.budget,
              priority: NotificationPriority.high,
            ),
          );
        } else if (percentageUsed >= 1.0) {
          notifications.add(
            SmartNotification(
              id: 'budget_exceeded_$category',
              title: 'Budget Terlampaui',
              message:
                  'Budget kategori "$category" sudah terlampaui ${(percentageUsed * 100).toInt()}%',
              icon: Icons.warning,
              color: AppColors.error,
              timestamp: DateTime.now(),
              type: NotificationType.budget,
              priority: NotificationPriority.urgent,
            ),
          );
        }
      } catch (e) {
        // Skip invalid budget data
        continue;
      }
    }

    return notifications;
  }

  static List<SmartNotification> _generateGoalNotifications(
    List<dynamic> goals,
  ) {
    final notifications = <SmartNotification>[];
    final now = DateTime.now();

    for (final goal in goals) {
      try {
        final goalName = goal['name'] as String? ?? '';
        final targetAmount = goal['targetAmount'] as double? ?? 0.0;
        final currentAmount = goal['currentAmount'] as double? ?? 0.0;
        final targetDate = goal['targetDate'] as DateTime?;
        final status = goal['status'] as String? ?? '';

        if (status == 'completed' || targetAmount <= 0) continue;

        final progress = currentAmount / targetAmount;
        final daysLeft = targetDate?.difference(now).inDays ?? 0;

        // Goal progress milestones
        if (progress >= 0.5 && progress < 0.75) {
          notifications.add(
            SmartNotification(
              id: 'goal_halfway_$goalName',
              title: 'Goal Progress',
              message:
                  'Goal "$goalName" sudah ${(progress * 100).toInt()}% tercapai. Lanjutkan!',
              icon: Icons.flag,
              color: AppColors.primary,
              timestamp: DateTime.now(),
              type: NotificationType.goal,
              priority: NotificationPriority.medium,
            ),
          );
        } else if (progress >= 0.75 && progress < 1.0) {
          notifications.add(
            SmartNotification(
              id: 'goal_near_complete_$goalName',
              title: 'Goal Hampir Tercapai',
              message:
                  'Goal "$goalName" sudah ${(progress * 100).toInt()}% tercapai. Tinggal sedikit lagi!',
              icon: Icons.flag,
              color: AppColors.success,
              timestamp: DateTime.now(),
              type: NotificationType.goal,
              priority: NotificationPriority.high,
            ),
          );
        }

        // Deadline reminders
        if (daysLeft <= 30 && daysLeft > 0) {
          notifications.add(
            SmartNotification(
              id: 'goal_deadline_$goalName',
              title: 'Deadline Goal',
              message:
                  'Goal "$goalName" deadline dalam $daysLeft hari. Percepat progress!',
              icon: Icons.schedule,
              color: AppColors.warning,
              timestamp: DateTime.now(),
              type: NotificationType.goal,
              priority: NotificationPriority.high,
            ),
          );
        } else if (daysLeft <= 0) {
          notifications.add(
            SmartNotification(
              id: 'goal_overdue_$goalName',
              title: 'Goal Terlambat',
              message:
                  'Goal "$goalName" sudah melewati deadline. Evaluasi dan sesuaikan target!',
              icon: Icons.schedule,
              color: AppColors.error,
              timestamp: DateTime.now(),
              type: NotificationType.goal,
              priority: NotificationPriority.urgent,
            ),
          );
        }
      } catch (e) {
        // Skip invalid goal data
        continue;
      }
    }

    return notifications;
  }

  static List<SmartNotification> _generateDebtNotifications(
    List<dynamic> debts,
  ) {
    final notifications = <SmartNotification>[];
    final now = DateTime.now();

    for (final debt in debts) {
      try {
        final personName = debt['personName'] as String? ?? '';
        final amount = debt['amount'] as double? ?? 0.0;
        final dueDate = debt['dueDate'] as DateTime?;
        final status = debt['status'] as String? ?? '';

        if (status == 'paid' || dueDate == null) continue;

        final daysUntilDue = dueDate.difference(now).inDays;

        if (daysUntilDue <= 7 && daysUntilDue > 0) {
          notifications.add(
            SmartNotification(
              id: 'debt_due_soon_$personName',
              title: 'Utang Jatuh Tempo',
              message:
                  'Utang kepada $personName jatuh tempo dalam $daysUntilDue hari (${amount.toStringAsFixed(0)})',
              icon: Icons.credit_card,
              color: AppColors.warning,
              timestamp: DateTime.now(),
              type: NotificationType.debt,
              priority: NotificationPriority.high,
            ),
          );
        } else if (daysUntilDue <= 0) {
          notifications.add(
            SmartNotification(
              id: 'debt_overdue_$personName',
              title: 'Utang Terlambat',
              message:
                  'Utang kepada $personName sudah terlambat ${daysUntilDue.abs()} hari (${amount.toStringAsFixed(0)})',
              icon: Icons.credit_card,
              color: AppColors.error,
              timestamp: DateTime.now(),
              type: NotificationType.debt,
              priority: NotificationPriority.urgent,
            ),
          );
        }
      } catch (e) {
        // Skip invalid debt data
        continue;
      }
    }

    return notifications;
  }

  static List<SmartNotification> _generateSpendingNotifications(
    List<dynamic> transactions,
  ) {
    final notifications = <SmartNotification>[];
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    // Analyze spending patterns
    final currentMonthExpenses =
        transactions.where((t) {
          final txnDate = t['date'] as DateTime?;
          if (txnDate == null) return false;

          final txnMonth = DateTime(txnDate.year, txnDate.month);
          return txnMonth.isAtSameMomentAs(currentMonth) &&
              t['type'] == 'expense';
        }).toList();

    final lastMonthExpenses =
        transactions.where((t) {
          final txnDate = t['date'] as DateTime?;
          if (txnDate == null) return false;

          final txnMonth = DateTime(txnDate.year, txnDate.month);
          return txnMonth.isAtSameMomentAs(lastMonth) && t['type'] == 'expense';
        }).toList();

    final currentTotal = currentMonthExpenses.fold<double>(
      0.0,
      (sum, t) => sum + (t['amount'] as double? ?? 0.0),
    );

    final lastTotal = lastMonthExpenses.fold<double>(
      0.0,
      (sum, t) => sum + (t['amount'] as double? ?? 0.0),
    );

    if (lastTotal > 0) {
      final changePercentage = ((currentTotal - lastTotal) / lastTotal) * 100;

      if (changePercentage > 20) {
        notifications.add(
          SmartNotification(
            id: 'spending_increase',
            title: 'Pengeluaran Meningkat',
            message:
                'Pengeluaran bulan ini meningkat ${changePercentage.toInt()}% dari bulan lalu',
            icon: Icons.trending_up,
            color: AppColors.warning,
            timestamp: DateTime.now(),
            type: NotificationType.spending,
            priority: NotificationPriority.medium,
          ),
        );
      } else if (changePercentage < -20) {
        notifications.add(
          SmartNotification(
            id: 'spending_decrease',
            title: 'Pengeluaran Berkurang',
            message:
                'Pengeluaran bulan ini berkurang ${changePercentage.abs().toInt()}% dari bulan lalu. Bagus!',
            icon: Icons.trending_down,
            color: AppColors.success,
            timestamp: DateTime.now(),
            type: NotificationType.spending,
            priority: NotificationPriority.low,
          ),
        );
      }
    }

    return notifications;
  }

  static List<SmartNotification> _generateInvestmentNotifications(
    List<dynamic> assets,
    List<dynamic> transactions,
  ) {
    final notifications = <SmartNotification>[];
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Check if user has investment assets
    final hasInvestments = assets.any((a) {
      final type = a['type'] as String? ?? '';
      return ['stocks', 'mutualFunds', 'crypto', 'property'].contains(type);
    });

    if (!hasInvestments) {
      // Suggest starting investments
      final monthlyIncome = transactions
          .where((t) {
            final txnDate = t['date'] as DateTime?;
            if (txnDate == null) return false;

            final txnMonth = DateTime(txnDate.year, txnDate.month);
            return txnMonth.isAtSameMomentAs(currentMonth) &&
                t['type'] == 'income';
          })
          .fold<double>(0.0, (sum, t) => sum + (t['amount'] as double? ?? 0.0));

      if (monthlyIncome > 5000000) {
        // 5 juta per bulan
        notifications.add(
          SmartNotification(
            id: 'investment_suggestion',
            title: 'Saran Investasi',
            message:
                'Berdasarkan cash flow Anda, pertimbangkan mulai investasi bulanan',
            icon: Icons.trending_up,
            color: AppColors.success,
            timestamp: DateTime.now(),
            type: NotificationType.investment,
            priority: NotificationPriority.medium,
          ),
        );
      }
    }

    return notifications;
  }

  static List<SmartNotification> _generateIncomeNotifications(
    List<dynamic> transactions,
  ) {
    final notifications = <SmartNotification>[];
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Check for regular income patterns
    final monthlyIncomes =
        transactions.where((t) {
          final txnDate = t['date'] as DateTime?;
          if (txnDate == null) return false;

          final txnMonth = DateTime(txnDate.year, txnDate.month);
          return txnMonth.isAtSameMomentAs(currentMonth) &&
              t['type'] == 'income';
        }).toList();

    if (monthlyIncomes.isEmpty) {
      // Remind to record income
      notifications.add(
        SmartNotification(
          id: 'income_reminder',
          title: 'Pencatatan Pemasukan',
          message:
              'Belum ada pencatatan pemasukan bulan ini. Jangan lupa catat gaji/bonus!',
          icon: Icons.attach_money,
          color: AppColors.income,
          timestamp: DateTime.now(),
          type: NotificationType.income,
          priority: NotificationPriority.medium,
        ),
      );
    }

    return notifications;
  }
}

final smartNotificationsProvider = FutureProvider<List<SmartNotification>>((
  ref,
) async {
  // Watch all relevant data providers
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final budgetsAsync = ref.watch(
    budgetsForMonthProvider((
      year: DateTime.now().year,
      month: DateTime.now().month,
    )),
  );
  final goalsAsync = ref.watch(goalsWithProgressProvider);
  final assetsAsync = ref.watch(assetsStreamProvider);
  final debtsAsync = ref.watch(debtsStreamProvider);

  // Wait for all data to be available
  final results = await Future.wait([
    transactionsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
    budgetsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
    goalsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
    assetsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
    debtsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<dynamic>[]),
      error: (_, __) => Future.value(<dynamic>[]),
    ),
  ]);

  final transactions = results[0];
  final budgets = results[1];
  final goals = results[2];
  final assets = results[3];
  final debts = results[4];

  final notifications = SmartNotificationService.generateNotifications(
    transactions: transactions,
    budgets: budgets,
    goals: goals,
    assets: assets,
    debts: debts,
  );

  // Send local notifications for urgent and high priority notifications
  _sendLocalNotifications(notifications);

  return notifications;
});

// Function to send local notifications
void _sendLocalNotifications(List<SmartNotification> notifications) {
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

// Generate navigation payload for smart notifications
String _generateNavigationPayload(SmartNotification notification) {
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

// Convert smart notification priority to local notification priority
LocalNotificationPriority _convertToLocalPriority(
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

// Generate unique notification ID
int _generateNotificationId(SmartNotification notification) {
  // Use hash of notification ID to generate unique integer ID
  return notification.id.hashCode;
}

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(smartNotificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
