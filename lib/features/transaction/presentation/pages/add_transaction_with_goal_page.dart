import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/async_value_helper.dart';
import '../../../../core/utils/form_submission_helper.dart';
import '../../../../core/utils/user_helper.dart';
import '../../../../core/widgets/widgets.dart';

import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../../../goals/data/models/goal_model.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../goals/application/goal_progress_service.dart';

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
                            loading: () => const CoreLoadingState(size: 20),
                            error: (error, stack) => Text('Error: $error'),
                            data: (goals) => _buildGoalSelector(goals, theme),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Amount Input
                        CoreAmountInput(
                          controller: _amountController,
                          label: 'Jumlah',
                          hint: 'Masukkan jumlah',
                          primaryColor: _transactionColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan jumlah';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Description Input
                        CoreTextField(
                          controller: _descriptionController,
                          label: 'Deskripsi',
                          hint: 'Deskripsi transaksi (opsional)',
                          icon: Icons.description_outlined,
                          primaryColor: _transactionColor,
                        ),
                        const SizedBox(height: 24),

                        // Date Input
                        CoreDatePicker(
                          selectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                              _dateController.text = DateFormat(
                                'dd MMMM yyyy',
                                'id_ID',
                              ).format(date);
                            });
                          },
                          label: 'Tanggal',
                          hint: 'Pilih tanggal',
                          primaryColor: _transactionColor,
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        CoreLoadingButton(
                          onPressed: _submitTransaction,
                          text:
                              widget.transactionType == TransactionType.income
                                  ? 'TAMBAH PEMASUKAN'
                                  : 'TAMBAH PENGELUARAN',
                          isLoading:
                              ref
                                  .watch(transactionControllerProvider)
                                  .isLoading,
                          gradientColors: [
                            _transactionColor,
                            _transactionColor,
                          ],
                        ),
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

    return CoreDropdown<String>(
      value: _selectedGoalId,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedGoalId = value;
            _selectedGoalName =
                activeGoals.firstWhere((g) => g.id == value).name;
          });
        }
      },
      label: 'Pilih Goal',
      hint: 'Pilih goal yang terkait',
      primaryColor: _transactionColor,
      items:
          activeGoals.map((goal) {
            return DropdownMenuItem(value: goal.id, child: Text(goal.name));
          }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih goal yang terkait';
        }
        return null;
      },
    );
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGoalId == null) {
      CoreSnackbar.showWarning(context, 'Pilih goal yang terkait');
      return;
    }

    final userId = UserHelper.requireUserId(ref, context);
    if (userId == null) return;

    try {
      // Remove currency formatting and parse amount correctly
      final amount = FormSubmissionHelper.parseAmount(_amountController.text);
      final description =
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Transaksi ${widget.transactionType == TransactionType.income ? 'pemasukan' : 'pengeluaran'} untuk goal';

      // Create transaction
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
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

      if (!mounted) return;
      final state = ref.read(transactionControllerProvider);
      AsyncValueHelper.handleFormResult(
        context: context,
        state: state,
        successMessage:
            'Transaksi berhasil ditambahkan ke goal "${_selectedGoalName ?? "Unknown"}"',
        onSuccess: () async {
          // Update goal progress
          if (_selectedGoalId != null) {
            await ref
                .read(goalProgressServiceProvider)
                .updateGoalProgress(_selectedGoalId!);

            // Invalidate providers to trigger UI refresh
            _invalidateProviders();
          }

          // Navigate back
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      CoreSnackbar.showError(context, 'Gagal menambahkan transaksi: $e');
    }
  }
}
