import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import '../../data/models/debt_receivable_model.dart';
import '../providers/debt_provider.dart';

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
  bool get _isLoading => ref.watch(debtNotifierProvider).isLoading;

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
    if (!_formKey.currentState!.validate()) return;

    final userId = UserHelper.requireUserId(ref, context);
    if (userId == null) return;

    final amount = FormSubmissionHelper.parseAmount(_amountController.text);

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

        await ref
            .read(debtNotifierProvider.notifier)
            .updateDebt(updatedDebt);

        if (!mounted) return;
        final state = ref.read(debtNotifierProvider);
        AsyncValueHelper.handleFormResult(
          context: context,
          state: state,
          successMessage: 'Catatan berhasil diperbarui',
          errorMessagePrefix: 'Gagal memperbarui catatan',
        );
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

        await ref
            .read(debtNotifierProvider.notifier)
            .addDebt(newDebt);

        if (!mounted) return;
        final state = ref.read(debtNotifierProvider);
        AsyncValueHelper.handleFormResult(
          context: context,
          state: state,
          successMessage: 'Catatan berhasil disimpan',
          errorMessagePrefix: 'Gagal menyimpan catatan',
        );
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
              title: _isEditMode ? 'Edit Catatan' : 'Tambah Catatan Utang/Piutang',
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
      title: _isEditMode ? 'Edit Catatan' : 'Tambah Catatan Baru',
      subtitle: _isEditMode
          ? 'Perbarui informasi utang/piutang Anda'
          : 'Catat utang atau piutang baru untuk melacak keuangan',
      icon: _isEditMode ? Icons.edit : Icons.add,
      gradientColors: [
        AppColors.secondary,
        AppColors.secondary.withValues(alpha: 0.8),
        AppColors.secondary.withValues(alpha: 0.6),
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
            // Type selector
            _buildTypeSelector(context, theme),

            AppSpacing.spaceLG,

            // Person Name Field
            CoreTextField(
              controller: _personNameController,
              label: 'Nama Orang',
              hint: 'Masukkan nama orang yang berutang/piutang',
              icon: Icons.person,
              validator: FormValidators.required(
                errorMessage: 'Nama tidak boleh kosong',
              ),
            ),

            AppSpacing.spaceLG,

            // Amount Field
            CoreAmountInput(
              controller: _amountController,
              label: 'Jumlah',
              hint: 'Masukkan jumlah utang/piutang',
              validator: FormValidators.amount(
                errorMessage: 'Jumlah tidak boleh kosong',
                zeroMessage: 'Jumlah harus lebih dari 0',
              ),
            ),

            AppSpacing.spaceLG,

            // Description Field
            CoreTextField(
              controller: _descriptionController,
              label: 'Keterangan',
              hint: 'Tambahkan keterangan atau alasan',
              icon: Icons.description,
              maxLines: 3,
              validator:
                  (v) =>
                      (v == null || v.isEmpty)
                          ? 'Keterangan tidak boleh kosong'
                          : null,
            ),

            AppSpacing.spaceLG,

            // Due Date Field
            CoreDatePicker(
              selectedDate: _dueDate,
              onDateSelected: (date) {
                setState(() => _dueDate = date);
              },
              onClear: () {
                setState(() => _dueDate = null);
              },
              label: 'Tanggal Jatuh Tempo (Opsional)',
              hint: 'Pilih tanggal jatuh tempo',
              firstDate: DateTime.now(),
            ),

            const SizedBox(height: 28),

            // Submit Button
            LoadingActionButton(
              onPressed: _submitForm,
              isLoading: _isLoading,
              text: _isEditMode ? 'PERBARUI CATATAN' : 'SIMPAN CATATAN',
              icon: _isEditMode ? Icons.save_outlined : Icons.add,
              height: 56,
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
        AppSpacing.spaceSM,
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
}
