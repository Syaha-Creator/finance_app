import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

class BudgetReportSection extends StatelessWidget {
  final DashboardAnalysis analysis;

  const BudgetReportSection({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (analysis.budgets.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Anggaran Bulan Ini',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...analysis.budgets.map((budget) {
            final spentAmount =
                analysis.expenseByCategory[budget.categoryName] ?? 0.0;
            final progress =
                budget.amount > 0
                    ? (spentAmount / budget.amount).clamp(0.0, 1.0)
                    : 0.0;
            final progressColor =
                progress < 0.5
                    ? AppColors.income
                    : (progress < 0.9 ? Colors.orange : AppColors.expense);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          budget.categoryName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,

                      backgroundColor: theme.colorScheme.onSurface.withAlpha(
                        30,
                      ),
                      color: progressColor,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppFormatters.currency.format(spentAmount),
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'dari ${AppFormatters.currency.format(budget.amount)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
