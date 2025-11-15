import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';

class PersonalizedInsights extends ConsumerWidget {
  const PersonalizedInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysis = ref.watch(dashboardAnalysisProvider);

    // Generate personalized insights based on real data
    final insights = _generatePersonalizedInsights(analysis);

    if (insights.isEmpty) {
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insight Personal',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Dapatkan saran yang disesuaikan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum Ada Insight',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lanjutkan menggunakan aplikasi untuk mendapatkan insight personal',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insight Personal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Dapatkan saran yang disesuaikan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${insights.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Insights List
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children:
                  insights.map((insight) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (insight['color'] as Color).withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              insight['icon'] as IconData,
                              color: insight['color'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight['title'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  insight['description'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.4,
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

  List<Map<String, dynamic>> _generatePersonalizedInsights(
    DashboardAnalysis analysis,
  ) {
    final insights = <Map<String, dynamic>>[];

    // Check savings rate
    if (analysis.totalIncome > 0) {
      final savingsRate = analysis.balance / analysis.totalIncome;
      if (savingsRate >= 0.2) {
        insights.add({
          'title': 'Tabungan Luar Biasa! 🎉',
          'description':
              'Anda berhasil menabung ${(savingsRate * 100).toStringAsFixed(0)}% dari pendapatan. Pertahankan kebiasaan baik ini!',
          'icon': Icons.celebration,
          'color': AppColors.success,
        });
      } else if (savingsRate < 0.1) {
        insights.add({
          'title': 'Optimasi Pengeluaran',
          'description':
              'Pengeluaran bulan ini cukup tinggi. Coba identifikasi kategori yang bisa dikurangi.',
          'icon': Icons.analytics,
          'color': AppColors.info,
        });
      }
    }

    // Check budget usage
    for (final budget in analysis.budgets) {
      final spentAmount =
          analysis.expenseByCategory[budget.categoryName] ?? 0.0;
      final usagePercentage =
          budget.amount > 0 ? (spentAmount / budget.amount) : 0.0;

      if (usagePercentage >= 0.9) {
        insights.add({
          'title': 'Anggaran ${budget.categoryName} Hampir Habis',
          'description':
              'Anggaran sudah ${(usagePercentage * 100).toStringAsFixed(0)}% terpakai. Pertimbangkan untuk mengurangi pengeluaran di kategori ini.',
          'icon': Icons.warning,
          'color': AppColors.warning,
        });
      }
    }

    // Check if expenses are too high compared to income
    if (analysis.totalIncome > 0 &&
        analysis.totalExpense > analysis.totalIncome * 0.8) {
      insights.add({
        'title': 'Pengeluaran Tinggi',
        'description':
            'Pengeluaran bulan ini ${(analysis.totalExpense / analysis.totalIncome * 100).toStringAsFixed(0)}% dari pendapatan. Coba kurangi pengeluaran non-esensial.',
        'icon': Icons.trending_down,
        'color': AppColors.error,
      });
    }

    // Check if no income recorded
    if (analysis.totalIncome == 0) {
      insights.add({
        'title': 'Belum Ada Pendapatan',
        'description':
            'Mulai catat pendapatan Anda untuk mendapatkan insight yang lebih akurat.',
        'icon': Icons.info,
        'color': AppColors.info,
      });
    }

    // Check if balance is negative
    if (analysis.balance < 0) {
      insights.add({
        'title': 'Saldo Negatif',
        'description':
            'Pengeluaran melebihi pendapatan bulan ini. Pertimbangkan untuk mengurangi pengeluaran atau mencari sumber pendapatan tambahan.',
        'icon': Icons.error,
        'color': AppColors.error,
      });
    }

    // Check goals progress
    if (analysis.goals.isNotEmpty) {
      final completedGoals =
          analysis.goals.where((g) => g.progressPercentage >= 100).length;
      if (completedGoals > 0) {
        insights.add({
          'title': 'Tujuan Tercapai! 🎯',
          'description':
              'Selamat! Anda telah mencapai $completedGoals tujuan keuangan. Lanjutkan dengan tujuan berikutnya!',
          'icon': Icons.flag,
          'color': AppColors.success,
        });
      }
    }

    // Limit to 5 insights
    return insights.take(5).toList();
  }
}
