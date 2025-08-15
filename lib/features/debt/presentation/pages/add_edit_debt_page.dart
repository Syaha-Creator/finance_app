import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/models/debt_receivable_model.dart';
import '../provider/debt_provider.dart';

class AddEditDebtPage extends ConsumerStatefulWidget {
  final DebtReceivableModel? debt;
  const AddEditDebtPage({super.key, this.debt});

  @override
  ConsumerState<AddEditDebtPage> createState() => _AddEditDebtPageState();
}

class _AddEditDebtPageState extends ConsumerState<AddEditDebtPage> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool get _isEditMode => widget.debt != null;

  DateTime? _dueDate;
  DebtReceivableType _selectedType = DebtReceivableType.debt;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      final debt = widget.debt!;
      _personNameController.text = widget.debt!.personName;
      _descriptionController.text = widget.debt!.description;

      final formatter = NumberFormat('#,###', 'id_ID');
      _amountController.text = formatter.format(debt.amount);

      _selectedType = widget.debt!.type;
      _dueDate = widget.debt!.dueDate;
    }
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_formKey.currentState!.validate()) {
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

      if (_isEditMode) {
        final updatedDebt = DebtReceivableModel(
          id: widget.debt!.id,
          userId: widget.debt!.userId,
          type: _selectedType,
          personName: _personNameController.text,
          description: _descriptionController.text,
          amount: amount,
          createdAt: widget.debt!.createdAt,
          dueDate: _dueDate,
          status: widget.debt!.status,
        );

        final success = await ref
            .read(debtControllerProvider.notifier)
            .updateDebt(updatedDebt);

        if (success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Catatan berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          navigator.pop();
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui catatan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final newDebt = DebtReceivableModel(
          userId: userId,
          type: _selectedType,
          personName: _personNameController.text,
          description: _descriptionController.text,
          amount: amount,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
          status: PaymentStatus.unpaid,
        );

        final success = await ref
            .read(debtControllerProvider.notifier)
            .addDebt(newDebt);

        if (success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Catatan berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          navigator.pop();
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan catatan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(debtControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Catatan' : 'Tambah Catatan Utang/Piutang',
        ),
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
                  SegmentedButton<DebtReceivableType>(
                    segments: const [
                      ButtonSegment(
                        value: DebtReceivableType.debt,
                        label: Text('Utang Saya'),
                      ),
                      ButtonSegment(
                        value: DebtReceivableType.receivable,
                        label: Text('Piutang Saya'),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (newSelection) {
                      setState(() => _selectedType = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _personNameController,
                    decoration: const InputDecoration(labelText: 'Nama Orang'),
                    validator:
                        (v) =>
                            (v == null || v.isEmpty)
                                ? 'Nama tidak boleh kosong'
                                : null,
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
                    validator:
                        (v) =>
                            (v == null || v.isEmpty)
                                ? 'Jumlah tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Keterangan'),
                    validator:
                        (v) =>
                            (v == null || v.isEmpty)
                                ? 'Keterangan tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Jatuh Tempo (Opsional)',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text:
                          _dueDate == null
                              ? ''
                              : DateFormat('dd MMMM yyyy').format(_dueDate!),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() => _dueDate = pickedDate);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: const Text('SIMPAN'),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
