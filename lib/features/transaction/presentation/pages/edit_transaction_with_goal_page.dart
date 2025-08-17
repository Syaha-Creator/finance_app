import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../../../goals/data/models/goal_model.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../goals/application/goal_progress_service.dart';

class EditTransactionWithGoalPage extends ConsumerStatefulWidget {
  final TransactionModel transaction;
  final String? goalId;
  final String? goalName;

  const EditTransactionWithGoalPage({
    super.key,
    required this.transaction,
    this.goalId,
    this.goalName,
  });

  @override
  ConsumerState<EditTransactionWithGoalPage> createState() =>
      _EditTransactionWithGoalPageState();
}

class _EditTransactionWithGoalPageState
    extends ConsumerState<EditTransactionWithGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedGoalId;
  String? _selectedGoalName;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.income;
  bool _isLoading = false;

  // Helper method to invalidate all related providers
  void _invalidateProviders() {
    ref.invalidate(goalsStreamProvider);
    ref.invalidate(goalControllerProvider);
    ref.invalidate(transactionsStreamProvider);
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing transaction data
    _amountController.text = AppFormatters.currency
        .format(widget.transaction.amount)
        .replaceFirst('Rp ', '');
    _descriptionController.text = widget.transaction.description;
    _selectedDate = widget.transaction.date;
    _selectedType = widget.transaction.type;
    _selectedGoalId = widget.goalId ?? widget.transaction.goalId;
    _selectedGoalName = widget.goalName;

    _dateController.text = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Transaksi Goal',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.edit, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Edit Transaksi Goal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.goalName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Goal: ${widget.goalName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Form Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Transaction Type Selector
                        _buildTransactionTypeSelector(theme),
                        const SizedBox(height: 24),

                        // Goal Selection (if not pre-selected)
                        if (widget.goalId == null) ...[
                          goalsAsync.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) => Text('Error: $error'),
                            data: (goals) => _buildGoalSelector(goals, theme),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Amount Input
                        _buildAmountInput(theme),
                        const SizedBox(height: 24),

                        // Description Input
                        _buildDescriptionInput(theme),
                        const SizedBox(height: 24),

                        // Date Input
                        _buildDateInput(theme),
                        const SizedBox(height: 32),

                        // Action Buttons
                        _buildActionButtons(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Transaksi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                context,
                theme,
                TransactionType.income,
                'Pemasukan',
                Icons.trending_up,
                AppColors.income,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                context,
                theme,
                TransactionType.expense,
                'Pengeluaran',
                Icons.trending_down,
                AppColors.expense,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    BuildContext context,
    ThemeData theme,
    TransactionType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.15)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector(List<GoalModel> goals, ThemeData theme) {
    final activeGoals =
        goals.where((g) => g.status != GoalStatus.completed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Goal',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedGoalId,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Pilih goal yang terkait',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            items:
                activeGoals.map((goal) {
                  return DropdownMenuItem(
                    value: goal.id,
                    child: Text(
                      goal.name,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGoalId = value;
                _selectedGoalName =
                    activeGoals.firstWhere((g) => g.id == value).name;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih goal yang terkait';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jumlah',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan jumlah',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixText: 'Rp ',
            prefixStyle: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            // Format currency as user types
            if (value.isNotEmpty) {
              final numericValue = value.replaceAll(RegExp(r'[^\d]'), '');
              if (numericValue.isNotEmpty) {
                final doubleValue = double.parse(numericValue);
                final formattedValue = AppFormatters.currency.format(
                  doubleValue,
                );
                // Remove "Rp " prefix and update controller
                final displayValue = formattedValue.replaceFirst('Rp ', '');
                if (displayValue != value) {
                  _amountController.value = TextEditingValue(
                    text: displayValue,
                    selection: TextSelection.collapsed(
                      offset: displayValue.length,
                    ),
                  );
                }
              }
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Masukkan jumlah';
            }
            // Remove formatting for validation
            final numericValue = value.replaceAll(RegExp(r'[^\d]'), '');
            if (numericValue.isEmpty) {
              return 'Masukkan angka yang valid';
            }
            final doubleValue = double.tryParse(numericValue);
            if (doubleValue == null || doubleValue <= 0) {
              return 'Jumlah harus lebih dari 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Deskripsi transaksi (opsional)',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Pilih tanggal',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
                _dateController.text = DateFormat(
                  'dd MMMM yyyy',
                  'id_ID',
                ).format(date);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        // Delete Button
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _deleteTransaction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.expense,
                side: BorderSide(color: AppColors.expense),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Update Button
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Update',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih goal yang terkait'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(
        _amountController.text.replaceAll(RegExp(r'[^\d]'), ''),
      );
      final description =
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Transaksi ${_selectedType == TransactionType.income ? 'pemasukan' : 'pengeluaran'} untuk goal';

      // Update transaction
      final updatedTransaction = widget.transaction.copyWith(
        amount: amount,
        type: _selectedType,
        description: description,
        date: _selectedDate,
        goalId: _selectedGoalId,
      );

      // Update transaction in database
      await ref
          .read(transactionRepositoryProvider)
          .updateTransaction(updatedTransaction);

      // Update goal progress
      if (_selectedGoalId != null) {
        await ref
            .read(goalProgressServiceProvider)
            .updateGoalProgress(_selectedGoalId!);

        // Invalidate providers to trigger UI refresh
        _invalidateProviders();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Transaksi berhasil diupdate untuk goal "${_selectedGoalName ?? "Unknown"}"',
            ),
            backgroundColor: AppColors.income,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengupdate transaksi: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTransaction() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus transaksi ini? '
              'Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.expense,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    setState(() => _isLoading = true);

    try {
      // Delete transaction
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(widget.transaction.id!);

      // Update goal progress
      if (_selectedGoalId != null) {
        await ref
            .read(goalProgressServiceProvider)
            .updateGoalProgress(_selectedGoalId!);

        // Invalidate providers to trigger UI refresh
        _invalidateProviders();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Transaksi berhasil dihapus'),
            backgroundColor: AppColors.income,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menghapus transaksi: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
