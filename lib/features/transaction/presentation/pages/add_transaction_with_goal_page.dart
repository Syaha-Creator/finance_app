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
import '../../../authentication/presentation/providers/auth_providers.dart';

class AddTransactionWithGoalPage extends ConsumerStatefulWidget {
  final TransactionType transactionType;
  final String? goalId;
  final String? goalName;

  const AddTransactionWithGoalPage({
    super.key,
    required this.transactionType,
    this.goalId,
    this.goalName,
  });

  @override
  ConsumerState<AddTransactionWithGoalPage> createState() =>
      _AddTransactionWithGoalPageState();
}

class _AddTransactionWithGoalPageState
    extends ConsumerState<AddTransactionWithGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedGoalId;
  String? _selectedGoalName;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Helper method to invalidate all related providers
  void _invalidateProviders() {
    ref.invalidate(goalsStreamProvider);
    ref.invalidate(goalControllerProvider);
    ref.invalidate(transactionsStreamProvider);
  }

  // Helper method to get appropriate color based on transaction type
  Color get _transactionColor =>
      widget.transactionType == TransactionType.income
          ? AppColors.income
          : AppColors.expense;

  // Helper method to build input decoration with transaction color
  InputDecoration _buildInputDecoration({
    required String hintText,
    String? prefixText,
    TextStyle? prefixStyle,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      prefixText: prefixText,
      prefixStyle: prefixStyle,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _transactionColor.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _transactionColor.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _transactionColor, width: 2),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }

  @override
  void initState() {
    super.initState();
    // Pre-select goal if provided
    if (widget.goalId != null && widget.goalName != null) {
      _selectedGoalId = widget.goalId;
      _selectedGoalName = widget.goalName;
    }
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
          widget.transactionType == TransactionType.income
              ? 'Tambah Pemasukan ke Goal'
              : 'Tambah Pengeluaran dari Goal',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor:
            widget.transactionType == TransactionType.income
                ? AppColors.income
                : AppColors.expense,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                widget.transactionType == TransactionType.income
                    ? [
                      AppColors.income,
                      AppColors.income.withValues(alpha: 0.8),
                    ]
                    : [
                      AppColors.expense,
                      AppColors.expense.withValues(alpha: 0.8),
                    ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    widget.transactionType == TransactionType.income
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.transactionType == TransactionType.income
                        ? 'Pemasukan ke Goal'
                        : 'Pengeluaran dari Goal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.transactionType == TransactionType.income
                          ? '+ Menambah Progress Goal'
                          : '- Mengurangi Progress Goal',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
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

                        // Submit Button
                        _buildSubmitButton(theme),
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
            border: Border.all(color: _transactionColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _transactionColor.withValues(alpha: 0.1),
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
          decoration: _buildInputDecoration(
            hintText: 'Masukkan jumlah',
            prefixText: 'Rp ',
            prefixStyle: TextStyle(
              color: _transactionColor,
              fontWeight: FontWeight.bold,
            ),
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
          decoration: _buildInputDecoration(
            hintText: 'Deskripsi transaksi (opsional)',
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
          decoration: _buildInputDecoration(
            hintText: 'Pilih tanggal',
            suffixIcon: Icon(Icons.calendar_today, color: _transactionColor),
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

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _transactionColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: _transactionColor.withValues(alpha: 0.3),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  'Simpan Transaksi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
      ),
    );
  }

  Future<void> _submitTransaction() async {
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
      // Remove currency formatting and parse amount correctly
      final numericValue = _amountController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      if (numericValue.isEmpty) {
        throw Exception('Jumlah tidak valid');
      }
      final amount = double.parse(numericValue);
      final description =
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Transaksi ${widget.transactionType == TransactionType.income ? 'pemasukan' : 'pengeluaran'} untuk goal';

      // Get current user ID
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create transaction
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        amount: amount,
        type: widget.transactionType,
        description: description,
        date: _selectedDate,
        category: 'Goal', // Default category for goal transactions
        account: 'Cash', // Default account
        goalId: _selectedGoalId,
      );

      // Add transaction using repository
      await ref
          .read(transactionControllerProvider.notifier)
          .addTransaction(transaction);

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
              '✅ Transaksi berhasil ditambahkan ke goal "${_selectedGoalName ?? "Unknown"}"',
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
            content: Text('❌ Gagal menambahkan transaksi: $e'),
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
