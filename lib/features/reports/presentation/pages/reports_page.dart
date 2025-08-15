import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/app_loading_indicator.dart';
import '../../../../widgets/month_selector.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../widgets/expense_pie_chart.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisDependencies = ref.watch(transactionsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: MonthSelector(),
          ),
          analysisDependencies.when(
            loading:
                () => const SliverFillRemaining(child: AppLoadingIndicator()),
            error:
                (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $err')),
                ),
            data: (_) {
              final analysis = ref.watch(dashboardAnalysisProvider);
              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      'Laporan Pengeluaran',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lihat komposisi pengeluaranmu dalam sebulan terakhir.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    ExpensePieChart(
                      expenseByCategory: analysis.expenseByCategory,
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
