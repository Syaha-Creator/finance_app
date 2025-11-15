import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/financial_health_analysis.dart';

class OverallScoreGauge extends StatelessWidget {
  final FinancialHealthAnalysis analysis;
  const OverallScoreGauge({super.key, required this.analysis});

  Color _getStatusColor(HealthStatus status, BuildContext context) {
    switch (status) {
      case HealthStatus.sehat:
        return AppColors.success;
      case HealthStatus.cukup:
        return AppColors.warning;
      case HealthStatus.kurang:
        return AppColors.error;
    }
  }

  String _getStatusText(HealthStatus status) {
    switch (status) {
      case HealthStatus.sehat:
        return 'Sehat';
      case HealthStatus.cukup:
        return 'Cukup';
      case HealthStatus.kurang:
        return 'Kurang';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(analysis.overallStatus, context);
    final statusText = _getStatusText(analysis.overallStatus);

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
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.health_and_safety, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skor Kesehatan Keuangan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Berdasarkan analisis rasio keuangan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gauge Circle
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Circle
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  // Progress Circle
                  CircularProgressIndicator(
                    value: (analysis.overallScore / 100.0).clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  // Center Content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          analysis.overallScore.toStringAsFixed(0),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: color,
                            fontSize: 36,
                          ),
                        ),
                        Text(
                          '/ 100',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status Description
          Text(
            _getStatusDescription(analysis.overallStatus),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(HealthStatus status) {
    switch (status) {
      case HealthStatus.sehat:
        return 'Selamat! Kesehatan keuangan Anda dalam kondisi yang sangat baik.';
      case HealthStatus.cukup:
        return 'Kesehatan keuangan Anda cukup baik, namun masih ada ruang untuk perbaikan.';
      case HealthStatus.kurang:
        return 'Kesehatan keuangan Anda membutuhkan perhatian serius. Lihat rekomendasi di bawah.';
    }
  }
}
