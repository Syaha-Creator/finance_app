import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../asset/presentation/provider/asset_provider.dart';
import '../../../budget/data/models/budget_model.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../debt/data/models/debt_receivable_model.dart';
import '../../../debt/presentation/provider/debt_provider.dart';
import '../../../goals/data/models/goal_model.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import 'package:collection/collection.dart';

class DashboardAnalysis {
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> expenseByCategory;
  final List<BudgetModel> budgets;
  final List<GoalModel> goals;

  DashboardAnalysis({
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
    required this.budgets,
    required this.goals,
  });

  double get balance => totalIncome - totalExpense;
}

final selectedDateProvider = StateProvider.autoDispose<DateTime>((ref) {
  return DateTime.now();
});

final dashboardAnalysisProvider = Provider.autoDispose<DashboardAnalysis>((
  ref,
) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final selectedDate = ref.watch(selectedDateProvider);
  final goals = ref.watch(goalsStreamProvider).value ?? [];

  final budgets =
      ref
          .watch(
            budgetsForMonthProvider((
              year: selectedDate.year,
              month: selectedDate.month,
            )),
          )
          .value ??
      [];

  final currentMonthTransactions =
      transactions.where((t) {
        return t.date.year == selectedDate.year &&
            t.date.month == selectedDate.month;
      }).toList();

  final totalIncome = currentMonthTransactions
      .where(
        (t) =>
            t.type == TransactionType.income && t.category != 'Transfer Masuk',
      )
      .fold(0.0, (sum, item) => sum + item.amount);

  final totalExpense = currentMonthTransactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.category != 'Transfer Keluar',
      )
      .fold(0.0, (sum, item) => sum + item.amount);

  final Map<String, double> expenseByCategory = {};
  for (var transaction in currentMonthTransactions) {
    if (transaction.type == TransactionType.expense &&
        transaction.category != 'Transfer Keluar') {
      expenseByCategory.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
  }

  goals.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));

  return DashboardAnalysis(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    expenseByCategory: expenseByCategory,
    budgets: budgets,
    goals: goals,
  );
});

final groupedTransactionsProvider =
    Provider.autoDispose<Map<DateTime, List<TransactionModel>>>((ref) {
      final transactions = ref.watch(transactionsStreamProvider).value ?? [];
      return groupBy(
        transactions,
        (TransactionModel t) => DateTime(t.date.year, t.date.month, t.date.day),
      );
    });

final netWorthProvider = FutureProvider<double>((ref) async {
  final assets = await ref.watch(assetsStreamProvider.future);
  final debts = await ref.watch(debtsStreamProvider.future);

  final totalAssets = assets.fold<double>(
    0.0,
    (sum, asset) => sum + asset.value,
  );

  final totalDebts = debts
      .where((d) => d.type == DebtReceivableType.debt)
      .fold<double>(0.0, (sum, debt) => sum + debt.amount);

  return totalAssets - totalDebts;
});
