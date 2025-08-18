import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/models/investment_model.dart';
import '../provider/investment_provider.dart';

class InvestmentListItem extends ConsumerWidget {
  final InvestmentModel investment;

  const InvestmentListItem({super.key, required this.investment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProfit = investment.profitLoss >= 0;

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      investment.type,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(investment.type),
                    color: _getTypeColor(investment.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investment.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        investment.symbol,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context),
              ],
            ),

            const SizedBox(height: 16),

            // Investment Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Jumlah',
                    investment.quantity.toStringAsFixed(2),
                    Icons.analytics_outlined,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Harga Rata-rata',
                    AppFormatters.currency.format(investment.averagePrice),
                    Icons.price_check_outlined,
                    AppColors.accent,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Harga Sekarang',
                    AppFormatters.currency.format(investment.currentPrice),
                    Icons.trending_up_outlined,
                    AppColors.income,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Value and Profit/Loss
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (isProfit ? AppColors.success : AppColors.error).withValues(
                      alpha: 0.1,
                    ),
                    (isProfit ? AppColors.success : AppColors.error).withValues(
                      alpha: 0.05,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isProfit ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Investasi',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          AppFormatters.currency.format(
                            investment.totalInvested,
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nilai Sekarang',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          AppFormatters.currency.format(
                            investment.currentValue,
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.income,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Profit/Loss',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${isProfit ? '+' : ''}${AppFormatters.currency.format(investment.profitLoss)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                isProfit ? AppColors.success : AppColors.error,
                          ),
                        ),
                        Text(
                          '${isProfit ? '+' : ''}${investment.profitLossPercentage.toStringAsFixed(2)}%',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                isProfit ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (investment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        investment.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Actions Row
            if (investment.status == InvestmentStatus.active) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdatePriceDialog(context, ref),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Update Harga'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddQuantityDialog(context, ref),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showSellDialog(context, ref),
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text('Jual'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: BorderSide(color: AppColors.warning),
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

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (investment.status) {
      case InvestmentStatus.active:
        color = AppColors.success;
        text = 'Aktif';
        icon = Icons.check_circle_outlined;
        break;
      case InvestmentStatus.sold:
        color = AppColors.warning;
        text = 'Terjual';
        icon = Icons.sell_outlined;
        break;
      case InvestmentStatus.matured:
        color = AppColors.accent;
        text = 'Jatuh Tempo';
        icon = Icons.schedule_outlined;
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

  Color _getTypeColor(InvestmentType type) {
    switch (type) {
      case InvestmentType.stock:
        return AppColors.primary;
      case InvestmentType.mutualFund:
        return AppColors.accent;
      case InvestmentType.crypto:
        return AppColors.warning;
      case InvestmentType.bond:
        return AppColors.success;
      case InvestmentType.gold:
        return Colors.amber;
      case InvestmentType.property:
        return Colors.brown;
      case InvestmentType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(InvestmentType type) {
    switch (type) {
      case InvestmentType.stock:
        return Icons.trending_up;
      case InvestmentType.mutualFund:
        return Icons.pie_chart;
      case InvestmentType.crypto:
        return Icons.currency_bitcoin;
      case InvestmentType.bond:
        return Icons.account_balance;
      case InvestmentType.gold:
        return Icons.monetization_on;
      case InvestmentType.property:
        return Icons.home;
      case InvestmentType.other:
        return Icons.attach_money;
    }
  }

  void _showUpdatePriceDialog(BuildContext context, WidgetRef ref) {
    final priceController = TextEditingController(
      text: investment.currentPrice.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Harga Sekarang'),
            content: TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga Baru',
                prefixText: 'Rp ',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newPrice = double.tryParse(priceController.text);
                  if (newPrice != null && newPrice > 0) {
                    ref
                        .read(investmentNotifierProvider.notifier)
                        .updateCurrentPrice(investment.id, newPrice);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showAddQuantityDialog(BuildContext context, WidgetRef ref) {
    final quantityController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tambah Jumlah'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Tambahan',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Unit',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final quantity = double.tryParse(quantityController.text);
                  final price = double.tryParse(priceController.text);
                  if (quantity != null &&
                      price != null &&
                      quantity > 0 &&
                      price > 0) {
                    ref
                        .read(investmentNotifierProvider.notifier)
                        .addQuantity(investment.id, quantity, price);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Tambah'),
              ),
            ],
          ),
    );
  }

  void _showSellDialog(BuildContext context, WidgetRef ref) {
    final quantityController = TextEditingController(
      text: investment.quantity.toString(),
    );
    final priceController = TextEditingController(
      text: investment.currentPrice.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Jual Investasi'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah yang Dijual',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Jual per Unit',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final quantity = double.tryParse(quantityController.text);
                  final price = double.tryParse(priceController.text);
                  if (quantity != null &&
                      price != null &&
                      quantity > 0 &&
                      price > 0) {
                    if (quantity >= investment.quantity) {
                      ref
                          .read(investmentNotifierProvider.notifier)
                          .markAsSold(investment.id, price);
                    } else {
                      ref
                          .read(investmentNotifierProvider.notifier)
                          .sellPartial(investment.id, quantity, price);
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Jual'),
              ),
            ],
          ),
    );
  }
}
