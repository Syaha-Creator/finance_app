import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/category_icons.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'add_edit_transaction_page.dart';

class TransactionDetailPage extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Transaksi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus transaksi ini?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              child: const Text('Hapus'),
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final pageNavigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  await ref
                      .read(transactionRepositoryProvider)
                      .deleteTransaction(transaction.id!);

                  navigator.pop();
                  pageNavigator.pop();

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Transaksi berhasil dihapus'),
                      backgroundColor: AppColors.income,
                    ),
                  );
                } catch (e) {
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: AppColors.expense,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppColors.expense : AppColors.income;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),

        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          AddEditTransactionPage(transaction: transaction),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isExpense ? '-' : '+'} ${AppFormatters.currency.format(transaction.amount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  icon: CategoryIcons.getIconForCategory(transaction.category),
                  title: 'Kategori',
                  value: transaction.category,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Akun',
                  value: transaction.account,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Tanggal',
                  value: DateFormat(
                    'EEEE, dd MMMM yyyy',
                    'id_ID',
                  ).format(transaction.date),
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.access_time,
                  title: 'Waktu',
                  value: DateFormat('HH:mm', 'id_ID').format(transaction.date),
                  hideDivider: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool hideDivider = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: textTheme.bodySmall?.color),
          title: Text(title, style: textTheme.bodyMedium),
          trailing: Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (!hideDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1),
          ),
      ],
    );
  }
}
