import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/financial_health_analysis.dart';

class FinancialRatioCard extends StatelessWidget {
  final FinancialRatio ratio;
  const FinancialRatioCard({super.key, required this.ratio});

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.sehat:
        return Colors.green;
      case HealthStatus.cukup:
        return Colors.amber.shade700;
      case HealthStatus.kurang:
        return Colors.red;
    }
  }

  String _formatValue(String name, double value) {
    if (value.isInfinite) {
      return '∞';
    }

    if (name.contains('(Bulan)')) {
      return '${value.toStringAsFixed(1)} bulan';
    }

    if (value < 0) {
      return '${NumberFormat.percentPattern().format(value.abs())} (negatif)';
    }

    return NumberFormat.percentPattern().format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(ratio.status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outline.withAlpha(51)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ratio.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatValue(ratio.name, ratio.value),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(ratio.description, style: theme.textTheme.bodySmall),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: Colors.blue.shade300,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ratio.recommendation,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
