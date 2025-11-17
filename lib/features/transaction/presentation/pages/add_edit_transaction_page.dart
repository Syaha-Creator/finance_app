import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/loading_action_button.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/income_expense_form.dart';
import '../widgets/transaction_type_selector.dart';
import '../widgets/transfer_form.dart';

class AddEditTransactionPage extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const AddEditTransactionPage({super.key, this.transaction});

  @override
  ConsumerState<AddEditTransactionPage> createState() =>
      _AddEditTransactionPageState();
}

class _AddEditTransactionPageState
    extends ConsumerState<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  String? _selectedCategory;
  String? _selectedAccount;
  String? _fromAccount;
  String? _toAccount;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  bool _isLoading = false;

  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _descriptionController = TextEditingController(text: t?.description);

    final initialAmount = t?.amount ?? 0;
    final formatter = NumberFormat('#,###', 'id_ID');
    _amountController = TextEditingController(
      text: initialAmount > 0 ? formatter.format(initialAmount) : '',
    );

    _selectedCategory = t?.category;
    _selectedAccount = t?.account;

    _selectedDate = _isEditMode ? t!.date : DateTime.now();
    _selectedType = _isEditMode ? t!.type : TransactionType.expense;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userId = ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) {
        if (!mounted) return;
        CoreSnackbar.showError(
          context,
          'Pengguna tidak ditemukan. Silakan login ulang.',
        );
        setState(() => _isLoading = false);
        return;
      }

      final amountString = _amountController.text.replaceAll('.', '');
      final amount = double.parse(amountString);

      try {
        final repo = ref.read(transactionRepositoryProvider);
        if (_selectedType == TransactionType.transfer) {
          await repo.addTransfer(
            amount: amount,
            fromAccount: _fromAccount!,
            toAccount: _toAccount!,
            date: _selectedDate,
            description: _descriptionController.text,
          );
        } else {
          final transactionData = TransactionModel(
            id: widget.transaction?.id,
            userId: userId,
            description: _descriptionController.text,
            amount: amount,
            category: _selectedCategory!,
            account: _selectedAccount!,
            date: _selectedDate,
            type: _selectedType,
          );
          if (_isEditMode) {
            await repo.updateTransaction(transactionData);
          } else {
            await repo.addTransaction(transactionData);
          }
        }

        if (!mounted) return;
        CoreSnackbar.showSuccess(
          context,
          'Transaksi berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        CoreSnackbar.showError(context, 'Gagal: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Transaction Type Selector (only for new transactions)
                  if (!_isEditMode) ...[
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.category_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jenis Transaksi',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Pilih jenis transaksi yang ingin Anda catat',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TransactionTypeSelector(
                            selectedType: _selectedType,
                            onTypeSelected: (type) {
                              setState(() {
                                _selectedType = type;
                                _selectedCategory = null;
                                _fromAccount = null;
                                _toAccount = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form Section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.description_outlined,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Detail Transaksi',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _selectedType == TransactionType.transfer
                            ? TransferForm(
                              amountController: _amountController,
                              descriptionController: _descriptionController,
                              fromAccount: _fromAccount,
                              toAccount: _toAccount,
                              selectedDate: _selectedDate,
                              onFromAccountChanged:
                                  (val) => setState(() => _fromAccount = val),
                              onToAccountChanged:
                                  (val) => setState(() => _toAccount = val),
                              onDateChanged:
                                  (val) => setState(() => _selectedDate = val),
                            )
                            : IncomeExpenseForm(
                              amountController: _amountController,
                              descriptionController: _descriptionController,
                              selectedCategory: _selectedCategory,
                              selectedAccount: _selectedAccount,
                              selectedDate: _selectedDate,
                              selectedType: _selectedType,
                              isEditMode: _isEditMode,
                              onCategoryChanged:
                                  (val) =>
                                      setState(() => _selectedCategory = val),
                              onAccountChanged:
                                  (val) =>
                                      setState(() => _selectedAccount = val),
                              onDateChanged:
                                  (val) => setState(() => _selectedDate = val),
                            ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit Button
                  LoadingActionButton(
                    onPressed: _submitForm,
                    isLoading: _isLoading,
                    text: _isEditMode ? 'PERBARUI' : 'SIMPAN',
                    icon: _isEditMode ? Icons.save_outlined : Icons.add,
                    height: 56,
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const CoreLoadingState(),
            ),
        ],
      ),
    );
  }
}
