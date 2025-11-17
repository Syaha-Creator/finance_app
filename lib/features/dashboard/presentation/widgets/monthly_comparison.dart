import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/dashboard_providers.dart';

class MonthlyComparison extends ConsumerWidget {
  const MonthlyComparison({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final monthlyDataAsync = ref.watch(monthlyComparisonProvider(selectedDate));

    return monthlyDataAsync.when(
      loading: () => _buildLoadingState(theme),
      error: (err, stack) => _buildErrorState(theme, err),
      data: (monthlyData) {
        final thisMonth = monthlyData['current'] as Map<String, dynamic>;
        final previousMonth = monthlyData['previous'] as Map<String, dynamic>;

        final comparisonItems = [
          {
            'label': 'Pendapatan',
            'thisMonth': thisMonth['income'] as double,
            'lastMonth': previousMonth['income'] as double,
            'icon': Icons.trending_up,
            'color': AppColors.income,
          },
          {
            'label': 'Pengeluaran',
            'thisMonth': thisMonth['expense'] as double,
            'lastMonth': previousMonth['expense'] as double,
            'icon': Icons.trending_down,
            'color': AppColors.expense,
          },
          {
            'label': 'Tabungan',
            'thisMonth': thisMonth['savings'] as double,
            'lastMonth': previousMonth['savings'] as double,
            'icon': Icons.savings,
            'color': AppColors.success,
          },
        ];

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
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.compare_arrows,
                        color: AppColors.info,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perbandingan Bulanan',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Bandingkan dengan bulan lalu',
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

              // Comparison Items
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children:
                      comparisonItems.map((item) {
                        final change =
                            (item['thisMonth'] as double) -
                            (item['lastMonth'] as double);
                        final changePercent =
                            (item['lastMonth'] as double) > 0
                                ? (change / (item['lastMonth'] as double) * 100)
                                : 0.0;
                        final isPositive = change >= 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['label'] as String,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      AppFormatters.currency.format(
                                        item['thisMonth'] as double,
                                      ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isPositive
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        color:
                                            isPositive
                                                ? AppColors.success
                                                : AppColors.error,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${changePercent.abs().toStringAsFixed(1)}%',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  isPositive
                                                      ? AppColors.success
                                                      : AppColors.error,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    AppFormatters.currency.format(change.abs()),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
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
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
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
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CoreLoadingState(color: AppColors.primary)),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
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
        child: Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
