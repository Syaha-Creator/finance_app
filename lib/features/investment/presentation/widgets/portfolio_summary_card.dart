import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const PortfolioSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final totalInvested = summary['totalInvested'] ?? 0.0;
    final totalCurrentValue = summary['totalCurrentValue'] ?? 0.0;
    final totalProfitLoss = summary['totalProfitLoss'] ?? 0.0;
    final totalProfitLossPercentage =
        summary['totalProfitLossPercentage'] ?? 0.0;
    final totalInvestments = summary['totalInvestments'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up,
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
                        'Portfolio Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Ringkasan investasi Anda',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Total Investasi',
                    AppFormatters.currency.format(totalInvested),
                    Icons.account_balance_wallet_outlined,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Nilai Sekarang',
                    AppFormatters.currency.format(totalCurrentValue),
                    Icons.assessment_outlined,
                    totalCurrentValue >= totalInvested
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Profit/Loss Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (totalProfitLoss >= 0 ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.1),
                    (totalProfitLoss >= 0 ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (totalProfitLoss >= 0
                          ? AppColors.success
                          : AppColors.error)
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    totalProfitLoss >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color:
                        totalProfitLoss >= 0
                            ? AppColors.success
                            : AppColors.error,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          totalProfitLoss >= 0
                              ? 'Total Keuntungan'
                              : 'Total Kerugian',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${totalProfitLoss >= 0 ? '+' : ''}${AppFormatters.currency.format(totalProfitLoss)} (${totalProfitLossPercentage >= 0 ? '+' : ''}${totalProfitLossPercentage.toStringAsFixed(2)}%)',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                totalProfitLoss >= 0
                                    ? AppColors.success
                                    : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Additional Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Jumlah Investasi',
                    totalInvestments.toString(),
                    Icons.list_alt_outlined,
                    AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'ROI',
                    '${totalProfitLossPercentage >= 0 ? '+' : ''}${totalProfitLossPercentage.toStringAsFixed(2)}%',
                    Icons.analytics_outlined,
                    totalProfitLossPercentage >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
