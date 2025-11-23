import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/async_value_helper.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../core/utils/form_submission_helper.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/user_helper.dart';
import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/gradient_header_card.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/loading_action_button.dart';
import '../../data/models/investment_model.dart';
import '../providers/investment_provider.dart';

class AddEditInvestmentPage extends ConsumerStatefulWidget {
  final InvestmentModel? investment;

  const AddEditInvestmentPage({super.key, this.investment});

  @override
  ConsumerState<AddEditInvestmentPage> createState() =>
      _AddEditInvestmentPageState();
}

class _AddEditInvestmentPageState extends ConsumerState<AddEditInvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _averagePriceController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _notesController = TextEditingController();

  InvestmentType _selectedType = InvestmentType.stock;
  DateTime _selectedPurchaseDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.investment != null) {
      _loadInvestmentData();
    }
  }

  void _loadInvestmentData() {
    final investment = widget.investment!;
    _nameController.text = investment.name;
    _symbolController.text = investment.symbol;
    _quantityController.text = investment.quantity.toString();
    _averagePriceController.text = investment.averagePrice.toString();
    _currentPriceController.text = investment.currentPrice.toString();
    _notesController.text = investment.notes ?? '';
    _selectedType = investment.type;
    _selectedPurchaseDate = investment.purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _averagePriceController.dispose();
    _currentPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.investment != null;

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
              title: isEditing ? 'Edit Investasi' : 'Tambah Investasi',
              actions: [
                if (isEditing)
                  IconButton(
                    onPressed: _showDeleteDialog,
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                  ),
              ],
            ),

            // Form content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Header dengan gradient
                  SliverToBoxAdapter(
                    child: _buildHeader(context, theme, isEditing),
                  ),

                  // Form content
                  SliverToBoxAdapter(child: _buildForm(context, theme)),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isEditing) {
    return GradientHeaderCard(
      title: isEditing ? 'Edit Investasi' : 'Tambah Investasi Baru',
      subtitle:
          isEditing
              ? 'Perbarui detail investasi Anda'
              : 'Catat investasi baru untuk melacak portofolio',
      icon: isEditing ? Icons.edit : Icons.trending_up,
      gradientColors: [
        AppColors.primary,
        AppColors.primaryLight,
        AppColors.primary.withValues(alpha: 0.8),
      ],
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Basic Information
          SectionCard(
            title: 'Informasi Dasar',
            icon: Icons.info_outline,
            children: [
              CoreTextField(
                controller: _nameController,
                label: 'Nama Investasi',
                hint: 'Contoh: Saham Bank BCA',
                icon: Icons.trending_up,
                validator: FormValidators.required(
                  errorMessage: 'Nama investasi harus diisi',
                ),
              ),

              AppSpacing.spaceMD,

              CoreTextField(
                controller: _symbolController,
                label: 'Symbol/Ticker',
                hint: 'Contoh: BBCA',
                icon: Icons.tag,
                validator: FormValidators.required(
                  errorMessage: 'Symbol harus diisi',
                ),
              ),

              AppSpacing.spaceMD,

              CoreDropdown<InvestmentType>(
                value: _selectedType,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
                label: 'Jenis Investasi',
                icon: Icons.category,
                items:
                    InvestmentType.values.map((type) {
                      String label;
                      switch (type) {
                        case InvestmentType.stock:
                          label = 'Saham';
                          break;
                        case InvestmentType.mutualFund:
                          label = 'Reksadana';
                          break;
                        case InvestmentType.crypto:
                          label = 'Cryptocurrency';
                          break;
                        case InvestmentType.bond:
                          label = 'Obligasi';
                          break;
                        case InvestmentType.gold:
                          label = 'Emas';
                          break;
                        case InvestmentType.property:
                          label = 'Properti';
                          break;
                        case InvestmentType.other:
                          label = 'Lainnya';
                          break;
                      }
                      return DropdownMenuItem<InvestmentType>(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _getInvestmentTypeIcon(type),
                              color: _getInvestmentTypeColor(type),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(label),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),

          // Investment Details
          SectionCard(
            title: 'Detail Investasi',
            icon: Icons.analytics_outlined,
            children: [
              CoreTextField(
                controller: _quantityController,
                label: 'Jumlah Unit',
                hint: '0',
                icon: Icons.analytics_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandInputFormatter()],
                validator: FormValidators.positiveNumber(
                  errorMessage: 'Jumlah unit harus diisi',
                  zeroMessage: 'Jumlah unit harus lebih dari 0',
                ),
              ),

              AppSpacing.spaceMD,

              CoreAmountInput(
                controller: _averagePriceController,
                label: 'Harga Rata-rata per Unit',
                hint: '0',
                validator: FormValidators.amount(
                  errorMessage: 'Harga rata-rata harus diisi',
                  zeroMessage: 'Harga rata-rata harus lebih dari 0',
                ),
              ),

              AppSpacing.spaceMD,

              CoreAmountInput(
                controller: _currentPriceController,
                label: 'Harga Sekarang per Unit',
                hint: '0',
                validator: FormValidators.amount(
                  errorMessage: 'Harga sekarang harus diisi',
                  zeroMessage: 'Harga sekarang harus lebih dari 0',
                ),
              ),

              AppSpacing.spaceMD,

              CoreDatePicker(
                selectedDate: _selectedPurchaseDate,
                onDateSelected: (date) {
                  setState(() => _selectedPurchaseDate = date);
                },
                label: 'Tanggal Pembelian',
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              ),
            ],
          ),

          // Notes
          SectionCard(
            title: 'Catatan',
            icon: Icons.note_outlined,
            children: [
              CoreTextField(
                controller: _notesController,
                label: 'Catatan (Opsional)',
                hint: 'Catatan tambahan tentang investasi ini',
                icon: Icons.note_outlined,
                maxLines: 3,
              ),
            ],
          ),

          AppSpacing.spaceLG,

          // Save Button
          Padding(
            padding: AppSpacing.paddingHorizontal,
            child: LoadingActionButton(
              onPressed: _saveInvestment,
              isLoading: false,
              text:
                  widget.investment != null
                      ? 'UPDATE INVESTASI'
                      : 'SIMPAN INVESTASI',
              icon: widget.investment != null ? Icons.save_outlined : Icons.add,
              height: 56,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = UserHelper.requireUserId(ref, context);
    if (userId == null) return;

    final quantity = FormSubmissionHelper.parseAmount(_quantityController.text);
    final averagePrice = FormSubmissionHelper.parseAmount(
      _averagePriceController.text,
    );
    final currentPrice = FormSubmissionHelper.parseAmount(
      _currentPriceController.text,
    );
    final totalInvested = quantity * averagePrice;
    final currentValue = quantity * currentPrice;
    final profitLoss = currentValue - totalInvested;
    final profitLossPercentage =
        totalInvested > 0 ? (profitLoss / totalInvested) * 100 : 0.0;

    final investment = InvestmentModel(
      id: widget.investment?.id ?? '',
      userId: userId,
      name: _nameController.text.trim(),
      symbol: _symbolController.text.trim().toUpperCase(),
      type: _selectedType,
      quantity: quantity,
      averagePrice: averagePrice,
      currentPrice: currentPrice,
      totalInvested: totalInvested,
      currentValue: currentValue,
      profitLoss: profitLoss,
      profitLossPercentage: profitLossPercentage,
      status: InvestmentStatus.active,
      purchaseDate: _selectedPurchaseDate,
      sellDate: null,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      createdAt: widget.investment?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final controller = ref.read(investmentNotifierProvider.notifier);
    if (widget.investment != null) {
      await controller.updateInvestment(investment);
    } else {
      await controller.addInvestment(investment);
    }

    if (!mounted) return;
    final state = ref.read(investmentNotifierProvider);
    AsyncValueHelper.handleFormResult(
      context: context,
      state: state,
      successMessage:
          'Investasi berhasil ${widget.investment != null ? 'diperbarui' : 'disimpan'}',
      errorMessagePrefix:
          'Gagal ${widget.investment != null ? 'memperbarui' : 'menyimpan'} investasi',
    );
  }

  void _showDeleteDialog() {
    DialogHelper.showDeleteConfirmation(
      context: context,
      title: 'Hapus Investasi',
      itemName: widget.investment!.name,
      onConfirm: () {
        ref
            .read(investmentNotifierProvider.notifier)
            .deleteInvestment(widget.investment!.id);
        Navigator.pop(context);
      },
    );
  }

  Color _getInvestmentTypeColor(InvestmentType type) {
    switch (type) {
      case InvestmentType.stock:
        return AppColors.primary;
      case InvestmentType.mutualFund:
        return AppColors.accent;
      case InvestmentType.crypto:
        return AppColors.warning;
      case InvestmentType.bond:
        return AppColors.success;
      case InvestmentType.gold:
        return Colors.amber;
      case InvestmentType.property:
        return Colors.brown;
      case InvestmentType.other:
        return Colors.grey;
    }
  }

  IconData _getInvestmentTypeIcon(InvestmentType type) {
    switch (type) {
      case InvestmentType.stock:
        return Icons.trending_up;
      case InvestmentType.mutualFund:
        return Icons.pie_chart;
      case InvestmentType.crypto:
        return Icons.currency_bitcoin;
      case InvestmentType.bond:
        return Icons.account_balance;
      case InvestmentType.gold:
        return Icons.monetization_on;
      case InvestmentType.property:
        return Icons.home;
      case InvestmentType.other:
        return Icons.attach_money;
    }
  }
}
