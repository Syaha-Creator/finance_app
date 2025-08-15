// lib/features/dashboard/presentation/widgets/net_worth_trend_card.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../providers/dashboard_viewmodel_provider.dart';

class NetWorthTrendCard extends StatelessWidget {
  final double netWorth;
  final List<NetWorthDataPoint> history;

  const NetWorthTrendCard({
    super.key,
    required this.netWorth,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Kekayaan Bersih',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              numberFormat.format(netWorth),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              // Memanggil fungsi helper dan memberikan BuildContext
              child: _buildChart(context, history),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper sekarang menjadi method dari class dan menerima context
  // Ini menyelesaikan semua masalah 'undefined identifier' dan 'scope'
  Widget _buildChart(BuildContext context, List<NetWorthDataPoint> data) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Helper untuk judul sumbu X ditempatkan di sini agar bisa mengakses 'theme'
    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      final style = theme.textTheme.bodySmall;
      final index = value.toInt();
      String text = '';
      if (index >= 0 && index < data.length) {
        text = DateFormat('MMM', 'id_ID').format(data[index].date);
      }
      return SideTitleWidget(
        // 'axisSide' sudah tidak ada di versi ini, jadi kita hapus.
        space: 4,
        meta: meta,
        child: Text(text, style: style),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Text('Data tidak cukup untuk menampilkan grafik.'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget:
                  bottomTitleWidgets, // Memanggil helper yang sudah benar
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots:
                data
                    .mapIndexed(
                      (index, element) =>
                          FlSpot(index.toDouble(), element.value),
                    )
                    .toList(),
            isCurved: true,
            color: primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [primaryColor.withAlpha(80), primaryColor.withAlpha(0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot spot) => primaryColor,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(spot.y),
                  TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
