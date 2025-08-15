import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/app_loading_indicator.dart';
import '../providers/recurring_transaction_provider.dart';
import 'add_edit_recurring_page.dart';

class RecurringTransactionPage extends ConsumerWidget {
  const RecurringTransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringTransactionsAsync = ref.watch(
      recurringTransactionsStreamProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Berulang')),
      body: recurringTransactionsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text('Belum ada jadwal transaksi berulang.'),
            );
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final item = transactions[index];
              return ListTile(
                title: Text(item.description),
                subtitle: Text(
                  'Setiap ${item.frequency.name}',
                ), // Akan kita perbaiki
                trailing: Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                  ).format(item.amount),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              AddEditRecurringPage(recurringTransaction: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditRecurringPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
