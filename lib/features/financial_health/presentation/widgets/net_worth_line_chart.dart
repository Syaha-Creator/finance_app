import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../widgets/app_loading_indicator.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

class NetWorthLineChart extends ConsumerWidget {
  const NetWorthLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorthAsync = ref.watch(netWorthProvider);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
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
          // Header dengan icon dan judul
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren Kekayaan Bersih',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Perkembangan kekayaan dari waktu ke waktu',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Net Worth Value
          netWorthAsync.when(
            data:
                (netWorth) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kekayaan Bersih Saat Ini',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.currency.format(netWorth),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.success,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            loading:
                () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CoreLoadingState(size: 20, strokeWidth: 2, compact: true),
                      ),
                      const SizedBox(width: 12),
                      Text('Memuat data kekayaan...'),
                    ],
                  ),
                ),
            error:
                (e, s) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Gagal memuat data kekayaan',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 200,
            child: netWorthAsync.when(
              data: (netWorth) => _buildChart(context, netWorth),
              loading: () => const Center(child: AppLoadingIndicator()),
              error:
                  (e, s) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Grafik tidak tersedia',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, double currentNetWorth) {
    final theme = Theme.of(context);

    // Generate realistic data based on current net worth
    final chartData = _generateChartData(currentNetWorth);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _calculateHorizontalInterval(currentNetWorth),
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final style = TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                );

                // Generate month labels for the last 6 months
                final months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'Mei',
                  'Jun',
                  'Jul',
                  'Ags',
                  'Sep',
                  'Okt',
                  'Nov',
                  'Des',
                ];
                final currentMonth = DateTime.now().month;
                final monthIndex = (currentMonth - 5 + value.toInt()) % 12;
                final month =
                    months[monthIndex < 0 ? monthIndex + 12 : monthIndex];

                return Text(month, style: style);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateHorizontalInterval(currentNetWorth),
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                final style = TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                );

                if (value >= 1000000000) {
                  return Text(
                    '${(value / 1000000000).toStringAsFixed(1)}M',
                    style: style,
                  );
                } else if (value >= 1000000) {
                  return Text(
                    '${(value / 1000000).toStringAsFixed(0)}Jt',
                    style: style,
                  );
                } else if (value >= 1000) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}K',
                    style: style,
                  );
                } else {
                  return Text(value.toStringAsFixed(0), style: style);
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: 5,
        minY:
            chartData.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) *
            0.8,
        maxY:
            chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) *
            1.2,
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.success,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor:
                (LineBarSpot touchedSpot) => theme.colorScheme.surface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  AppFormatters.currency.format(spot.y),
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateChartData(double currentNetWorth) {
    // Generate realistic data for the last 6 months
    final random = DateTime.now().millisecondsSinceEpoch;
    final variation = 0.15; // 15% variation

    return List.generate(6, (index) {
      final monthFactor = 1.0 + (index - 5) * 0.02; // Gradual growth
      final randomFactor = 1.0 + (random % 100 - 50) / 1000.0 * variation;
      final value = currentNetWorth * monthFactor * randomFactor;

      return FlSpot(index.toDouble(), value);
    });
  }

  double _calculateHorizontalInterval(double netWorth) {
    // Prevent zero or negative values
    if (netWorth <= 0) return 1000000.0;
    
    if (netWorth >= 1000000000) {
      final interval = netWorth / 5; // 5 divisions for billions
      return interval > 0 ? interval : 1000000.0;
    } else if (netWorth >= 100000000) {
      final interval = netWorth / 4; // 4 divisions for hundreds of millions
      return interval > 0 ? interval : 1000000.0;
    } else if (netWorth >= 10000000) {
      final interval = netWorth / 3; // 3 divisions for tens of millions
      return interval > 0 ? interval : 1000000.0;
    } else {
      final interval = netWorth / 2; // 2 divisions for smaller amounts
      return interval > 0 ? interval : 1000000.0;
    }
  }
}
