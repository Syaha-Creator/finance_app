import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../widgets/budget_report_section.dart';

class BudgetMainPage extends ConsumerWidget {
  const BudgetMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(dashboardAnalysisProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: BudgetReportSection(analysis: analysis),
      ),
    );
  }
}
