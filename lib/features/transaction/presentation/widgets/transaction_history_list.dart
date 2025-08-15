import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../providers/transaction_provider.dart';
import '../../../../widgets/transaction_list_item.dart';

class TransactionHistoryList extends ConsumerWidget {
  final Map<DateTime, List<dynamic>> groupedTransactions;
  const TransactionHistoryList({super.key, required this.groupedTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsStream = ref.watch(transactionsStreamProvider);

    return transactionsStream.when(
      loading:
          () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) =>
              SliverFillRemaining(child: Center(child: Text('Error: $err'))),
      data: (transactions) {
        if (transactions.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/receipt_transaction.json',
                    width: 350,
                    height: 350,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Transaksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Catat transaksi pertamamu sekarang!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final date = groupedTransactions.keys.elementAt(index);
            final transactionsOnDate = groupedTransactions[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 8.0,
                    left: 8.0,
                  ),
                  child: Text(
                    AppFormatters.formatDateHeader(date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                ...transactionsOnDate.map(
                  (tx) => TransactionListItem(transaction: tx),
                ),
              ],
            );
          }, childCount: groupedTransactions.length),
        );
      },
    );
  }
}
