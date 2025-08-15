import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/models/goal_model.dart';
import '../providers/goal_provider.dart';

class AddEditGoalPage extends ConsumerStatefulWidget {
  final GoalModel? goal;
  const AddEditGoalPage({super.key, this.goal});

  @override
  ConsumerState<AddEditGoalPage> createState() => _AddEditGoalPageState();
}

class _AddEditGoalPageState extends ConsumerState<AddEditGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime? _targetDate;

  bool get _isEditMode => widget.goal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final g = widget.goal!;
      _nameController.text = g.name;
      _targetAmountController.text = g.targetAmount.toStringAsFixed(0);
      _targetDate = g.targetDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      final targetAmount = double.parse(
        _targetAmountController.text.replaceAll('.', ''),
      );
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

      final goalData = GoalModel(
        id: widget.goal?.id,
        userId: userId,
        name: _nameController.text,
        targetAmount: targetAmount,
        currentAmount: widget.goal?.currentAmount ?? 0,
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
        targetDate: _targetDate!,
        status: widget.goal?.status ?? GoalStatus.inProgress,
      );

      try {
        final controller = ref.read(goalControllerProvider.notifier);
        final bool success;
        if (_isEditMode) {
          success = await controller.updateGoal(goalData);
        } else {
          success = await controller.addGoal(goalData);
        }

        if (success && mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Tujuan berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          navigator.pop();
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(goalControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Tujuan' : 'Tambah Tujuan Baru'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Tujuan'),
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'Nama tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Target',
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
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Target Tanggal Tercapai',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text:
                      _targetDate == null
                          ? ''
                          : DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(_targetDate!),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        _targetDate ??
                        DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() => _targetDate = pickedDate);
                  }
                },
                validator:
                    (v) =>
                        _targetDate == null
                            ? 'Tanggal tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                child: const Text('SIMPAN TUJUAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
