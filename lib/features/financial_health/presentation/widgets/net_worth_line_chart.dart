import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/app_loading_indicator.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

class NetWorthLineChart extends ConsumerWidget {
  const NetWorthLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Data dummy untuk membangun UI grafik terlebih dahulu
    final dummyData = [
      FlSpot(0, 50000000),
      FlSpot(1, 65000000),
      FlSpot(2, 60000000),
      FlSpot(3, 75000000),
      FlSpot(4, 85000000),
      FlSpot(5, 105000000),
    ];

    final netWorthAsync = ref.watch(netWorthProvider);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tren Kekayaan Bersih',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            netWorthAsync.when(
              data:
                  (netWorth) => Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(netWorth),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade400,
                    ),
                  ),
              loading:
                  () =>
                      const SizedBox(height: 36, child: AppLoadingIndicator()),
              error: (e, s) => const Text('Tidak bisa memuat data'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: LineChart(_mainData(dummyData, context)),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _mainData(List<FlSpot> spots, BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 25000000,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outline.withAlpha(50),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outline.withAlpha(50),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final style = TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              );
              final month = DateFormat('MMM').format(
                DateTime.now().subtract(
                  Duration(days: (5 - value.toInt()) * 30),
                ),
              );
              return Text(month, style: style);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 50000000,
            reservedSize: 42,
            getTitlesWidget: (double value, TitleMeta meta) {
              final style = TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              );
              String text = '${(value / 1000000).toStringAsFixed(0)}Jt';
              return Text(text, style: style, textAlign: TextAlign.left);
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: theme.colorScheme.outline.withAlpha(80)),
      ),
      minX: 0,
      maxX: 5,
      minY: 0,
      maxY: 150000000,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [primaryColor, Colors.green.shade300],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                primaryColor.withAlpha(50),
                Colors.green.shade300.withAlpha(10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
