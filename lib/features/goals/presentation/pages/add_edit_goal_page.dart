import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_decorations.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/async_value_helper.dart';
import '../../../../core/utils/form_submission_helper.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/user_helper.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/gradient_header_card.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/loading_action_button.dart';
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
  bool get _isLoading => ref.watch(goalControllerProvider).isLoading;

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
    if (!_formKey.currentState!.validate()) return;

    final userId = UserHelper.requireUserId(ref, context);
    if (userId == null) return;

    final targetAmount = FormSubmissionHelper.parseAmount(
      _targetAmountController.text,
    );

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
      if (_isEditMode) {
        await controller.updateGoal(goalData);
      } else {
        await controller.addGoal(goalData);
      }

      if (!mounted) return;
      final state = ref.read(goalControllerProvider);
      AsyncValueHelper.handleFormResult(
        context: context,
        state: state,
        successMessage:
            'Tujuan berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}',
      );
    } catch (e) {
      if (mounted) {
        CoreSnackbar.showError(context, 'Gagal: $e');
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
            CustomAppBar(
              title: _isEditMode ? 'Edit Tujuan' : 'Tambah Tujuan Baru',
            ),

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
                        child: CoreLoadingState(
                          size: 20,
                          color: AppColors.primary,
                          compact: true,
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

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return GradientHeaderCard(
      title: _isEditMode ? 'Edit Tujuan Keuangan' : 'Buat Tujuan Keuangan Baru',
      subtitle:
          _isEditMode
              ? 'Perbarui detail tujuan Anda'
              : 'Tentukan target keuangan yang ingin Anda capai',
      icon: _isEditMode ? Icons.edit : Icons.add,
      gradientColors: [
        AppColors.accent,
        AppColors.accentLight,
        AppColors.accent.withValues(alpha: 0.8),
      ],
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(20.0),
      decoration: AppDecorations.cardDecoration(
        context: context,
        borderRadius: 16.0,
      ),
      child: Form(
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
              validator: FormValidators.required(
                errorMessage: 'Nama tujuan tidak boleh kosong',
              ),
            ),

            AppSpacing.spaceLG,

            // Jumlah Target
            CoreAmountInput(
              controller: _targetAmountController,
              label: 'Jumlah Target',
              hint: 'Masukkan jumlah target',
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Jumlah target tidak boleh kosong';
                }
                final amount = FormSubmissionHelper.tryParseAmount(v);
                if (amount == null || amount <= 0) {
                  return 'Jumlah target harus lebih dari 0';
                }
                return null;
              },
            ),

            AppSpacing.spaceLG,

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
            LoadingActionButton(
              onPressed: _submitForm,
              isLoading: _isLoading,
              text: _isEditMode ? 'UPDATE TUJUAN' : 'SIMPAN TUJUAN',
              icon: _isEditMode ? Icons.save_outlined : Icons.add,
              height: 56,
            ),
          ],
        ),
      ),
    );
  }
}
