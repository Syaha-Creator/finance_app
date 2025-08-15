import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/month_selector.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../widgets/transaction_history_list.dart';

class TransactionPage extends ConsumerWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedTransactions = ref.watch(groupedTransactionsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: MonthSelector(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: TransactionHistoryList(
              groupedTransactions: groupedTransactions,
            ),
          ),
        ],
      ),
    );
  }
}
