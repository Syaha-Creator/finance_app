import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/financial_health_score.dart';
import '../widgets/financial_ratio_card.dart';
import '../widgets/overall_score_gauge.dart';
import '../widgets/personalized_insights.dart';
import '../../../../core/widgets/app_scaffold.dart';

class FinancialHealthPage extends ConsumerWidget {
  const FinancialHealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Cek Kesehatan Finansial',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 8),
          OverallScoreGauge(),
          SizedBox(height: 16),
          FinancialHealthScore(),
          SizedBox(height: 16),
          FinancialRatioCard(),
          SizedBox(height: 16),
          PersonalizedInsights(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
