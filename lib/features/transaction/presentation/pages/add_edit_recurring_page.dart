import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
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
      final amount = double.parse(_amountController.text.replaceAll('.', ''));
      final userId = ref.read(authStateChangesProvider).value?.uid;

      if (userId == null) {
        if (!mounted) return;
        CoreSnackbar.showError(
          context,
          'Pengguna tidak ditemukan. Silakan login ulang.',
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

      if (!mounted) return;
      if (success) {
        CoreSnackbar.showSuccess(
          context,
          'Jadwal berhasil ${isEditMode ? 'diperbarui' : 'disimpan'}',
        );
        Navigator.of(context).pop();
      } else {
        CoreSnackbar.showError(context, 'Gagal menyimpan jadwal');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(recurringTransactionControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(context, theme),

            // Form Content
            Expanded(
              child: Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: CustomScrollView(
                      slivers: [
                        // Header dengan gradient
                        SliverToBoxAdapter(child: _buildHeader(context, theme)),

                        // Form content
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTypeSelector(),
                                const SizedBox(height: 20),
                                _buildDescriptionField(),
                                const SizedBox(height: 20),
                                _buildAmountField(),
                                const SizedBox(height: 20),
                                _buildCategoryDropdown(),
                                const SizedBox(height: 20),
                                _buildAccountDropdown(),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),
                                _buildFrequencySelector(),
                                const SizedBox(height: 32),
                                _buildSubmitButton(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Loading overlay
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const CoreLoadingState(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KUMPULAN WIDGET BUILDER UNTUK FORM ---

  Widget _buildCustomAppBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Tombol back
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Judul halaman
          Expanded(
            child: Text(
              isEditMode ? 'Edit Jadwal' : 'Jadwal Baru',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
            AppColors.primaryDark,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isEditMode ? Icons.edit : Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Edit Jadwal' : 'Jadwal Baru',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isEditMode
                      ? 'Perbarui jadwal transaksi berulang'
                      : 'Buat jadwal transaksi yang berulang otomatis',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return CoreTextField(
      controller: _descriptionController,
      label: 'Keterangan',
      hint: 'Contoh: Bayar internet, Gaji bulanan, dll',
      icon: Icons.description,
      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Widget _buildAmountField() {
    return CoreAmountInput(
      controller: _amountController,
      label: 'Jumlah',
      hint: 'Masukkan jumlah transaksi',
      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Widget _buildSubmitButton() {
    final isLoading = ref.watch(recurringTransactionControllerProvider);

    return CoreLoadingButton(
      onPressed: _submit,
      text: isEditMode ? 'UPDATE JADWAL' : 'SIMPAN JADWAL',
      isLoading: isLoading,
    );
  }

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
      loading: () => const CoreLoadingState(size: 20),
      error: (err, stack) => Text('Error: $err'),
      data: (categories) {
        return CoreDropdown<String>(
          value: _selectedCategory,
          onChanged: (val) => setState(() => _selectedCategory = val),
          label: 'Kategori',
          items: categories
              .map(
                (c) => DropdownMenuItem(value: c.name, child: Text(c.name)),
              )
              .toList(),
          validator: (v) => v == null ? 'Wajib dipilih' : null,
        );
      },
    );
  }

  Widget _buildAccountDropdown() {
    final accountsAsync = ref.watch(accountsProvider);
    return accountsAsync.when(
      loading: () => const CoreLoadingState(size: 20),
      error: (err, stack) => Text('Error: $err'),
      data: (accounts) {
        return CoreDropdown<String>(
          value: _selectedAccount,
          onChanged: (val) => setState(() => _selectedAccount = val),
          label: 'Akun',
          items: accounts
              .map(
                (a) => DropdownMenuItem(value: a.name, child: Text(a.name)),
              )
              .toList(),
          validator: (v) => v == null ? 'Wajib dipilih' : null,
        );
      },
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
