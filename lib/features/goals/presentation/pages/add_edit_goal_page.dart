import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
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
  bool get _isLoading => ref.watch(goalControllerProvider);

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
      final targetAmount = double.parse(
        _targetAmountController.text.replaceAll('.', ''),
      );
      final userId = ref.read(authStateChangesProvider).value?.uid;

      if (userId == null) {
        CoreSnackbar.showError(
          context,
          'Pengguna tidak ditemukan. Silakan login ulang.',
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
          CoreSnackbar.showSuccess(
            context,
            'Tujuan berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}',
          );
          navigator.pop();
        }
      } catch (e) {
        if (mounted) {
          CoreSnackbar.showError(context, 'Gagal: $e');
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(context, theme),

                    const SizedBox(height: 24),

                    // Form
                    _buildForm(context, theme),

                    // Bottom padding
                    const SizedBox(height: 32),
                  ],
                ),
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
              _isEditMode ? 'Edit Tujuan' : 'Tambah Tujuan Baru',
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.accentLight,
            AppColors.accentContainer,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
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
                  _isEditMode
                      ? 'Edit Tujuan Keuangan'
                      : 'Buat Tujuan Keuangan Baru',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isEditMode
                      ? 'Perbarui detail tujuan Anda'
                      : 'Tentukan target keuangan yang ingin Anda capai',
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

  Widget _buildForm(BuildContext context, ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nama Tujuan
          CoreTextField(
            controller: _nameController,
            label: 'Nama Tujuan',
            hint: 'Contoh: Beli Rumah, Liburan ke Bali',
            icon: Icons.flag,
            validator:
                (v) =>
                    (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
          ),

          const SizedBox(height: 20),

          // Jumlah Target
          CoreAmountInput(
            controller: _targetAmountController,
            label: 'Jumlah Target',
            hint: 'Masukkan jumlah target',
            validator:
                (v) =>
                    (v == null || v.isEmpty)
                        ? 'Jumlah tidak boleh kosong'
                        : null,
          ),

          const SizedBox(height: 20),

          // Target Tanggal
          CoreDatePicker(
            selectedDate: _targetDate,
            onDateSelected: (date) {
              setState(() => _targetDate = date);
            },
            onClear: () {
              setState(() => _targetDate = null);
            },
            label: 'Target Tanggal Tercapai',
            hint: 'Pilih tanggal target',
            firstDate: DateTime.now(),
            errorText:
                _targetDate == null ? 'Tanggal tidak boleh kosong' : null,
          ),

          const SizedBox(height: 32),

          // Submit Button
          CoreLoadingButton(
            onPressed: _submitForm,
            text: _isEditMode ? 'UPDATE TUJUAN' : 'SIMPAN TUJUAN',
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
