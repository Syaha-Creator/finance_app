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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          context,
          'Pengeluaran',
          Icons.arrow_downward,
          TransactionType.expense,
        ),
        _buildButton(
          context,
          'Pemasukan',
          Icons.arrow_upward,
          TransactionType.income,
        ),
        _buildButton(
          context,
          'Transfer',
          Icons.swap_horiz,
          TransactionType.transfer,
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    TransactionType type,
  ) {
    final bool isSelected = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeSelected(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
