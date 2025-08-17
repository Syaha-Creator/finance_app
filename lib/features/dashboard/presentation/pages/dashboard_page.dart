import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/dashboard_viewmodel_provider.dart';
import '../widgets/index.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(dashboardViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: viewModelAsync.when(
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data:
              (viewModel) => CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(context, theme, viewModel),
                  ),

                  // Dashboard Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Phase 1: Core Features
                          const GoalsProgressOverview(),
                          const SizedBox(height: 8),
                          const QuickActionsPanel(),
                          const SizedBox(height: 8),

                          // Phase 2: Analysis Features
                          const SpendingPatternAnalysis(),
                          const SizedBox(height: 8),
                          const MonthlyComparison(),
                          const SizedBox(height: 8),

                          // Phase 3: Health & Insights
                          const FinancialHealthScore(),
                          const SizedBox(height: 8),
                          const PersonalizedInsights(),
                          const SizedBox(height: 8),

                          // Phase 4: Advanced Analytics
                          const FinancialRatioCard(),
                          const SizedBox(height: 8),
                          const NetWorthLineChart(),
                          const SizedBox(height: 8),

                          // Phase 5: Summary & Overview
                          const OverallScoreGauge(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    dynamic viewModel,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const SummaryCard(),
    );
  }
}
