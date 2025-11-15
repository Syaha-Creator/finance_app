import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

final pieTouchedIndexProvider = StateProvider.autoDispose<int>((ref) => -1);

class ExpensePieChart extends ConsumerWidget {
  final Map<String, double> expenseByCategory;
  const ExpensePieChart({super.key, required this.expenseByCategory});

  final List<Color> _chartColors = const [
    AppColors.primary,
    AppColors.expense,
    Colors.orange,
    Colors.lightBlue,
    Colors.teal,
    Colors.purple,
    Colors.amber,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Komposisi Pengeluaran',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Distribusi pengeluaran berdasarkan kategori',
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (expenseByCategory.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data pengeluaran',
                    style: textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai catat transaksi untuk melihat analisis',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(flex: 2, child: _buildPieChart(ref)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildLegend(context)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPieChart(WidgetRef ref) {
    final totalExpense = expenseByCategory.values.fold(
      0.0,
      (sum, item) => sum + item,
    );
    final touchedIndex = ref.watch(pieTouchedIndexProvider);

    int colorIndex = 0;
    final List<PieChartSectionData> sections =
        expenseByCategory.entries.map((entry) {
          final isTouched = colorIndex == touchedIndex;
          final fontSize = isTouched ? 16.0 : 12.0;
          final radius = isTouched ? 70.0 : 60.0;
          final percentage = (entry.value / totalExpense) * 100;

          final color = _chartColors[colorIndex % _chartColors.length];
          colorIndex++;

          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
            ),
          );
        }).toList();

    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                ref.read(pieTouchedIndexProvider.notifier).state = -1;
                return;
              }
              ref.read(pieTouchedIndexProvider.notifier).state =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            },
          ),
          sections: sections,
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 35,
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final touchedIndex = ref.watch(pieTouchedIndexProvider);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(expenseByCategory.length, (index) {
            final category = expenseByCategory.keys.elementAt(index);
            return _Indicator(
              color: _chartColors[index % _chartColors.length],
              text: category,
              isTouched: index == touchedIndex,
            );
          }),
        );
      },
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.color,
    required this.text,
    required this.isTouched,
  });
  final Color color;
  final String text;
  final bool isTouched;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: isTouched ? 12 : 10,
            height: isTouched ? 12 : 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
