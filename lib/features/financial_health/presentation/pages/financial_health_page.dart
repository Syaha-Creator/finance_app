import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/app_loading_indicator.dart';
import '../widgets/net_worth_line_chart.dart'; // <-- IMPOR BARU
import '../../application/financial_health_service.dart';
import '../widgets/financial_ratio_card.dart';
import '../widgets/overall_score_gauge.dart';
import '../widgets/summary_card.dart';

class FinancialHealthPage extends ConsumerWidget {
  const FinancialHealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(financialHealthAnalysisProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Health Check'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: analysisAsync.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (analysis) {
          return RefreshIndicator(
            onRefresh:
                () => ref.refresh(financialHealthAnalysisProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                OverallScoreGauge(analysis: analysis),
                const SizedBox(height: 24),
                SummaryCard(summary: analysis.summary),
                const SizedBox(height: 24),

                // --- TAMBAHKAN GRAFIK TREN DI SINI ---
                // Ini adalah tempat yang logis untuk analisis tren jangka panjang
                const NetWorthLineChart(),
                const SizedBox(height: 24),

                // --- Bagian Detail Analisis ---
                Text(
                  'Detail Analisis Rasio',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...analysis.ratios.map(
                  (ratio) => FinancialRatioCard(ratio: ratio),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
