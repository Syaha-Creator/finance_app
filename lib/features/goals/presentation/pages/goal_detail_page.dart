import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/goal_model.dart';
import '../providers/goal_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

class GoalDetailPage extends ConsumerWidget {
  final GoalModel goal;
  const GoalDetailPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch goal data to auto-refresh
    final goalsAsync = ref.watch(goalsWithProgressProvider);
    final currentGoal = goalsAsync.value?.firstWhere(
      (g) => g.id == goal.id,
      orElse: () => goal,
    );

    final isCompleted = currentGoal?.status == GoalStatus.completed;

    // Check if goal should be auto-completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndAutoCompleteGoal(context, ref);
    });

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
                    // Goal Header
                    _buildGoalHeader(context, theme),

                    const SizedBox(height: 24),

                    // Progress Section
                    _buildProgressSection(context, theme),

                    const SizedBox(height: 24),

                    // Transactions Section
                    _buildTransactionsSection(context, theme),

                    // Bottom padding
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          !isCompleted
              ? FloatingActionButton.extended(
                onPressed: () {
                  _showAddTransactionDialog(context);
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Transaksi'),
              )
              : null,
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
              'Detail Tujuan',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Tombol edit
          if (goal.status != GoalStatus.completed)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () => context.push('/add-goal'),
                icon: Icon(Icons.edit, color: AppColors.primary, size: 20),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalHeader(BuildContext context, ThemeData theme) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  goal.status == GoalStatus.completed
                      ? Icons.check_circle
                      : Icons.flag,
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
                      goal.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration:
                            goal.status == GoalStatus.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      goal.status == GoalStatus.completed
                          ? 'Tujuan Telah Tercapai! 🎉'
                          : 'Target: ${DateFormat('dd MMMM yyyy', 'id_ID').format(goal.targetDate)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Amount information
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  context,
                  'Target',
                  goal.targetAmount,
                  Icons.flag,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAmountCard(
                  context,
                  'Terkumpul',
                  goal.currentAmount,
                  Icons.account_balance_wallet,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAmountCard(
                  context,
                  'Sisa',
                  goal.remainingAmount,
                  Icons.trending_up,
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppFormatters.currency.format(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, ThemeData theme) {
    return Container(
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Tujuan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${(goal.progressPercentage * 100).toInt()}%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: goal.progressPercentage,
            backgroundColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            color: AppColors.primary,
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 12),
          Text(
            '${AppFormatters.currency.format(goal.currentAmount)} dari ${AppFormatters.currency.format(goal.targetAmount)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // Auto-complete logic
  void _checkAndAutoCompleteGoal(BuildContext context, WidgetRef ref) {
    if (goal.progressPercentage >= 1.0 && goal.status != GoalStatus.completed) {
      // Show auto-complete dialog
      _showAutoCompleteDialog(context, ref);
    }
  }

  // Auto-complete dialog
  void _showAutoCompleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus memilih salah satu opsi
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.celebration,
                  color: AppColors.income,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text('🎉 Tujuan Telah Tercapai!'),
              ],
            ),
            content: Text(
              'Selamat! Tujuan "${goal.name}" telah mencapai target. '
              'Apakah Anda ingin menandainya sebagai selesai?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Mark later functionality - will be checked again when page is refreshed
                  CoreSnackbar.showInfo(context, 'Goal akan ditandai selesai nanti');
                },
                child: const Text('Nanti'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Mark as completed functionality
                  _markGoalAsCompleted(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.income,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ya, Tandai Selesai'),
              ),
            ],
          ),
    );
  }

  // Mark goal as completed
  void _markGoalAsCompleted(BuildContext context, WidgetRef ref) async {
    try {
      // Update goal status to completed
      final updatedGoal = goal.copyWith(status: GoalStatus.completed);
      await ref.read(goalControllerProvider.notifier).updateGoal(updatedGoal);

      if (!context.mounted) return;
      final state = ref.read(goalControllerProvider);
      state.when(
        data: (_) {
          // Show success message
          CoreSnackbar.showSuccess(
            context,
            '🎉 "${goal.name}" telah ditandai selesai!',
          );

          // Navigate back to goals page
          Navigator.of(context).pop();
        },
        loading: () {},
        error: (error, _) {
          CoreSnackbar.showError(
            context,
            'Gagal memperbarui tujuan: $error',
          );
        },
      );
    } catch (e) {
      // Show error message if update fails
      CoreSnackbar.showError(context, 'Gagal menandai goal selesai: $e');
    }
  }

  Widget _buildTransactionsSection(BuildContext context, ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final transactionsAsync = ref.watch(transactionsStreamProvider);

        return Container(
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Terkait',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  transactionsAsync.when(
                    loading:
                        () => Text(
                          '...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    error:
                        (_, __) => Text(
                          'Error',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                    data: (transactions) {
                      final goalTransactions =
                          transactions
                              .where((t) => t.goalId == goal.id)
                              .toList();
                      return Text(
                        '${goalTransactions.length} transaksi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Transactions list or empty state
              transactionsAsync.when(
                loading:
                    () => const Center(
                      child: CoreLoadingState(
                        size: 20,
                        color: AppColors.primary,
                        compact: true,
                      ),
                    ),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (transactions) {
                  final goalTransactions =
                      transactions.where((t) => t.goalId == goal.id).toList();

                  if (goalTransactions.isEmpty) {
                    return _buildEmptyTransactions(context, theme);
                  }

                  return _buildTransactionsList(
                    context,
                    theme,
                    goalTransactions,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    ThemeData theme,
    List<TransactionModel> transactions,
  ) {
    return Column(
      children:
          transactions.map((transaction) {
            return InkWell(
              onTap: () => _navigateToEditTransaction(context, transaction),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Transaction type icon with better color distinction
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            transaction.type == TransactionType.income
                                ? AppColors.income.withValues(alpha: 0.15)
                                : AppColors.expense.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              transaction.type == TransactionType.income
                                  ? AppColors.income.withValues(alpha: 0.3)
                                  : AppColors.expense.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        transaction.type == TransactionType.income
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color:
                            transaction.type == TransactionType.income
                                ? AppColors.income
                                : AppColors.expense,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Transaction details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'dd MMM yyyy',
                              'id_ID',
                            ).format(transaction.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Text(
                      '${transaction.type == TransactionType.income ? '+' : '-'}${AppFormatters.currency.format(transaction.amount)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            transaction.type == TransactionType.income
                                ? AppColors.income
                                : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan transaksi untuk melacak progress tujuan Anda',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddTransactionDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Transaksi Pertama'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Tambah Transaksi ke "${goal.name}"'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih jenis transaksi yang ingin ditambahkan ke goal ini:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _buildTransactionOption(
                  context,
                  'Pemasukan ke Goal',
                  'Menambah progress goal (gaji, bonus, dll)',
                  Icons.trending_up,
                  AppColors.income,
                  () {
                    Navigator.of(dialogContext).pop();
                    _navigateToAddTransaction(context, TransactionType.income);
                  },
                ),
                const SizedBox(height: 8),
                _buildTransactionOption(
                  context,
                  'Pengeluaran dari Goal',
                  'Mengurangi progress goal (belanja barang untuk tujuan)',
                  Icons.trending_down,
                  AppColors.expense,
                  () {
                    Navigator.of(dialogContext).pop();
                    _navigateToAddTransaction(context, TransactionType.expense);
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transaksi goal akan otomatis muncul di halaman transaksi utama',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
            ],
          ),
    );
  }

  Widget _buildTransactionOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToAddTransaction(BuildContext context, TransactionType type) {
    // Navigate to add transaction page with goal pre-selected
    context.push(
      '/add-transaction-with-goal',
      extra: {'transactionType': type, 'goalId': goal.id, 'goalName': goal.name},
    );
  }

  void _navigateToEditTransaction(
    BuildContext context,
    TransactionModel transaction,
  ) {
    context.push(
      '/edit-transaction-with-goal',
      extra: {'transaction': transaction, 'goalId': goal.id, 'goalName': goal.name},
    );
  }
}
