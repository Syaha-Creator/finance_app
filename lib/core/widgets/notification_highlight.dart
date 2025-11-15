import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationHighlight extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const NotificationHighlight({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                minimumSize: Size.zero,
              ),
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0,
                ),
              ),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: color.withValues(alpha: 0.6),
                size: 20.0,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32.0,
                minHeight: 32.0,
              ),
            ),
        ],
      ),
    );
  }
}

// Specialized highlight widgets for different notification types
class BudgetWarningHighlight extends StatelessWidget {
  final String category;
  final double percentageUsed;
  final VoidCallback? onViewBudget;

  const BudgetWarningHighlight({
    super.key,
    required this.category,
    required this.percentageUsed,
    this.onViewBudget,
  });

  @override
  Widget build(BuildContext context) {
    final isExceeded = percentageUsed >= 1.0;
    final color = isExceeded ? AppColors.error : AppColors.warning;
    final message =
        isExceeded
            ? 'Budget kategori "$category" sudah terlampaui ${(percentageUsed * 100).toInt()}%'
            : 'Budget kategori "$category" sudah ${(percentageUsed * 100).toInt()}% terpakai';

    return NotificationHighlight(
      message: message,
      icon: isExceeded ? Icons.warning : Icons.account_balance_wallet,
      color: color,
      onAction: onViewBudget,
      actionLabel: 'Lihat Budget',
    );
  }
}

class GoalProgressHighlight extends StatelessWidget {
  final String goalName;
  final double progress;
  final bool isDeadline;
  final VoidCallback? onViewGoal;

  const GoalProgressHighlight({
    super.key,
    required this.goalName,
    required this.progress,
    this.isDeadline = false,
    this.onViewGoal,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDeadline ? AppColors.warning : AppColors.primary;
    final message =
        isDeadline
            ? 'Goal "$goalName" deadline dalam ${(progress * 100).toInt()} hari'
            : 'Goal "$goalName" sudah ${(progress * 100).toInt()}% tercapai';

    return NotificationHighlight(
      message: message,
      icon: isDeadline ? Icons.schedule : Icons.flag,
      color: color,
      onAction: onViewGoal,
      actionLabel: 'Lihat Goal',
    );
  }
}

class DebtReminderHighlight extends StatelessWidget {
  final String personName;
  final double amount;
  final bool isOverdue;
  final VoidCallback? onViewDebt;
  final VoidCallback? onMarkPaid;

  const DebtReminderHighlight({
    super.key,
    required this.personName,
    required this.amount,
    this.isOverdue = false,
    this.onViewDebt,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? AppColors.error : AppColors.warning;
    final message =
        isOverdue
            ? 'Utang kepada $personName sudah terlambat (${amount.toStringAsFixed(0)})'
            : 'Utang kepada $personName jatuh tempo (${amount.toStringAsFixed(0)})';

    return NotificationHighlight(
      message: message,
      icon: Icons.credit_card,
      color: color,
      onAction: onViewDebt,
      actionLabel: 'Lihat Utang',
    );
  }
}

class InvestmentSuggestionHighlight extends StatelessWidget {
  final VoidCallback? onViewAssets;
  final VoidCallback? onDismiss;

  const InvestmentSuggestionHighlight({
    super.key,
    this.onViewAssets,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationHighlight(
      message:
          'Berdasarkan cash flow Anda, pertimbangkan mulai investasi bulanan',
      icon: Icons.trending_up,
      color: AppColors.success,
      onAction: onViewAssets,
      actionLabel: 'Lihat Aset',
      onDismiss: onDismiss,
    );
  }
}
