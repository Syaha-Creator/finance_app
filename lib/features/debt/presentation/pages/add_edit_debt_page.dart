import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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
  bool get _isLoading => ref.watch(debtControllerProvider);

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
            // Custom App Bar dengan tombol back
            _buildCustomAppBar(context, theme),

            // Form content
            Expanded(
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Header dengan gradient
                      SliverToBoxAdapter(child: _buildHeader(context, theme)),

                      // Form content
                      SliverToBoxAdapter(child: _buildForm(context, theme)),

                      // Bottom padding
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),

                  // Loading overlay
                  if (_isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              _isEditMode ? 'Edit Catatan' : 'Tambah Catatan Utang/Piutang',
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
      padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(20),
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
              _isEditMode ? Icons.edit : Icons.add,
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
                  _isEditMode ? 'Edit Catatan' : 'Tambah Catatan Baru',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isEditMode
                      ? 'Perbarui informasi utang/piutang Anda'
                      : 'Catat utang atau piutang baru untuk melacak keuangan',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type selector
            _buildTypeSelector(context, theme),

            const SizedBox(height: 20),

            // Person Name Field
            _buildTextField(
              context,
              theme,
              controller: _personNameController,
              label: 'Nama Orang',
              hint: 'Masukkan nama orang yang berutang/piutang',
              validator:
                  (v) =>
                      (v == null || v.isEmpty)
                          ? 'Nama tidak boleh kosong'
                          : null,
            ),

            const SizedBox(height: 20),

            // Amount Field
            _buildTextField(
              context,
              theme,
              controller: _amountController,
              label: 'Jumlah',
              hint: 'Masukkan jumlah utang/piutang',
              prefixText: 'Rp ',
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

            const SizedBox(height: 20),

            // Description Field
            _buildTextField(
              context,
              theme,
              controller: _descriptionController,
              label: 'Keterangan',
              hint: 'Tambahkan keterangan atau alasan',
              validator:
                  (v) =>
                      (v == null || v.isEmpty)
                          ? 'Keterangan tidak boleh kosong'
                          : null,
            ),

            const SizedBox(height: 20),

            // Due Date Field
            _buildDateField(context, theme),

            const SizedBox(height: 28),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _isEditMode ? 'PERBARUI CATATAN' : 'SIMPAN CATATAN',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Jenis Catatan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<DebtReceivableType>(
          segments: const [
            ButtonSegment(
              value: DebtReceivableType.debt,
              label: Text('Utang Saya'),
              icon: Icon(Icons.arrow_upward),
            ),
            ButtonSegment(
              value: DebtReceivableType.receivable,
              label: Text('Piutang Saya'),
              icon: Icon(Icons.arrow_downward),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (newSelection) {
            setState(() => _selectedType = newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              );
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return theme.colorScheme.onSurface;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    ThemeData theme, {
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Jatuh Tempo (Opsional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _dueDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() => _dueDate = pickedDate);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'Pilih tanggal jatuh tempo'
                        : DateFormat('dd MMMM yyyy', 'id_ID').format(_dueDate!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          _dueDate == null
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_dueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _dueDate = null),
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
