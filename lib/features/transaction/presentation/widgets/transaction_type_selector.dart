import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeSelected;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children:
            TransactionType.values.map((type) {
              final isSelected = selectedType == type;
              final color = _getColorForType(type);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onTypeSelected(type),
                      borderRadius: BorderRadius.circular(12.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      color,
                                      color.withValues(alpha: 0.8),
                                    ],
                                  )
                                  : null,
                          color: isSelected ? null : Colors.transparent,
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSelected ? 8 : 6),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForType(type),
                                color: isSelected ? Colors.white : color,
                                size: isSelected ? 20 : 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getTitleForType(type),
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                fontSize: isSelected ? 12 : 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Color _getColorForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
    }
  }

  IconData _getIconForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.trending_up_rounded;
      case TransactionType.expense:
        return Icons.trending_down_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }

  String _getTitleForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}
