import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/widgets.dart';
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
    final theme = Theme.of(context);

    final expenseCategoriesAsync = ref.watch(expenseCategoriesProvider);
    final budgetsAsyncValue = ref.watch(
      budgetsForMonthProvider((
        year: selectedDate.year,
        month: selectedDate.month,
      )),
    );
    final analysis = ref.watch(dashboardAnalysisProvider);

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
        child: Column(
          children: [
            // Custom App Bar dengan Month Selector
            _buildCustomAppBar(context, theme, selectedDate, ref),

            // Content
            Expanded(
              child: expenseCategoriesAsync.when(
                loading:
                    () => const Center(
                      child: CoreLoadingState(color: AppColors.primary),
                    ),
                error: (err, stack) => _buildErrorState(context, theme, err),
                data: (categories) {
                  if (categories.isEmpty) {
                    return _buildEmptyState(context, theme);
                  }
                  return budgetsAsyncValue.when(
                    loading:
                        () => const Center(
                          child: CoreLoadingState(color: AppColors.primary),
                        ),
                    error:
                        (err, stack) => _buildErrorState(context, theme, err),
                    data: (budgets) {
                      final totalBudget = budgets.fold<double>(
                        0,
                        (sum, item) => sum + item.amount,
                      );
                      final totalSpent = analysis.totalExpense;

                      return CustomScrollView(
                        slivers: [
                          // Header dengan gradient
                          SliverToBoxAdapter(
                            child: _buildHeader(
                              context,
                              theme,
                              totalBudget,
                              totalSpent,
                            ),
                          ),

                          // Notification Highlights (Budget Warnings)
                          SliverToBoxAdapter(
                            child: _buildBudgetWarnings(
                              context,
                              ref,
                              budgets,
                              selectedDate,
                            ),
                          ),

                          // Auto Budget Card
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: const AutoBudgetCard(),
                            ),
                          ),

                          // Budget Categories
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _buildCategoriesHeader(context, theme),
                            ),
                          ),

                          // Budget List
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
                              return BudgetCategoryItem(
                                budget: budgetForCategory,
                              );
                            },
                          ),

                          // Bottom padding
                          const SliverToBoxAdapter(child: SizedBox(height: 80)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(
    BuildContext context,
    ThemeData theme,
    DateTime selectedDate,
    WidgetRef ref,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Tombol back
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Month Selector dengan ukuran yang sama
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final newDate = DateTime(
                        selectedDate.year,
                        selectedDate.month - 1,
                      );
                      ref.read(selectedDateProvider.notifier).state = newDate;
                    },
                    icon: Icon(
                      Icons.chevron_left,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final newDate = DateTime(
                        selectedDate.year,
                        selectedDate.month + 1,
                      );
                      ref.read(selectedDateProvider.notifier).state = newDate;
                    },
                    icon: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
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
    double totalBudget,
    double totalSpent,
  ) {
    final remaining = totalBudget - totalSpent;
    final progress =
        totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final progressColor =
        progress < 0.5
            ? AppColors.income
            : (progress < 0.9 ? AppColors.warning : AppColors.expense);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
            AppColors.primaryDark,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anggaran Bulanan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Kelola pengeluaran dengan bijak',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress Pengeluaran',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                color: progressColor,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary Row
          Row(
            children: [
              Expanded(
                child: _buildHeaderSummaryItem(
                  context,
                  'Anggaran',
                  totalBudget,
                  Icons.account_balance_wallet,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 12), // Kurangi spacing
              Expanded(
                child: _buildHeaderSummaryItem(
                  context,
                  'Pemakaian',
                  totalSpent,
                  Icons.trending_down,
                  progressColor,
                ),
              ),
              const SizedBox(width: 12), // Kurangi spacing
              Expanded(
                child: _buildHeaderSummaryItem(
                  context,
                  'Sisa',
                  remaining,
                  Icons.savings,
                  remaining >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSummaryItem(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(10), // Kurangi padding
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ), // Warna putih agar kontras dengan background
          const SizedBox(height: 6),
          // Nominal dengan style yang lebih compact
          Flexible(
            child: Text(
              AppFormatters.currency.format(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15, // Font size yang seimbang
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(height: 24),
          // Label
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Kategori Anggaran',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Kategori',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan tambah kategori pengeluaran di menu Pengaturan terlebih dahulu.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Terjadi Kesalahan',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetWarnings(
    BuildContext context,
    WidgetRef ref,
    List<BudgetModel> budgets,
    DateTime selectedDate,
  ) {
    final warnings = ref.watch(budgetWarningsProvider);

    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show first warning as highlight
    final firstWarning = warnings.first;

    return BudgetWarningHighlight(
      category: firstWarning.categoryName,
      percentageUsed: firstWarning.percentageUsed,
      onViewBudget: () {
        // Already on budget page, just scroll to category
        // This could be enhanced with scroll controller
      },
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return 'Unknown';
    }
  }
}
