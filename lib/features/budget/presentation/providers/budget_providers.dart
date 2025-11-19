import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final budgetsForMonthProvider = StreamProvider.autoDispose
    .family<List<BudgetModel>, ({int year, int month})>((ref, date) {
      final budgetRepository = ref.watch(budgetRepositoryProvider);
      return budgetRepository
          .getBudgetsForMonth(date.month, date.year)
          .handleError((error, stackTrace) {
            return <BudgetModel>[];
          });
    });

final budgetControllerProvider =
    StateNotifierProvider.autoDispose<BudgetController, AsyncValue<void>>((
      ref,
    ) {
      return BudgetController(
        budgetRepository: ref.watch(budgetRepositoryProvider),
        ref: ref,
      );
    });

// Provider untuk budget warnings
final budgetWarningsProvider = Provider<List<BudgetWarning>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final budgetsAsync = ref.watch(
    budgetsForMonthProvider((
      year: selectedDate.year,
      month: selectedDate.month,
    )),
  );
  final transactionsAsync = ref.watch(transactionsStreamProvider);

  return budgetsAsync.when(
    data: (budgets) {
      return transactionsAsync.when(
        data: (transactions) {
          final warnings = <BudgetWarning>[];
          final currentMonth = DateTime(selectedDate.year, selectedDate.month);

          for (final budget in budgets) {
            if (budget.amount <= 0) continue;

            // Calculate spending for this category in current month
            final monthlyTransactions =
                transactions.where((t) {
                  final txnDate = t.date;
                  final txnMonth = DateTime(txnDate.year, txnDate.month);
                  return txnMonth.isAtSameMomentAs(currentMonth) &&
                      t.category == budget.categoryName &&
                      t.type == TransactionType.expense;
                }).toList();

            final totalSpent = monthlyTransactions.fold<double>(
              0.0,
              (sum, t) => sum + t.amount,
            );

            final percentageUsed = totalSpent / budget.amount;

            // Add warning if budget is 80% used or exceeded
            if (percentageUsed >= 0.8) {
              warnings.add(
                BudgetWarning(
                  categoryName: budget.categoryName,
                  amount: totalSpent,
                  budgetAmount: budget.amount,
                  percentageUsed: percentageUsed,
                  isExceeded: percentageUsed >= 1.0,
                ),
              );
            }
          }

          return warnings;
        },
        loading: () => <BudgetWarning>[],
        error: (_, __) => <BudgetWarning>[],
      );
    },
    loading: () => <BudgetWarning>[],
    error: (_, __) => <BudgetWarning>[],
  );
});

// Model untuk budget warning
class BudgetWarning {
  final String categoryName;
  final double amount;
  final double budgetAmount;
  final double percentageUsed;
  final bool isExceeded;

  BudgetWarning({
    required this.categoryName,
    required this.amount,
    required this.budgetAmount,
    required this.percentageUsed,
    required this.isExceeded,
  });
}

class BudgetController extends BaseController {
  final BudgetRepository _budgetRepository;

  BudgetController({
    required BudgetRepository budgetRepository,
    required super.ref,
  }) : _budgetRepository = budgetRepository;

  Future<void> saveOrUpdateBudget(BudgetModel budget) async {
    await executeWithLoading(
      () => _budgetRepository.saveOrUpdateBudget(budget),
      providersToInvalidate: [
        budgetsForMonthProvider((year: budget.year, month: budget.month)),
      ],
    );
  }

  Future<void> saveMultipleBudgets(List<BudgetModel> budgets) async {
    await executeWithLoading(
      () async {
        // Kita panggil saveOrUpdateBudget untuk setiap item
        for (final budget in budgets) {
          await _budgetRepository.saveOrUpdateBudget(budget);
        }
      },
      providersToInvalidate:
          budgets.isNotEmpty
              ? [
                budgetsForMonthProvider((
                  year: budgets.first.year,
                  month: budgets.first.month,
                )),
              ]
              : [],
    );
  }
}
