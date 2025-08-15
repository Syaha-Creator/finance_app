// lib/features/dashboard/presentation/widgets/cash_flow_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_viewmodel_provider.dart'; // Untuk model MonthlyCashFlow

class CashFlowCard extends StatelessWidget {
  final MonthlyCashFlow cashFlow;

  const CashFlowCard({super.key, required this.cashFlow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Formatter untuk menampilkan mata uang lengkap
    final numberFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final total = cashFlow.income + cashFlow.expense;
    final incomeFlex = total > 0 ? (cashFlow.income / total * 100).toInt() : 50;
    final expenseFlex =
        total > 0 ? (cashFlow.expense / total * 100).toInt() : 50;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Bulan Ini',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Baris Pemasukan
            Row(
              children: [
                const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Pemasukan', style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text(
                  numberFormat.format(cashFlow.income),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Baris Pengeluaran
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Pengeluaran', style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text(
                  numberFormat.format(cashFlow.expense),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Visual Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                    flex: incomeFlex,
                    child: Container(height: 10, color: Colors.green),
                  ),
                  Expanded(
                    flex: expenseFlex,
                    child: Container(height: 10, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
