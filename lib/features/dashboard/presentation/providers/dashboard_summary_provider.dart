import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../asset/presentation/providers/asset_provider.dart';
import '../../../debt/data/models/debt_receivable_model.dart';
import '../../../debt/presentation/providers/debt_provider.dart';

class DashboardSummary {
  final double totalAssets;
  final double totalDebts;
  
  DashboardSummary({required this.totalAssets, required this.totalDebts});
  
  double get netWorth => totalAssets - totalDebts;
}

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final assetsAsync = ref.watch(assetsStreamProvider);
  final debtsAsync = ref.watch(debtsStreamProvider);

  if (assetsAsync.isLoading || debtsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (assetsAsync.hasError) {
    return AsyncValue.error(assetsAsync.error!, assetsAsync.stackTrace!);
  }
  if (debtsAsync.hasError) {
    return AsyncValue.error(debtsAsync.error!, debtsAsync.stackTrace!);
  }

  final totalAssets =
      assetsAsync.value?.fold<double>(0, (sum, item) => sum + item.value) ?? 0;
  final totalDebts =
      debtsAsync.value
          ?.where((d) => d.type == DebtReceivableType.debt)
          .fold<double>(0, (sum, item) => sum + item.amount) ??
      0;

  return AsyncValue.data(
    DashboardSummary(totalAssets: totalAssets, totalDebts: totalDebts),
  );
});
