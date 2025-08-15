import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../transaction/data/models/transaction_model.dart';

class UpcomingBillsCard extends StatelessWidget {
  final List<TransactionModel> bills;

  const UpcomingBillsCard({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,

      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tagihan Akan Datang',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (bills.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada tagihan dalam 7 hari ke depan.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                itemCount: bills.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.receipt_long,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bill.category,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              bill.description,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(bill.amount),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            DateFormat('d MMM', 'id_ID').format(bill.date),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
