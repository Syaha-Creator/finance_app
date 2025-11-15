import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class IncomeExpenseForm extends ConsumerWidget {
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final String? selectedCategory;
  final String? selectedAccount;
  final DateTime selectedDate;
  final TransactionType selectedType;
  final bool isEditMode;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onAccountChanged;
  final ValueChanged<DateTime> onDateChanged;

  const IncomeExpenseForm({
    super.key,
    required this.descriptionController,
    required this.amountController,
    this.selectedCategory,
    this.selectedAccount,
    required this.selectedDate,
    required this.selectedType,
    required this.isEditMode,
    required this.onCategoryChanged,
    required this.onAccountChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCategoriesProvider =
        selectedType == TransactionType.expense
            ? expenseCategoriesProvider
            : incomeCategoriesProvider;

    final categoriesValue = ref.watch(selectedCategoriesProvider);
    final accountsValue = ref.watch(accountsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Transaksi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CoreTextField(
          controller: descriptionController,
          label: 'Keterangan',
          hint: 'Masukkan keterangan transaksi',
          icon: Icons.description_outlined,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Keterangan wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        CoreAmountInput(
          controller: amountController,
          label: 'Jumlah',
          hint: 'Masukkan jumlah',
          validator: (v) {
            if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CoreDatePicker(
          selectedDate: selectedDate,
          onDateSelected: (date) {
            final now = DateTime.now();
            final combinedDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              now.hour,
              now.minute,
              now.second,
            );
            onDateChanged(combinedDateTime);
          },
          label: 'Tanggal',
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ),
        const SizedBox(height: 16),
        categoriesValue.when(
          loading: () => const CoreLoadingState(size: 20),
          error: (err, stack) => Text('Error: $err'),
          data: (categories) {
            return CoreDropdown<String>(
              value: selectedCategory,
              onChanged: onCategoryChanged,
              label: 'Kategori',
              icon: Icons.category_outlined,
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.name,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        accountsValue.when(
          loading: () => const CoreLoadingState(size: 20),
          error: (err, stack) => Text('Error: $err'),
          data: (accounts) {
            return CoreDropdown<String>(
              value: selectedAccount,
              onChanged: onAccountChanged,
              label: 'Akun',
              icon: Icons.account_balance_wallet_outlined,
              items: accounts
                  .map(
                    (a) => DropdownMenuItem(
                      value: a.name,
                      child: Text(a.name),
                    ),
                  )
                  .toList(),
              validator: (v) => v == null ? 'Pilih akun' : null,
            );
          },
        ),
      ],
    );
  }
}
