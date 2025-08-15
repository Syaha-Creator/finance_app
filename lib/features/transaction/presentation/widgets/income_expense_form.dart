import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/thousand_input_formatter.dart';
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
        TextFormField(
          controller: descriptionController,
          decoration: _inputDecoration(
            'Keterangan',
            Icons.description_outlined,
          ),
          validator:
              (v) => (v == null || v.isEmpty) ? 'Keterangan wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: amountController,
          decoration: _inputDecoration('Jumlah', Icons.attach_money),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandInputFormatter(),
          ],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDatePicker(context, theme),
        const SizedBox(height: 16),
        categoriesValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
          data: (categories) {
            return DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: _inputDecoration('Kategori', Icons.category_outlined),
              items:
                  categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
              onChanged: onCategoryChanged,
              validator: (v) => v == null ? 'Pilih kategori' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        accountsValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
          data:
              (accounts) => DropdownButtonFormField<String>(
                initialValue: selectedAccount,
                decoration: _inputDecoration(
                  'Akun',
                  Icons.account_balance_wallet_outlined,
                ),
                items:
                    accounts
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.name,
                            child: Text(a.name),
                          ),
                        )
                        .toList(),
                onChanged: onAccountChanged,
                validator: (v) => v == null ? 'Pilih akun' : null,
              ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && picked != selectedDate) {
          onDateChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration('Tanggal', Icons.calendar_today_outlined),
        child: Text(
          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate),
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
    );
  }
}
