import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

// Provider ini akan menghasilkan Map<String, double>
// yang berisi saran budget per kategori.
final budgetSuggestionProvider =
    FutureProvider.autoDispose<Map<String, double>>((ref) async {
      // Ambil semua transaksi pengguna
      final transactions = await ref.watch(transactionsStreamProvider.future);

      if (transactions.isEmpty) {
        return {}; // Kembalikan map kosong jika tidak ada transaksi
      }

      // Tentukan rentang 3 bulan terakhir (tidak termasuk bulan ini)
      final now = DateTime.now();
      final lastMonth = DateTime(
        now.year,
        now.month,
        0,
      ); // Hari terakhir bulan lalu
      final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);

      // Filter transaksi pengeluaran dalam 3 bulan terakhir
      final recentExpenses =
          transactions.where((t) {
            return t.type == TransactionType.expense &&
                t.category != 'Transfer Keluar' &&
                t.date.isAfter(threeMonthsAgo) &&
                t.date.isBefore(lastMonth.add(const Duration(days: 1)));
          }).toList();

      if (recentExpenses.isEmpty) {
        return {};
      }

      // Kelompokkan berdasarkan kategori
      final expensesByCategory = groupBy(
        recentExpenses,
        (TransactionModel t) => t.category,
      );

      // Hitung total bulan yang ada datanya (antara 1 s/d 3)
      final monthsWithData = <String>{};
      for (var t in recentExpenses) {
        monthsWithData.add('${t.date.year}-${t.date.month}');
      }
      final totalMonths = monthsWithData.length;

      // Hitung rata-rata pengeluaran per kategori
      final Map<String, double> suggestedBudget = {};
      expensesByCategory.forEach((category, transactions) {
        final total = transactions.fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );
        final average = total / totalMonths;
        // Bulatkan ke 1000 rupiah terdekat untuk angka yang lebih rapi
        suggestedBudget[category] = (average / 1000).ceil() * 1000;
      });

      return suggestedBudget;
    });
