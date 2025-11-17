import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../asset/presentation/providers/asset_provider.dart';
import '../../../budget/data/models/budget_model.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../debt/data/models/debt_receivable_model.dart';
import '../../../debt/presentation/providers/debt_provider.dart';
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
  final goals = ref.watch(goalsWithProgressProvider).value ?? [];

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

final netWorthHistoryProvider = FutureProvider.autoDispose<
  List<Map<String, dynamic>>
>((ref) async {
  final allTransactions = await ref.watch(transactionsStreamProvider.future);
  final allAssets = await ref.watch(assetsStreamProvider.future);
  final allDebts = await ref.watch(debtsStreamProvider.future);

  // Generate 6 months of historical data based on real transactions
  final now = DateTime.now();
  final history = <Map<String, dynamic>>[];

  for (int i = 5; i >= 0; i--) {
    final date = DateTime(now.year, now.month - i, 1);

    // Calculate net worth for this month based on transactions up to that date
    final transactionsUpToDate =
        allTransactions
            .where((t) => t.date.isBefore(date.add(const Duration(days: 32))))
            .toList();

    // Calculate cumulative income and expense up to this month
    final cumulativeIncome = transactionsUpToDate
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.category != 'Transfer Masuk',
        )
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final cumulativeExpense = transactionsUpToDate
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.category != 'Transfer Keluar',
        )
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    // Calculate assets and debts as of this month
    // For historical purposes, we'll estimate based on current values
    // In a real app, you'd store historical snapshots
    final totalAssets = allAssets.fold<double>(
      0.0,
      (sum, asset) => sum + asset.value,
    );
    final totalDebts = allDebts
        .where((d) => d.type == DebtReceivableType.debt)
        .fold<double>(0.0, (sum, debt) => sum + debt.amount);

    // Calculate net worth for this month
    final netWorth =
        cumulativeIncome - cumulativeExpense + totalAssets - totalDebts;

    history.add({
      'date': date,
      'value': netWorth,
      'income': cumulativeIncome,
      'expense': cumulativeExpense,
      'assets': totalAssets,
      'debts': totalDebts,
    });
  }

  return history;
});

final monthlyComparisonProvider = FutureProvider.autoDispose.family<
  Map<String, dynamic>,
  DateTime
>((ref, selectedDate) async {
  final allTransactions = await ref.watch(transactionsStreamProvider.future);

  // Get current month data
  final currentMonth = {'year': selectedDate.year, 'month': selectedDate.month};

  // Get previous month data
  final previousMonth = {
    'year': selectedDate.month == 1 ? selectedDate.year - 1 : selectedDate.year,
    'month': selectedDate.month == 1 ? 12 : selectedDate.month - 1,
  };

  // Calculate current month transactions
  final currentMonthTransactions =
      allTransactions.where((t) {
        return t.date.year == currentMonth['year'] &&
            t.date.month == currentMonth['month'];
      }).toList();

  // Calculate previous month transactions
  final previousMonthTransactions =
      allTransactions.where((t) {
        return t.date.year == previousMonth['year'] &&
            t.date.month == previousMonth['month'];
      }).toList();

  // Calculate income and expense for both months
  final currentIncome = currentMonthTransactions
      .where(
        (t) =>
            t.type == TransactionType.income && t.category != 'Transfer Masuk',
      )
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  final currentExpense = currentMonthTransactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.category != 'Transfer Keluar',
      )
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  final previousIncome = previousMonthTransactions
      .where(
        (t) =>
            t.type == TransactionType.income && t.category != 'Transfer Masuk',
      )
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  final previousExpense = previousMonthTransactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.category != 'Transfer Keluar',
      )
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  return {
    'current': {
      'income': currentIncome,
      'expense': currentExpense,
      'savings': currentIncome - currentExpense,
    },
    'previous': {
      'income': previousIncome,
      'expense': previousExpense,
      'savings': previousIncome - previousExpense,
    },
  };
});
