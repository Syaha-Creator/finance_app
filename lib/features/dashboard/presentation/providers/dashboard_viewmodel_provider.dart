import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../asset/presentation/provider/asset_provider.dart';
import '../../../debt/data/models/debt_receivable_model.dart';
import '../../../debt/presentation/provider/debt_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/data/models/transaction_model.dart';

class DashboardViewModel {
  final double netWorth;
  final List<NetWorthDataPoint> netWorthHistory;
  final MonthlyCashFlow monthlyCashFlow;
  final List<TransactionModel> upcomingBills;

  DashboardViewModel({
    required this.netWorth,
    required this.netWorthHistory,
    required this.monthlyCashFlow,
    required this.upcomingBills,
  });
}

class NetWorthDataPoint {
  final DateTime date;
  final double value;
  NetWorthDataPoint(this.date, this.value);
}

class MonthlyCashFlow {
  final double income;
  final double expense;
  MonthlyCashFlow({required this.income, required this.expense});
}

final dashboardViewModelProvider =
    FutureProvider.autoDispose<DashboardViewModel>((ref) async {
      final allTransactions = await ref.watch(
        transactionsStreamProvider.future,
      );
      final allAssets = await ref.watch(assetsStreamProvider.future);
      final allDebts = await ref.watch(debtsStreamProvider.future);

      final totalAssets = allAssets.fold<double>(
        0.0,
        (sum, asset) => sum + asset.value,
      );
      final totalDebts = allDebts
          .where((d) => d.type == DebtReceivableType.debt)
          .fold<double>(0.0, (sum, debt) => sum + debt.amount);
      final currentNetWorth = totalAssets - totalDebts;

      final List<NetWorthDataPoint> netWorthHistory = [
        NetWorthDataPoint(
          DateTime.now().subtract(const Duration(days: 150)),
          currentNetWorth * 0.75,
        ),
        NetWorthDataPoint(
          DateTime.now().subtract(const Duration(days: 120)),
          currentNetWorth * 0.80,
        ),
        NetWorthDataPoint(
          DateTime.now().subtract(const Duration(days: 90)),
          currentNetWorth * 0.85,
        ),
        NetWorthDataPoint(
          DateTime.now().subtract(const Duration(days: 60)),
          currentNetWorth * 0.90,
        ),
        NetWorthDataPoint(
          DateTime.now().subtract(const Duration(days: 30)),
          currentNetWorth * 0.95,
        ),
        NetWorthDataPoint(DateTime.now(), currentNetWorth),
      ];

      final now = DateTime.now();
      final incomeThisMonth = allTransactions
          .where(
            (t) =>
                t.type == TransactionType.income &&
                t.date.month == now.month &&
                t.date.year == now.year,
          )
          .fold<double>(0, (sum, item) => sum + item.amount);
      final expenseThisMonth = allTransactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                t.date.month == now.month &&
                t.date.year == now.year,
          )
          .fold<double>(0, (sum, item) => sum + item.amount);
      final cashFlow = MonthlyCashFlow(
        income: incomeThisMonth,
        expense: expenseThisMonth,
      );

      final upcomingBills =
          allTransactions.where((t) {
            return t.type == TransactionType.expense &&
                t.date.isAfter(DateTime.now()) &&
                t.date.isBefore(DateTime.now().add(const Duration(days: 7)));
          }).toList();

      return DashboardViewModel(
        netWorth: currentNetWorth,
        netWorthHistory: netWorthHistory,
        monthlyCashFlow: cashFlow,
        upcomingBills: upcomingBills,
      );
    });
