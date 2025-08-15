import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/models/budget_model.dart';
import '../providers/budget_providers.dart';

class BudgetCategoryItem extends ConsumerWidget {
  final BudgetModel budget;
  const BudgetCategoryItem({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(dashboardAnalysisProvider);
    final spentAmount = analysis.expenseByCategory[budget.categoryName] ?? 0.0;
    final progress =
        budget.amount > 0 ? (spentAmount / budget.amount).clamp(0.0, 1.0) : 0.0;
    final progressColor =
        progress < 0.5
            ? AppColors.income
            : (progress < 0.9 ? AppColors.warning : AppColors.expense);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSetBudgetDialog(context, ref, budget),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budget.categoryName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppFormatters.currency.format(budget.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.onSurface.withAlpha(30),
                color: progressColor,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terpakai: ${AppFormatters.currency.format(spentAmount)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    BudgetModel existingBudget,
  ) {
    final amountController = TextEditingController(
      text:
          existingBudget.amount > 0
              ? existingBudget.amount.toStringAsFixed(0)
              : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Anggaran untuk ${existingBudget.categoryName}'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Jumlah Anggaran',
                prefixText: 'Rp ',
              ),
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value.replaceAll('.', '')) == null) {
                  return 'Masukkan angka yang valid';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            Consumer(
              builder: (context, innerRef, child) {
                final isLoading = innerRef.watch(budgetControllerProvider);
                return ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              final navigator = Navigator.of(dialogContext);
                              final amount =
                                  double.tryParse(
                                    amountController.text.replaceAll('.', ''),
                                  ) ??
                                  0.0;
                              final newBudget = BudgetModel(
                                id: existingBudget.id,
                                userId: '',
                                categoryName: existingBudget.categoryName,
                                amount: amount,
                                month: existingBudget.month,
                                year: existingBudget.year,
                              );
                              final success = await innerRef
                                  .read(budgetControllerProvider.notifier)
                                  .saveOrUpdateBudget(newBudget);

                              if (success) {
                                navigator.pop();
                              } else {
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal menyimpan anggaran'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Simpan'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
