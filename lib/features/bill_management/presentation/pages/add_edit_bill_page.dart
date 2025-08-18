import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/thousand_input_formatter.dart';
import '../../data/models/bill_model.dart';
import '../provider/bill_provider.dart';

class AddEditBillPage extends ConsumerStatefulWidget {
  final BillModel? bill;

  const AddEditBillPage({super.key, this.bill});

  @override
  ConsumerState<AddEditBillPage> createState() => _AddEditBillPageState();
}

class _AddEditBillPageState extends ConsumerState<AddEditBillPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  BillFrequency _selectedFrequency = BillFrequency.oneTime;
  bool _isRecurring = false;
  bool _hasReminder = true;
  int _reminderDays = 3;

  final List<String> _categories = [
    'Tagihan Listrik',
    'Tagihan Air',
    'Tagihan Internet',
    'Tagihan Telepon',
    'Tagihan Kartu Kredit',
    'Tagihan Asuransi',
    'Tagihan Sekolah',
    'Tagihan Rumah Sakit',
    'Tagihan Pajak',
    'Tagihan Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _loadBillData();
    }
  }

  void _loadBillData() {
    final bill = widget.bill!;
    _titleController.text = bill.title;
    _descriptionController.text = bill.description;
    _amountController.text = bill.amount.toString();
    _categoryController.text = bill.category;
    _notesController.text = bill.notes ?? '';
    _selectedDueDate = bill.dueDate;
    _selectedFrequency = bill.frequency;
    _isRecurring = bill.isRecurring;
    _hasReminder = bill.hasReminder;
    _reminderDays = bill.reminderDays;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bill != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tagihan' : 'Tambah Tagihan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            _buildTextField(
              controller: _titleController,
              label: 'Judul Tagihan',
              hint: 'Contoh: Tagihan Listrik Bulan Januari',
              icon: Icons.receipt_long_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tagihan harus diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description Field
            _buildTextField(
              controller: _descriptionController,
              label: 'Deskripsi (Opsional)',
              hint: 'Deskripsi detail tagihan',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Amount Field
            _buildTextField(
              controller: _amountController,
              label: 'Jumlah Tagihan',
              hint: '0',
              icon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandInputFormatter()],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tagihan harus diisi';
                }
                final amount = double.tryParse(value.replaceAll('.', ''));
                if (amount == null || amount <= 0) {
                  return 'Jumlah tagihan harus lebih dari 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category Field
            _buildDropdownField(
              controller: _categoryController,
              label: 'Kategori',
              icon: Icons.category_outlined,
              items: _categories,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kategori harus dipilih';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Due Date Field
            _buildDateField(),

            const SizedBox(height: 16),

            // Recurring Settings
            _buildRecurringSettings(),

            const SizedBox(height: 16),

            // Reminder Settings
            _buildReminderSettings(),

            const SizedBox(height: 16),

            // Notes Field
            _buildTextField(
              controller: _notesController,
              label: 'Catatan (Opsional)',
              hint: 'Catatan tambahan',
              icon: Icons.note_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Update Tagihan' : 'Simpan Tagihan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: controller.text.isEmpty ? null : controller.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items:
              items.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.text = newValue;
            }
          },
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jatuh Tempo',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value ?? false;
                });
              },
              activeColor: AppColors.primary,
            ),
            const Text('Tagihan Berulang'),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<BillFrequency>(
            initialValue: _selectedFrequency,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            items:
                BillFrequency.values.map((frequency) {
                  String label;
                  switch (frequency) {
                    case BillFrequency.oneTime:
                      label = 'Satu Kali';
                      break;
                    case BillFrequency.monthly:
                      label = 'Bulanan';
                      break;
                    case BillFrequency.quarterly:
                      label = 'Triwulan';
                      break;
                    case BillFrequency.yearly:
                      label = 'Tahunan';
                      break;
                  }
                  return DropdownMenuItem<BillFrequency>(
                    value: frequency,
                    child: Text(label),
                  );
                }).toList(),
            onChanged: (BillFrequency? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFrequency = newValue;
                });
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildReminderSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _hasReminder,
              onChanged: (value) {
                setState(() {
                  _hasReminder = value ?? false;
                });
              },
              activeColor: AppColors.primary,
            ),
            const Text('Aktifkan Pengingat'),
          ],
        ),
        if (_hasReminder) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Pengingat'),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _reminderDays,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items:
                      [1, 2, 3, 5, 7, 14, 30].map((days) {
                        return DropdownMenuItem<int>(
                          value: days,
                          child: Text('$days hari sebelum jatuh tempo'),
                        );
                      }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _reminderDays = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = double.parse(_amountController.text.replaceAll('.', ''));

        final bill = BillModel(
          id: widget.bill?.id ?? '',
          userId: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          amount: amount,
          category: _categoryController.text.trim(),
          dueDate: _selectedDueDate,
          status: BillStatus.pending,
          frequency: _selectedFrequency,
          nextDueDate: _isRecurring ? _calculateNextDueDate() : null,
          paidDate: null,
          notes:
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
          isRecurring: _isRecurring,
          hasReminder: _hasReminder,
          reminderDays: _reminderDays,
          createdAt: widget.bill?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.bill != null) {
          ref.read(billNotifierProvider.notifier).updateBill(bill);
        } else {
          ref.read(billNotifierProvider.notifier).addBill(bill);
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan tagihan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error saving bill: $e'); // Debug log
      }
    }
  }

  DateTime? _calculateNextDueDate() {
    switch (_selectedFrequency) {
      case BillFrequency.monthly:
        return DateTime(
          _selectedDueDate.year,
          _selectedDueDate.month + 1,
          _selectedDueDate.day,
        );
      case BillFrequency.quarterly:
        return DateTime(
          _selectedDueDate.year,
          _selectedDueDate.month + 3,
          _selectedDueDate.day,
        );
      case BillFrequency.yearly:
        return DateTime(
          _selectedDueDate.year + 1,
          _selectedDueDate.month,
          _selectedDueDate.day,
        );
      case BillFrequency.oneTime:
        return null;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.delete_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Hapus Tagihan'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus tagihan "${widget.bill!.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(billNotifierProvider.notifier)
                      .deleteBill(widget.bill!.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ya, Hapus'),
              ),
            ],
          ),
    );
  }
}
