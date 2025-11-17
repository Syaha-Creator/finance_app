import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/models/bill_model.dart';
import '../providers/bill_provider.dart';

class BillListItem extends ConsumerWidget {
  final BillModel bill;

  const BillListItem({super.key, required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue =
        bill.status == BillStatus.pending &&
        bill.dueDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (bill.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          bill.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusChip(context, isOverdue),
              ],
            ),

            const SizedBox(height: 24),

            // Details Row
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Jatuh Tempo',
                    AppFormatters.formatDateHeader(bill.dueDate),
                    Icons.calendar_today_outlined,
                    isOverdue ? AppColors.error : AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Kategori',
                    bill.category,
                    Icons.category_outlined,
                    AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Jumlah',
                    AppFormatters.currency.format(bill.amount),
                    Icons.account_balance_wallet_outlined,
                    AppColors.income,
                  ),
                ),
              ],
            ),

            if (bill.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bill.notes!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions Row
            if (bill.status == BillStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed:
                            () => _showActionDialog(context, ref, 'paid'),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          'Tandai Lunas',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          backgroundColor: AppColors.success.withValues(
                            alpha: 0.08,
                          ),
                          side: BorderSide(
                            color: AppColors.success,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed:
                            () => _showActionDialog(context, ref, 'cancelled'),
                        icon: const Icon(Icons.cancel_outlined, size: 20),
                        label: Text(
                          'Batalkan',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          backgroundColor: AppColors.error.withValues(
                            alpha: 0.08,
                          ),
                          side: BorderSide(color: AppColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isOverdue) {
    Color color;
    String text;
    IconData icon;

    switch (bill.status) {
      case BillStatus.pending:
        if (isOverdue) {
          color = AppColors.error;
          text = 'Jatuh Tempo';
          icon = Icons.warning_amber_outlined;
        } else {
          color = AppColors.warning;
          text = 'Pending';
          icon = Icons.pending_outlined;
        }
        break;
      case BillStatus.paid:
        color = AppColors.success;
        text = 'Lunas';
        icon = Icons.check_circle_outlined;
        break;
      case BillStatus.cancelled:
        color = AppColors.error;
        text = 'Dibatalkan';
        icon = Icons.cancel_outlined;
        break;
      case BillStatus.overdue:
        color = AppColors.error;
        text = 'Jatuh Tempo';
        icon = Icons.warning_amber_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, WidgetRef ref, String action) {
    final actionText = action == 'paid' ? 'Lunas' : 'Dibatalkan';
    final actionIcon =
        action == 'paid' ? Icons.check_circle_outline : Icons.cancel_outlined;
    final actionColor = action == 'paid' ? AppColors.success : AppColors.error;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(actionIcon, color: actionColor),
                const SizedBox(width: 8),
                Text('Tandai $actionText'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menandai tagihan "${bill.title}" sebagai $actionText?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (action == 'paid') {
                    ref.read(billNotifierProvider.notifier).markAsPaid(bill.id);
                  } else {
                    ref
                        .read(billNotifierProvider.notifier)
                        .markAsCancelled(bill.id);
                  }
                  // Refresh providers for real-time updates
                  ref.invalidate(billsProvider);
                  ref.invalidate(billsSummaryProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Ya, $actionText'),
              ),
            ],
          ),
    );
  }
}
