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

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Komposisi Pengeluaran',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            if (expenseByCategory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.0),
                  child: Text('Belum ada data pengeluaran bulan ini.'),
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
