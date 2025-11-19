import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../widgets/month_selector.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../widgets/transaction_history_list.dart';

class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(dashboardAnalysisProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // MonthSelector
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 70,
                child: MonthSelector(
                  selectedDate: ref.watch(selectedDateProvider),
                  onDateChanged: (date) {
                    ref.read(selectedDateProvider.notifier).state = date;
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Column(
            children: [
              // Compact summary section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
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
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCompactSummaryCard(
                        context,
                        icon: Icons.trending_up_rounded,
                        title: 'Pemasukan',
                        value: analysis.totalIncome,
                        color: AppColors.income,
                        theme: theme,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                    Expanded(
                      child: _buildCompactSummaryCard(
                        context,
                        icon: Icons.trending_down_rounded,
                        title: 'Pengeluaran',
                        value: analysis.totalExpense,
                        color: AppColors.expense,
                        theme: theme,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                    Expanded(
                      child: _buildCompactSummaryCard(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Saldo',
                        value: analysis.balance,
                        color: AppColors.secondary,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),

              // Transaction list section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Riwayat Transaksi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Expanded(child: TransactionHistoryList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(8), // Kurangi padding dari 12 ke 8
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon dan title dalam satu row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4), // Kurangi padding dari 6 ke 4
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    4,
                  ), // Kurangi radius dari 6 ke 4
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 14,
                ), // Kurangi size dari 16 ke 14
              ),
              const SizedBox(width: 4), // Kurangi spacing dari 6 ke 4
              Expanded(
                // Tambahkan Expanded untuk handle overflow
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 10, // Kurangi font size dari 11 ke 10
                  ),
                  textAlign: TextAlign.center,
                  overflow:
                      TextOverflow.ellipsis, // Tambahkan overflow handling
                  maxLines: 1, // Batasi ke 1 line
                ),
              ),
            ],
          ),

          const SizedBox(height: 6), // Kurangi spacing dari 8 ke 6
          // Amount dengan styling yang lebih compact
          Text(
            AppFormatters.currency.format(value),
            style: theme.textTheme.titleSmall?.copyWith(
              // Ganti dari titleMedium ke titleSmall
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12, // Kurangi font size dari 14 ke 12
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Tambahkan overflow handling
            maxLines: 1, // Batasi ke 1 line
          ),
        ],
      ),
    );
  }
}
