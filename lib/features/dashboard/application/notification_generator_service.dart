import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/models/smart_notification_model.dart';

/// Service untuk generate smart notifications berdasarkan data finansial
class NotificationGeneratorService {
  /// Generate semua notifications berdasarkan data yang diberikan
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
    return _sortNotifications(notifications);
  }

  /// Sort notifications by priority and timestamp
  static List<SmartNotification> _sortNotifications(
    List<SmartNotification> notifications,
  ) {
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
