import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/models/recurring_transaction_model.dart';
import '../../data/models/transaction_model.dart';
import '../providers/recurring_transaction_provider.dart';
import '../providers/transaction_provider.dart';

class AddEditRecurringPage extends ConsumerStatefulWidget {
  final RecurringTransactionModel? recurringTransaction;
  const AddEditRecurringPage({super.key, this.recurringTransaction});

  @override
  ConsumerState<AddEditRecurringPage> createState() =>
      _AddEditRecurringPageState();
}

class _AddEditRecurringPageState extends ConsumerState<AddEditRecurringPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  // State untuk form
  TransactionType _type = TransactionType.expense;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  int _dayOfMonth = 1;
  int _dayOfWeek = 1;
  String? _selectedCategory;
  String? _selectedAccount;
  DateTime _startDate = DateTime.now();

  bool get isEditMode => widget.recurringTransaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final r = widget.recurringTransaction!;
      _descriptionController.text = r.description;
      _amountController.text = r.amount.toStringAsFixed(0);
      _type = r.type;
      _frequency = r.frequency;
      _dayOfMonth = r.dayOfMonth;
      _dayOfWeek = r.dayOfWeek;
      _selectedCategory = r.category;
      _selectedAccount = r.account;
      _startDate = r.startDate;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final amount = double.parse(_amountController.text.replaceAll('.', ''));
      final userId = ref.read(authStateChangesProvider).value?.uid;

      if (userId == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Pengguna tidak ditemukan. Silakan login ulang.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newRecurring = RecurringTransactionModel(
        id: widget.recurringTransaction?.id,
        userId: userId,
        description: _descriptionController.text,
        amount: amount,
        category: _selectedCategory!,
        account: _selectedAccount!,
        type: _type,
        frequency: _frequency,
        dayOfMonth: _dayOfMonth,
        dayOfWeek: _dayOfWeek,
        startDate: _startDate,
      );

      final controller = ref.read(
        recurringTransactionControllerProvider.notifier,
      );
      final success =
          isEditMode
              ? await controller.update(newRecurring)
              : await controller.add(newRecurring);

      if (success && mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Jadwal berhasil ${isEditMode ? 'diperbarui' : 'disimpan'}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } else if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan jadwal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(recurringTransactionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Jadwal' : 'Jadwal Baru')),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTypeSelector(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Keterangan'),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandInputFormatter(),
                    ],
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildAccountDropdown(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildFrequencySelector(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: Text(isEditMode ? 'UPDATE JADWAL' : 'SIMPAN JADWAL'),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // --- KUMPULAN WIDGET BUILDER UNTUK FORM ---

  Widget _buildTypeSelector() {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Pengeluaran'),
        ),
        ButtonSegment(value: TransactionType.income, label: Text('Pemasukan')),
      ],
      selected: {_type},
      onSelectionChanged: (newSelection) {
        setState(() {
          _type = newSelection.first;
          _selectedCategory = null; // Reset kategori saat tipe berubah
        });
      },
    );
  }

  Widget _buildCategoryDropdown() {
    final provider =
        _type == TransactionType.expense
            ? expenseCategoriesProvider
            : incomeCategoriesProvider;
    final categoriesAsync = ref.watch(provider);
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
      data:
          (categories) => DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items:
                categories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)),
                    )
                    .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val),
            validator: (v) => v == null ? 'Wajib dipilih' : null,
          ),
    );
  }

  Widget _buildAccountDropdown() {
    final accountsAsync = ref.watch(accountsProvider);
    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
      data:
          (accounts) => DropdownButtonFormField<String>(
            initialValue: _selectedAccount,
            decoration: const InputDecoration(labelText: 'Akun'),
            items:
                accounts
                    .map(
                      (a) =>
                          DropdownMenuItem(value: a.name, child: Text(a.name)),
                    )
                    .toList(),
            onChanged: (val) => setState(() => _selectedAccount = val),
            validator: (v) => v == null ? 'Wajib dipilih' : null,
          ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frekuensi Pengulangan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurringFrequency>(
          initialValue: _frequency,
          decoration: const InputDecoration(labelText: 'Ulangi Setiap'),
          items: const [
            DropdownMenuItem(
              value: RecurringFrequency.monthly,
              child: Text('Bulan'),
            ),
            DropdownMenuItem(
              value: RecurringFrequency.weekly,
              child: Text('Minggu'),
            ),
            DropdownMenuItem(
              value: RecurringFrequency.daily,
              child: Text('Hari'),
            ),
          ],
          onChanged: (val) => setState(() => _frequency = val!),
        ),
        if (_frequency == RecurringFrequency.monthly) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _dayOfMonth,
            decoration: const InputDecoration(labelText: 'Pada Tanggal'),
            items:
                List.generate(31, (i) => i + 1)
                    .map(
                      (d) =>
                          DropdownMenuItem(value: d, child: Text(d.toString())),
                    )
                    .toList(),
            onChanged: (val) => setState(() => _dayOfMonth = val!),
          ),
        ],
        if (_frequency == RecurringFrequency.weekly) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _dayOfWeek,
            decoration: const InputDecoration(labelText: 'Pada Hari'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Senin')),
              DropdownMenuItem(value: 2, child: Text('Selasa')),
              DropdownMenuItem(value: 3, child: Text('Rabu')),
              DropdownMenuItem(value: 4, child: Text('Kamis')),
              DropdownMenuItem(value: 5, child: Text('Jumat')),
              DropdownMenuItem(value: 6, child: Text('Sabtu')),
              DropdownMenuItem(value: 7, child: Text('Minggu')),
            ],
            onChanged: (val) => setState(() => _dayOfWeek = val!),
          ),
        ],
      ],
    );
  }
}
