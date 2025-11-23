import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/dashboard_viewmodel_provider.dart';
import '../widgets/index.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(dashboardViewModelProvider);
    final theme = Theme.of(context);

    return viewModelAsync.when(
      loading:
          () => const Center(child: CoreLoadingState(color: AppColors.primary)),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data:
          (viewModel) => CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: _buildHeader(context, theme, viewModel),
                ),
              ),

              // Dashboard Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.paddingAll,
                  child: Column(
                    children: [
                      // Phase 1: Core Features
                      const QuickActionsWidget(),
                      AppSpacing.spaceMD,
                      const GoalsProgressOverview(),
                      AppSpacing.spaceMD,

                      // Phase 2: Analysis Features
                      const SpendingPatternAnalysis(),
                      AppSpacing.spaceMD,
                      const MonthlyComparison(),
                      AppSpacing.spaceMD,

                      // Phase 3: Health & Insights
                      const FinancialHealthScore(),
                      AppSpacing.spaceMD,
                      const PersonalizedInsights(),
                      AppSpacing.spaceMD,

                      // Phase 4: Advanced Analytics
                      const FinancialRatioCard(),
                      AppSpacing.spaceMD,
                      const NetWorthLineChart(),
                      AppSpacing.spaceMD,

                      // Phase 5: Summary & Overview
                      const OverallScoreGauge(),
                      AppSpacing.spaceMD,
                    ],
                  ),
                ),
              ),
            ],
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
      margin: AppSpacing.paddingHorizontal,
      child: const SummaryCard(),
    );
  }
}
