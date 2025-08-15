import 'package:flutter/material.dart';

import '../../domain/entities/financial_health_analysis.dart';

class OverallScoreGauge extends StatelessWidget {
  final FinancialHealthAnalysis analysis;
  const OverallScoreGauge({super.key, required this.analysis});

  Color _getStatusColor(HealthStatus status, BuildContext context) {
    switch (status) {
      case HealthStatus.sehat:
        return Colors.green.shade400;
      case HealthStatus.cukup:
        return Colors.amber.shade400;
      case HealthStatus.kurang:
        return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(analysis.overallStatus, context);

    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: (analysis.overallScore / 100.0).clamp(0.0, 1.0),
              strokeWidth: 12,
              backgroundColor: color.withAlpha(51),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    analysis.overallScore.toStringAsFixed(0),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'Skor Kesehatan',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
