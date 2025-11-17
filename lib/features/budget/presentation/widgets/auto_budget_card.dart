import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../widgets/app_loading_indicator.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/models/budget_model.dart';
import '../providers/budget_providers.dart';
import '../providers/budget_suggestion_provider.dart';

class AutoBudgetCard extends ConsumerWidget {
  const AutoBudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(budgetSuggestionProvider);
    final theme = Theme.of(context);

    return suggestionAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (err, stack) => Card(child: Center(child: Text('Error: $err'))),
      data: (suggestions) {
        if (suggestions.isEmpty) {
          // Jangan tampilkan apa-apa jika tidak ada saran
          return const SizedBox.shrink();
        }

        return Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Saran Budget Otomatis',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berdasarkan rata-rata pengeluaran 3 bulan terakhir Anda.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withAlpha(26),
                  ),
                ),
                const Divider(height: 24),
                ...suggestions.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: theme.textTheme.bodyLarge),
                        Text(
                          AppFormatters.currency.format(entry.value),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _applyBudget(context, ref, suggestions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Terapkan Budget Ini'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyBudget(
    BuildContext context,
    WidgetRef ref,
    Map<String, double> suggestions,
  ) async {
    final selectedDate = ref.read(selectedDateProvider);

    // Buat daftar model budget dari saran
    final List<BudgetModel> budgetsToSave =
        suggestions.entries.map((entry) {
          return BudgetModel(
            userId: '', // akan diisi oleh controller
            categoryName: entry.key,
            amount: entry.value,
            month: selectedDate.month,
            year: selectedDate.year,
          );
        }).toList();

    // Panggil controller untuk menyimpan semua budget
    final success = await ref
        .read(budgetControllerProvider.notifier)
        .saveMultipleBudgets(budgetsToSave);

    if (!context.mounted) return;
    if (success) {
      CoreSnackbar.showSuccess(context, 'Budget otomatis berhasil diterapkan!');
    } else {
      CoreSnackbar.showError(context, 'Gagal menerapkan budget.');
    }
  }
}
