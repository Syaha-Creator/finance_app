import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../providers/dashboard_providers.dart';

class DashboardHeader extends ConsumerWidget {
  final DashboardAnalysis analysis;

  const DashboardHeader({super.key, required this.analysis, required String userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),

        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo Bulan Ini',

            style: TextStyle(
              color: colorScheme.onPrimary.withAlpha(204),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppFormatters.currency.format(analysis.balance),
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIncomeExpenseRow(
                context,
                Icons.arrow_upward,
                'Pemasukan',
                AppFormatters.currency.format(analysis.totalIncome),
                AppColors.income,
              ),
              _buildIncomeExpenseRow(
                context,
                Icons.arrow_downward,
                'Pengeluaran',
                AppFormatters.currency.format(analysis.totalExpense),
                AppColors.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onPrimary.withAlpha(204),
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
