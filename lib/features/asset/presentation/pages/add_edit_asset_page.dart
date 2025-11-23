import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/async_value_helper.dart';
import '../../../../core/utils/form_submission_helper.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/user_helper.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/gradient_header_card.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/loading_action_button.dart';
import '../../data/models/asset_model.dart';
import '../providers/asset_provider.dart';

class AddEditAssetPage extends ConsumerStatefulWidget {
  final AssetModel? asset;
  const AddEditAssetPage({super.key, this.asset});

  @override
  ConsumerState<AddEditAssetPage> createState() => _AddEditAssetPageState();
}

class _AddEditAssetPageState extends ConsumerState<AddEditAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  AssetType? _selectedType;

  bool get _isEditMode => widget.asset != null;
  bool get _isLoading => ref.watch(assetNotifierProvider).isLoading;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final asset = widget.asset!;
      _nameController.text = asset.name;
      final formatter = NumberFormat('#,###', 'id_ID');
      _valueController.text = formatter.format(asset.value);
      _selectedType = asset.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = UserHelper.requireUserId(ref, context);
    if (userId == null) return;

    final value = FormSubmissionHelper.parseAmount(_valueController.text);

    if (_isEditMode) {
      final updatedAsset = widget.asset!.copyWith(
        name: _nameController.text,
        value: value,
        type: _selectedType,
      );
      await ref.read(assetNotifierProvider.notifier).updateAsset(updatedAsset);

      if (!mounted) return;
      final state = ref.read(assetNotifierProvider);
      AsyncValueHelper.handleFormResult(
        context: context,
        state: state,
        successMessage: 'Aset berhasil diperbarui',
        errorMessagePrefix: 'Gagal memperbarui aset',
      );
    } else {
      final newAsset = AssetModel(
        userId: userId,
        name: _nameController.text,
        type: _selectedType!,
        value: value,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );
      await ref.read(assetNotifierProvider.notifier).addAsset(newAsset);

      if (!mounted) return;
      final state = ref.read(assetNotifierProvider);
      AsyncValueHelper.handleFormResult(
        context: context,
        state: state,
        successMessage: 'Aset berhasil disimpan',
        errorMessagePrefix: 'Gagal menyimpan aset',
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
            CustomAppBar(title: _isEditMode ? 'Edit Aset' : 'Tambah Aset Baru'),

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
      title: _isEditMode ? 'Edit Aset' : 'Tambah Aset Baru',
      subtitle:
          _isEditMode
              ? 'Perbarui informasi aset Anda'
              : 'Catat aset baru untuk melacak kekayaan',
      icon: _isEditMode ? Icons.edit : Icons.add,
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(20.0),
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
            // Asset Type Dropdown
            CoreDropdown<AssetType>(
              value: _selectedType,
              onChanged: (newValue) => setState(() => _selectedType = newValue),
              label: 'Jenis Aset',
              hint: 'Pilih jenis aset',
              validator: (v) => v == null ? 'Pilih jenis aset' : null,
              items:
                  AssetType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(
                            _getAssetTypeIcon(type),
                            color: _getAssetTypeColor(type),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(assetTypeToString(type)),
                        ],
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),

            // Asset Name Field
            CoreTextField(
              controller: _nameController,
              label: 'Nama Aset',
              hint: 'Contoh: Tabungan BCA, Saham Telkom, dll',
              validator: FormValidators.required(
                errorMessage: 'Nama tidak boleh kosong',
              ),
            ),

            const SizedBox(height: 20),

            // Asset Value Field
            CoreAmountInput(
              controller: _valueController,
              label: 'Nilai / Saldo',
              hint: 'Masukkan nilai aset',
              validator: FormValidators.amount(
                errorMessage: 'Nilai tidak boleh kosong',
                zeroMessage: 'Nilai harus lebih dari 0',
              ),
            ),

            const SizedBox(height: 28),

            // Submit Button
            LoadingActionButton(
              onPressed: _submitForm,
              isLoading: _isLoading,
              text: _isEditMode ? 'PERBARUI ASET' : 'SIMPAN ASET',
              icon: _isEditMode ? Icons.save_outlined : Icons.add,
              height: 56,
            ),
          ],
        ),
      ),
    );
  }

  Color _getAssetTypeColor(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return AppColors.success;
      case AssetType.bankAccount:
        return AppColors.primary;
      case AssetType.eWallet:
        return AppColors.secondary;
      case AssetType.stocks:
        return AppColors.accent;
      case AssetType.mutualFunds:
        return AppColors.info;
      case AssetType.crypto:
        return AppColors.warning;
      case AssetType.property:
        return AppColors.primaryDark;
      case AssetType.vehicle:
        return AppColors.secondary;
      case AssetType.other:
        return AppColors.lightTextSecondary;
    }
  }

  IconData _getAssetTypeIcon(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return Icons.attach_money;
      case AssetType.bankAccount:
        return Icons.account_balance;
      case AssetType.eWallet:
        return Icons.account_balance_wallet;
      case AssetType.stocks:
        return Icons.trending_up;
      case AssetType.mutualFunds:
        return Icons.pie_chart;
      case AssetType.crypto:
        return Icons.currency_bitcoin;
      case AssetType.property:
        return Icons.home;
      case AssetType.vehicle:
        return Icons.directions_car;
      case AssetType.other:
        return Icons.category;
    }
  }
}
