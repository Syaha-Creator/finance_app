import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
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
    _selectedDate = t?.date ?? DateTime.now();
    _selectedType = _isEditMode ? t!.type : TransactionType.expense;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userId = ref.read(authStateChangesProvider).value?.uid;
      if (userId == null) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Error: Pengguna tidak ditemukan. Silakan login ulang.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
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

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Transaksi berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          if (_isEditMode) navigator.pop();
          navigator.pop();
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi'),
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
                  if (!_isEditMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: TransactionTypeSelector(
                        selectedType: _selectedType,
                        onTypeSelected: (newType) {
                          setState(() {
                            _selectedType = newType;
                            _selectedCategory = null;
                            _fromAccount = null;
                            _toAccount = null;
                          });
                        },
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child:
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
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: Text(_isEditMode ? 'PERBARUI' : 'SIMPAN'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
