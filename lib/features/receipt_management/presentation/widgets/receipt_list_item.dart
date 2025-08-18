import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/models/receipt_model.dart';
import '../provider/receipt_provider.dart';

class ReceiptListItem extends ConsumerWidget {
  final ReceiptModel receipt;

  const ReceiptListItem({super.key, required this.receipt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Receipt Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    receipt.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.shade600,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Receipt Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.merchantName ?? 'Merchant Tidak Diketahui',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (receipt.merchantAddress != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          receipt.merchantAddress!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (receipt.transactionDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          AppFormatters.formatDateHeader(
                            receipt.transactionDate!,
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status Chip
                _buildStatusChip(context),
              ],
            ),

            const SizedBox(height: 16),

            // Amount and Items
            if (receipt.totalAmount != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.income,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppFormatters.currency.format(receipt.totalAmount!),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.income,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Items List
            if (receipt.items != null && receipt.items!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...receipt.items!
                        .take(3)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• $item',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                    if (receipt.items!.length > 3)
                      Text(
                        '... dan ${receipt.items!.length - 3} item lainnya',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Notes
            if (receipt.notes?.isNotEmpty == true) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        receipt.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Actions Row
            Row(
              children: [
                if (receipt.status == ReceiptStatus.pending) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          () => _showActionDialog(context, ref, 'processed'),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Tandai Diproses'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => _showActionDialog(context, ref, 'archived'),
                    icon: const Icon(Icons.archive_outlined, size: 18),
                    label: const Text('Arsipkan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showActionDialog(context, ref, 'delete'),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (receipt.status) {
      case ReceiptStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        icon = Icons.pending_outlined;
        break;
      case ReceiptStatus.processed:
        color = AppColors.success;
        text = 'Diproses';
        icon = Icons.check_circle_outlined;
        break;
      case ReceiptStatus.archived:
        color = AppColors.accent;
        text = 'Diarsipkan';
        icon = Icons.archive_outlined;
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
    String title;
    String message;
    String confirmText;
    Color confirmColor;
    IconData confirmIcon;

    switch (action) {
      case 'processed':
        title = 'Tandai Diproses';
        message =
            'Apakah Anda yakin ingin menandai struk ini sebagai diproses?';
        confirmText = 'Ya, Diproses';
        confirmColor = AppColors.success;
        confirmIcon = Icons.check_circle_outline;
        break;
      case 'archived':
        title = 'Arsipkan Struk';
        message = 'Apakah Anda yakin ingin mengarsipkan struk ini?';
        confirmText = 'Ya, Arsipkan';
        confirmColor = AppColors.accent;
        confirmIcon = Icons.archive_outlined;
        break;
      case 'delete':
        title = 'Hapus Struk';
        message =
            'Apakah Anda yakin ingin menghapus struk ini? Tindakan ini tidak dapat dibatalkan.';
        confirmText = 'Ya, Hapus';
        confirmColor = AppColors.error;
        confirmIcon = Icons.delete_outline;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(confirmIcon, color: confirmColor),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performAction(ref, action);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  void _performAction(WidgetRef ref, String action) {
    switch (action) {
      case 'processed':
        ref.read(receiptNotifierProvider.notifier).markAsProcessed(receipt.id);
        break;
      case 'archived':
        ref.read(receiptNotifierProvider.notifier).markAsArchived(receipt.id);
        break;
      case 'delete':
        ref.read(receiptNotifierProvider.notifier).deleteReceipt(receipt.id);
        break;
    }
  }
}
