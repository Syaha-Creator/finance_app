import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';
import '../../../goals/data/models/goal_model.dart';

class FinancialRatioCard extends ConsumerWidget {
  const FinancialRatioCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysis = ref.watch(dashboardAnalysisProvider);

    // Calculate financial ratios based on real data
    final ratios = _calculateFinancialRatios(analysis);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rasio Keuangan',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Indikator kesehatan keuangan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ratios List
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children:
                  ratios.map((ratio) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ratio Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (ratio['color'] as Color).withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  ratio['icon'] as IconData,
                                  color: ratio['color'] as Color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ratio['label'] as String,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: (ratio['color'] as Color).withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: (ratio['color'] as Color).withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  ratio['value'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: ratio['color'] as Color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Recommendation
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.1,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: AppColors.accent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ratio['recommendation'] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _calculateFinancialRatios(
    DashboardAnalysis analysis,
  ) {
    final ratios = <Map<String, dynamic>>[];

    // 1. Savings Rate
    if (analysis.totalIncome > 0) {
      final savingsRate = (analysis.balance / analysis.totalIncome * 100);
      final savingsColor =
          savingsRate >= 20
              ? AppColors.success
              : savingsRate >= 10
              ? AppColors.warning
              : AppColors.error;
      final savingsRecommendation =
          savingsRate >= 20
              ? 'Target 20-30% untuk kondisi keuangan yang sehat. Anda sudah mencapai target!'
              : savingsRate >= 10
              ? 'Target 20-30% untuk kondisi keuangan yang sehat. Coba tingkatkan tabungan.'
              : 'Target 20-30% untuk kondisi keuangan yang sehat. Pertimbangkan mengurangi pengeluaran.';

      ratios.add({
        'label': 'Savings Rate',
        'value': '${savingsRate.toStringAsFixed(1)}%',
        'icon': Icons.savings,
        'color': savingsColor,
        'recommendation': savingsRecommendation,
      });
    }

    // 2. Expense Ratio
    if (analysis.totalIncome > 0) {
      final expenseRatio = (analysis.totalExpense / analysis.totalIncome * 100);
      final expenseColor =
          expenseRatio <= 70
              ? AppColors.success
              : expenseRatio <= 80
              ? AppColors.warning
              : AppColors.error;
      final expenseRecommendation =
          expenseRatio <= 70
              ? 'Pengeluaran terkontrol dengan baik. Pertahankan rasio di bawah 70%.'
              : expenseRatio <= 80
              ? 'Pengeluaran masih dalam batas wajar. Target rasio di bawah 70%.'
              : 'Pengeluaran terlalu tinggi. Coba kurangi pengeluaran non-esensial.';

      ratios.add({
        'label': 'Expense Ratio',
        'value': '${expenseRatio.toStringAsFixed(1)}%',
        'icon': Icons.trending_down,
        'color': expenseColor,
        'recommendation': expenseRecommendation,
      });
    }

    // 3. Budget Utilization
    if (analysis.budgets.isNotEmpty) {
      int wellManagedBudgets = 0;
      for (final budget in analysis.budgets) {
        final spentAmount =
            analysis.expenseByCategory[budget.categoryName] ?? 0.0;
        final usagePercentage =
            budget.amount > 0 ? (spentAmount / budget.amount) : 0.0;
        if (usagePercentage <= 0.9) {
          wellManagedBudgets++;
        }
      }
      final budgetUtilization =
          (wellManagedBudgets / analysis.budgets.length * 100);
      final budgetColor =
          budgetUtilization >= 80
              ? AppColors.success
              : budgetUtilization >= 60
              ? AppColors.warning
              : AppColors.error;
      final budgetRecommendation =
          budgetUtilization >= 80
              ? 'Pengelolaan anggaran sangat baik. Pertahankan disiplin ini.'
              : budgetUtilization >= 60
              ? 'Pengelolaan anggaran cukup baik. Ada ruang untuk peningkatan.'
              : 'Pengelolaan anggaran perlu diperbaiki. Fokus pada kontrol pengeluaran.';

      ratios.add({
        'label': 'Budget Management',
        'value': '${budgetUtilization.toStringAsFixed(0)}%',
        'icon': Icons.account_balance_wallet,
        'color': budgetColor,
        'recommendation': budgetRecommendation,
      });
    }

    // 4. Goals Progress
    if (analysis.goals.isNotEmpty) {
      final averageProgress =
          analysis.goals.fold<double>(
            0.0,
            (sum, goal) => sum + goal.progressPercentage,
          ) /
          analysis.goals.length;
      final goalColor =
          averageProgress >= 80
              ? AppColors.success
              : averageProgress >= 50
              ? AppColors.warning
              : AppColors.error;
      final goalRecommendation =
          averageProgress >= 80
              ? 'Progress tujuan keuangan sangat baik. Lanjutkan dengan konsisten.'
              : averageProgress >= 50
              ? 'Progress tujuan keuangan cukup baik. Tingkatkan kontribusi untuk mencapai target.'
              : 'Progress tujuan keuangan masih rendah. Pertimbangkan menambah kontribusi atau menyesuaikan target.';

      ratios.add({
        'label': 'Goals Progress',
        'value': '${averageProgress.toStringAsFixed(0)}%',
        'icon': Icons.flag,
        'color': goalColor,
        'recommendation': goalRecommendation,
      });
    }

    // 5. Emergency Fund Ratio (simplified)
    if (analysis.totalExpense > 0) {
      // This is a simplified calculation. In a real app, you'd use actual emergency fund data
      final emergencyFundRatio = 3.0; // Simplified: assume 3 months of expenses
      final emergencyColor =
          emergencyFundRatio >= 6
              ? AppColors.success
              : emergencyFundRatio >= 3
              ? AppColors.warning
              : AppColors.error;
      final emergencyRecommendation =
          emergencyFundRatio >= 6
              ? 'Dana darurat mencukupi untuk 6+ bulan. Sangat baik!'
              : emergencyFundRatio >= 3
              ? 'Dana darurat mencukupi untuk 3 bulan. Target 6-12 bulan untuk keamanan lebih.'
              : 'Dana darurat kurang dari 3 bulan. Prioritaskan untuk menambah dana darurat.';

      ratios.add({
        'label': 'Emergency Fund',
        'value': '${emergencyFundRatio.toStringAsFixed(1)} bln',
        'icon': Icons.emergency,
        'color': emergencyColor,
        'recommendation': emergencyRecommendation,
      });
    }

    return ratios;
  }
}
