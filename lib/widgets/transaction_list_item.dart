import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/app_formatters.dart';
import '../core/utils/category_icons.dart';
import '../features/transaction/data/models/transaction_model.dart';
import '../features/transaction/presentation/pages/transaction_detail_page.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;

    final color = isExpense ? AppColors.expense : AppColors.income;

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TransactionDetailPage(transaction: transaction),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(30),
                child: Icon(
                  CategoryIcons.getIconForCategory(transaction.category),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,

                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(transaction.category, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${isExpense ? '-' : '+'} ${AppFormatters.currency.format(transaction.amount)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
