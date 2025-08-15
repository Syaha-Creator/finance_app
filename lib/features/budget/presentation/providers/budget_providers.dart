import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
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
      return budgetRepository.getBudgetsForMonth(date.month, date.year);
    });

final budgetControllerProvider =
    StateNotifierProvider.autoDispose<BudgetController, bool>((ref) {
      return BudgetController(
        budgetRepository: ref.watch(budgetRepositoryProvider),
        ref: ref,
      );
    });

class BudgetController extends StateNotifier<bool> {
  final BudgetRepository _budgetRepository;
  final Ref _ref;

  BudgetController({
    required BudgetRepository budgetRepository,
    required Ref ref,
  }) : _budgetRepository = budgetRepository,
       _ref = ref,
       super(false);

  Future<bool> saveOrUpdateBudget(BudgetModel budget) async {
    state = true;
    try {
      await _budgetRepository.saveOrUpdateBudget(budget);
      _ref.invalidate(
        budgetsForMonthProvider((year: budget.year, month: budget.month)),
      );
      state = false;
      return true;
    } catch (e) {
      state = false;
      return false;
    }
  }

  Future<bool> saveMultipleBudgets(List<BudgetModel> budgets) async {
    state = true;
    try {
      // Kita panggil saveOrUpdateBudget untuk setiap item
      for (final budget in budgets) {
        await _budgetRepository.saveOrUpdateBudget(budget);
      }
      if (!mounted) return false;
      // Invalidate provider setelah semua selesai
      if (budgets.isNotEmpty) {
        _ref.invalidate(
          budgetsForMonthProvider((
            year: budgets.first.year,
            month: budgets.first.month,
          )),
        );
      }
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }
}
