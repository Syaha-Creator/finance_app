import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_providers.dart';
import '../../../../core/widgets/empty_state.dart';

class SpendingPatternAnalysis extends ConsumerWidget {
  const SpendingPatternAnalysis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysis = ref.watch(dashboardAnalysisProvider);

    // Get top spending categories from real data
    final topCategories =
        analysis.expenseByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (topCategories.isEmpty) {
      return EmptyState(
        icon: Icons.pie_chart_outline,
        title: 'Belum Ada Data Pengeluaran',
        subtitle:
            'Mulai catat transaksi pengeluaran untuk melihat analisis pola belanja Anda',
        action: TextButton.icon(
          onPressed: () => context.push('/add-transaction'),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Transaksi'),
        ),
      );
    }

    final totalExpense = analysis.totalExpense;

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
                    color: AppColors.expense.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pie_chart_outline,
                    color: AppColors.expense,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisis Pola Pengeluaran',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Lihat kategori pengeluaran terbesar',
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
                    color: AppColors.expense.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.expense.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Total: ${AppFormatters.currency.format(totalExpense).replaceAll('Rp ', '')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.expense,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children:
                  topCategories.take(5).map((category) {
                    final categoryPercentage =
                        (category.value / totalExpense * 100).clamp(0.0, 100.0);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  category.key,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${categoryPercentage.toStringAsFixed(1)}%',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.expense,
                                    ),
                                  ),
                                  Text(
                                    AppFormatters.currency.format(
                                      category.value,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: categoryPercentage / 100,
                            backgroundColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.1),
                            color: AppColors.expense,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),

          // View All Button
          if (topCategories.length > 5)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => context.push('/reports'),
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.expense,
                  ),
                  label: Text(
                    'Lihat Analisis Lengkap',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.expense,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
