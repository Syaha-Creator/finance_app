import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../asset/data/models/asset_model.dart';
import '../../asset/presentation/providers/asset_provider.dart';
import '../../debt/data/models/debt_receivable_model.dart';
import '../../debt/presentation/providers/debt_provider.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/presentation/providers/transaction_provider.dart';
import '../domain/entities/financial_health_analysis.dart';

final financialHealthServiceProvider = Provider<FinancialHealthService>((ref) {
  return FinancialHealthService();
});

final financialHealthAnalysisProvider = FutureProvider<FinancialHealthAnalysis>(
  (ref) async {
    final transactions = await ref.watch(transactionsStreamProvider.future);
    final assets = await ref.watch(assetsStreamProvider.future);
    final debts = await ref.watch(debtsStreamProvider.future);

    return ref
        .read(financialHealthServiceProvider)
        .analyze(transactions: transactions, assets: assets, debts: debts);
  },
);

class FinancialHealthService {
  FinancialHealthService();

  Future<FinancialHealthAnalysis> analyze({
    required List<TransactionModel> transactions,
    required List<AssetModel> assets,
    required List<DebtReceivableModel> debts,
  }) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentTransactions =
        transactions.where((t) => t.date.isAfter(thirtyDaysAgo)).toList();

    final totalPendapatanBulanan = _calculateTotalIncome(recentTransactions);
    final totalPengeluaranBulanan = _calculateTotalExpense(recentTransactions);
    final totalCicilanUtangBulanan = _calculateTotalDebtPayments(debts);
    final totalAsetLancar = _calculateTotalLiquidAssets(assets);

    if (totalPendapatanBulanan == 0) {
      return FinancialHealthAnalysis.empty();
    }

    final savingsRatio = _calculateSavingsRatio(
      totalPendapatanBulanan,
      totalPengeluaranBulanan,
    );
    final debtServiceRatio = _calculateDebtServiceRatio(
      totalCicilanUtangBulanan,
      totalPendapatanBulanan,
    );
    final emergencyFundRatio = _calculateEmergencyFundRatio(
      totalAsetLancar,
      totalPengeluaranBulanan,
    );

    final allRatios = [savingsRatio, debtServiceRatio, emergencyFundRatio];
    final overallScore = _calculateOverallScore(allRatios);

    return FinancialHealthAnalysis(
      overallScore: overallScore,
      overallStatus: _getOverallStatus(overallScore),
      ratios: allRatios,
      summary: _generateSummary(overallScore, allRatios),
    );
  }

  // Menggunakan .fold yang lebih aman
  double _calculateTotalIncome(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpense(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalDebtPayments(List<DebtReceivableModel> debts) {
    return debts
        .where((d) => d.type == DebtReceivableType.debt)
        .fold(0.0, (sum, d) => sum + d.monthlyPayment);
  }

  double _calculateTotalLiquidAssets(List<AssetModel> assets) {
    const liquidAssetTypes = [
      AssetType.cash,
      AssetType.bankAccount,
      AssetType.eWallet,
    ];

    return assets
        .where((asset) => liquidAssetTypes.contains(asset.type))
        .fold(0.0, (sum, asset) => sum + asset.value);
  }

  FinancialRatio _calculateSavingsRatio(double income, double expense) {
    final value = income == 0 ? 0.0 : (income - expense) / income;
    HealthStatus status;
    String recommendation;

    if (value >= 0.20) {
      status = HealthStatus.sehat;
      recommendation =
          'Luar biasa! Pertahankan kemampuan menabung di atas 20%.';
    } else if (value >= 0.10) {
      status = HealthStatus.cukup;
      recommendation =
          'Cukup baik. Coba tingkatkan dengan mengurangi pengeluaran yang tidak perlu.';
    } else {
      status = HealthStatus.kurang;
      recommendation =
          'Perlu perhatian. Prioritaskan untuk mengevaluasi pengeluaran dan mencari cara menambah pendapatan.';
    }
    return FinancialRatio(
      name: 'Rasio Tabungan',
      value: value,
      status: status,
      description:
          'Persentase pendapatan yang berhasil Anda simpan setelah pengeluaran.',
      recommendation: recommendation,
    );
  }

  FinancialRatio _calculateDebtServiceRatio(
    double debtPayments,
    double income,
  ) {
    final value = income == 0 ? 0.0 : debtPayments / income;
    HealthStatus status;
    String recommendation;

    if (value <= 0.30) {
      status = HealthStatus.sehat;
      recommendation = 'Sangat sehat! Anda mengelola utang dengan sangat baik.';
    } else if (value <= 0.35) {
      status = HealthStatus.cukup;
      recommendation =
          'Masih dalam batas wajar. Hati-hati dalam menambah utang baru.';
    } else {
      status = HealthStatus.kurang;
      recommendation =
          'Beban utang terlalu tinggi. Prioritaskan untuk melunasi utang dan hindari utang konsumtif baru.';
    }
    return FinancialRatio(
      name: 'Rasio Beban Utang',
      value: value,
      status: status,
      description:
          'Persentase pendapatan yang digunakan untuk membayar cicilan utang.',
      recommendation: recommendation,
    );
  }

  FinancialRatio _calculateEmergencyFundRatio(
    double liquidAssets,
    double monthlyExpense,
  ) {
    if (monthlyExpense == 0) {
      return const FinancialRatio(
        name: 'Rasio Dana Darurat',
        value: double.infinity,
        status: HealthStatus.sehat,
        description:
            'Anda tidak memiliki pengeluaran, dana darurat Anda sangat aman.',
        recommendation: 'Kondisi yang sangat baik!',
      );
    }
    final value = liquidAssets / monthlyExpense;
    HealthStatus status;
    String recommendation;

    if (value >= 6) {
      status = HealthStatus.sehat;
      recommendation =
          'Sangat bagus! Dana darurat Anda cukup untuk lebih dari 6 bulan.';
    } else if (value >= 3) {
      status = HealthStatus.cukup;
      recommendation =
          'Sudah cukup baik. Terus tambah hingga mencapai minimal 6 bulan pengeluaran.';
    } else {
      status = HealthStatus.kurang;
      recommendation =
          'Dana darurat kurang. Ini adalah prioritas utama untuk diisi demi keamanan finansial.';
    }
    return FinancialRatio(
      name: 'Rasio Dana Darurat (Bulan)',
      value: value,
      status: status,
      description:
          'Kesiapan dana untuk menutupi pengeluaran jika tidak ada pemasukan.',
      recommendation: recommendation,
    );
  }

  double _calculateOverallScore(List<FinancialRatio> ratios) {
    double score = 0;
    for (var ratio in ratios) {
      double ratioScore = 0;
      if (ratio.status == HealthStatus.sehat) {
        ratioScore = 100;
      } else if (ratio.status == HealthStatus.cukup) {
        ratioScore = 60;
      } else {
        ratioScore = 20;
      }

      if (ratio.name.contains('Dana Darurat')) {
        score += ratioScore * 0.4;
      } else if (ratio.name.contains('Tabungan')) {
        score += ratioScore * 0.4;
      } else if (ratio.name.contains('Utang')) {
        score += ratioScore * 0.2;
      }
    }
    return score;
  }

  HealthStatus _getOverallStatus(double score) {
    if (score >= 80) return HealthStatus.sehat;
    if (score >= 50) return HealthStatus.cukup;
    return HealthStatus.kurang;
  }

  String _generateSummary(double score, List<FinancialRatio> ratios) {
    if (_getOverallStatus(score) == HealthStatus.sehat) {
      return "Selamat! Kondisi keuangan Anda secara keseluruhan sangat sehat. Pertahankan kebiasaan baik ini.";
    }
    // Menggunakan firstWhereOrNull dari package:collection
    final worstRatio = ratios.firstWhereOrNull(
      (r) => r.status == HealthStatus.kurang,
    );
    if (worstRatio != null) {
      return "Kondisi keuanganmu cukup baik, namun perlu perhatian khusus pada bagian ${worstRatio.name}. ${worstRatio.recommendation}";
    }
    return "Kondisi keuanganmu sudah cukup baik. Terus tingkatkan untuk mencapai kondisi yang lebih sehat.";
  }
}
