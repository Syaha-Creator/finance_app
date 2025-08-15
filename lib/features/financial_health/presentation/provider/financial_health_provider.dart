import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../asset/data/models/asset_model.dart';
import '../../../asset/presentation/provider/asset_provider.dart';
import '../../../debt/data/models/debt_receivable_model.dart';
import '../../../debt/presentation/provider/debt_provider.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

class FinancialHealthModel {
  final double emergencyFundRatio; // dalam bulan
  final double savingsRatio; // 0.0 - 1.0
  final double debtToAssetRatio; // 0.0 - 1.0

  FinancialHealthModel({
    required this.emergencyFundRatio,
    required this.savingsRatio,
    required this.debtToAssetRatio,
  });
}

final financialHealthProvider = Provider.autoDispose<
  AsyncValue<FinancialHealthModel>
>((ref) {
  final assetsAsync = ref.watch(assetsStreamProvider);
  final debtsAsync = ref.watch(debtsStreamProvider);
  final transactionsAsync = ref.watch(transactionsStreamProvider);

  // Cek jika ada state loading atau error dari provider yang dibutuhkan
  if (assetsAsync.isLoading ||
      debtsAsync.isLoading ||
      transactionsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (assetsAsync.hasError) {
    return AsyncValue.error(assetsAsync.error!, assetsAsync.stackTrace!);
  }
  if (debtsAsync.hasError) {
    return AsyncValue.error(debtsAsync.error!, debtsAsync.stackTrace!);
  }
  if (transactionsAsync.hasError) {
    return AsyncValue.error(
      transactionsAsync.error!,
      transactionsAsync.stackTrace!,
    );
  }

  // Jika semua data ada, lanjutkan perhitungan
  final assets = assetsAsync.value!;
  final debts = debtsAsync.value!;
  final transactions = transactionsAsync.value!;

  // --- Perhitungan Rasio Dana Darurat ---
  final liquidAssets = assets
      .where(
        (a) =>
            a.type == AssetType.cash ||
            a.type == AssetType.bankAccount ||
            a.type == AssetType.eWallet,
      )
      .fold<double>(0, (sum, item) => sum + item.value);

  // Hitung rata-rata pengeluaran 3 bulan terakhir
  final recentMonths = <DateTime>{};
  for (var t in transactions) {
    if (t.type == TransactionType.expense) {
      recentMonths.add(DateTime(t.date.year, t.date.month));
    }
  }

  final monthlyExpenses = groupBy(
    transactions.where((t) => t.type == TransactionType.expense),
    (TransactionModel t) => DateTime(t.date.year, t.date.month),
  ).map(
    (key, value) =>
        MapEntry(key, value.fold(0.0, (sum, item) => sum + item.amount)),
  );

  double averageMonthlyExpense = 0;
  if (monthlyExpenses.isNotEmpty) {
    averageMonthlyExpense = monthlyExpenses.values.average;
  }

  final emergencyFundRatio =
      averageMonthlyExpense > 0 ? liquidAssets / averageMonthlyExpense : 0.0;

  // --- Perhitungan Rasio Tabungan ---
  final now = DateTime.now();
  final lastMonth = DateTime(now.year, now.month - 1);

  final lastMonthIncome = transactions
      .where(
        (t) =>
            t.type == TransactionType.income &&
            t.date.year == lastMonth.year &&
            t.date.month == lastMonth.month,
      )
      .fold<double>(0, (sum, item) => sum + item.amount);

  final lastMonthExpense = transactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.date.year == lastMonth.year &&
            t.date.month == lastMonth.month,
      )
      .fold<double>(0, (sum, item) => sum + item.amount);

  final savingsRatio =
      lastMonthIncome > 0
          ? (lastMonthIncome - lastMonthExpense) / lastMonthIncome
          : 0.0;

  // --- Perhitungan Rasio Utang terhadap Aset ---
  final totalAssets = assets.fold<double>(0, (sum, item) => sum + item.value);
  final totalDebts = debts
      .where((d) => d.type == DebtReceivableType.debt)
      .fold<double>(0, (sum, item) => sum + item.amount);

  final debtToAssetRatio = totalAssets > 0 ? totalDebts / totalAssets : 0.0;

  return AsyncValue.data(
    FinancialHealthModel(
      emergencyFundRatio: emergencyFundRatio,
      savingsRatio: savingsRatio,
      debtToAssetRatio: debtToAssetRatio,
    ),
  );
});
