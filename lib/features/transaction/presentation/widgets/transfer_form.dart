import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/dropdown_helpers.dart';
import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/transaction_provider.dart';

class TransferForm extends ConsumerWidget {
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final String? fromAccount;
  final String? toAccount;
  final DateTime selectedDate;
  final ValueChanged<String?> onFromAccountChanged;
  final ValueChanged<String?> onToAccountChanged;
  final ValueChanged<DateTime> onDateChanged;

  const TransferForm({
    super.key,
    required this.amountController,
    required this.descriptionController,
    this.fromAccount,
    this.toAccount,
    required this.selectedDate,
    required this.onFromAccountChanged,
    required this.onToAccountChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsValue = ref.watch(accountsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Transfer',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: amountController,
          decoration: _inputDecoration('Jumlah Transfer', Icons.attach_money),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandInputFormatter(),
          ],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
            if (fromAccount == toAccount && fromAccount != null) {
              return 'Akun tidak boleh sama';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDatePicker(context, theme),
        const SizedBox(height: 16),
        accountsValue.when(
          loading: () => const Center(child: CoreLoadingState()),
          error: (err, stack) => Text('Error: $err'),
          data: (accounts) {
            return DropdownButtonFormField<String>(
              initialValue: fromAccount,
              decoration: _inputDecoration(
                'Dari Akun',
                Icons.north_east_outlined,
              ),
              items: DropdownItemHelpers.createAccountItems(accounts),
              onChanged: onFromAccountChanged,
              validator: (v) => v == null ? 'Pilih akun asal' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        accountsValue.when(
          loading: () => const Center(child: CoreLoadingState()),
          error: (err, stack) => Text('Error: $err'),
          data: (accounts) {
            // --- PERBAIKAN TIPE DROPDOWN ---
            return DropdownButtonFormField<String>(
              initialValue: toAccount,
              decoration: _inputDecoration(
                'Ke Akun',
                Icons.south_west_outlined,
              ),
              items: DropdownItemHelpers.createAccountItems(accounts),
              onChanged: onToAccountChanged,
              validator: (v) => v == null ? 'Pilih akun tujuan' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: _inputDecoration(
            'Keterangan (Opsional)',
            Icons.description_outlined,
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
          final now = DateTime.now();
          final combinedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            now.hour,
            now.minute,
            now.second,
          );
          onDateChanged(combinedDateTime);
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
