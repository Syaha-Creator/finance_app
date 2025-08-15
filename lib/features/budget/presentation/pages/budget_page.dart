import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../widgets/month_selector.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../data/models/budget_model.dart';
import '../providers/budget_providers.dart';
import '../widgets/auto_budget_card.dart';
import '../widgets/budget_category_item.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    final expenseCategoriesAsync = ref.watch(expenseCategoriesProvider);
    final budgetsAsyncValue = ref.watch(
      budgetsForMonthProvider((
        year: selectedDate.year,
        month: selectedDate.month,
      )),
    );
    final analysis = ref.watch(dashboardAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Anggaran Bulanan"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: MonthSelector(),
        ),
      ),
      body: expenseCategoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(child: Text('Gagal memuat kategori: $err')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Tidak ada kategori pengeluaran.\nSilakan tambah di menu Pengaturan.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return budgetsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, stack) =>
                    Center(child: Text('Gagal memuat budget: $err')),
            data: (budgets) {
              final totalBudget = budgets.fold<double>(
                0,
                (sum, item) => sum + item.amount,
              );
              final totalSpent = analysis.totalExpense;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          const AutoBudgetCard(),
                          const SizedBox(height: 16),
                          _buildSummaryHeader(context, totalBudget, totalSpent),
                        ],
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];

                      final budgetForCategory = budgets.firstWhere(
                        (b) => b.categoryName == category.name,
                        orElse:
                            () => BudgetModel(
                              userId: '',
                              categoryName: category.name,
                              amount: 0,
                              month: selectedDate.month,
                              year: selectedDate.year,
                            ),
                      );

                      return BudgetCategoryItem(budget: budgetForCategory);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    double totalBudget,
    double totalSpent,
  ) {
    final remaining = totalBudget - totalSpent;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryColumn(
                  context,
                  'Total Anggaran',
                  totalBudget,
                  AppColors.primary,
                ),
                _buildSummaryColumn(
                  context,
                  'Total Terpakai',
                  totalSpent,
                  AppColors.expense,
                ),
                _buildSummaryColumn(
                  context,
                  'Sisa Anggaran',
                  remaining,
                  AppColors.income,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value:
                  totalBudget > 0
                      ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                      : 0,

              backgroundColor: theme.colorScheme.onSurface.withAlpha(30),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(
    BuildContext context,
    String title,
    double amount,
    Color color,
  ) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          AppFormatters.currency.format(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
