import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../data/models/goal_model.dart';
import '../../data/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Provider untuk goal progress yang dihitung real-time dari transaksi
final goalsWithProgressProvider = StreamProvider.autoDispose<List<GoalModel>>((
  ref,
) {
  final goalsStream = ref.watch(goalRepositoryProvider).getGoalsStream();
  final transactionsStream = ref.watch(transactionsStreamProvider);

  return goalsStream.asyncMap((goals) async {
    // Gunakan when untuk mengakses data dari AsyncValue
    final transactions = transactionsStream.when(
      data: (data) => data,
      loading: () => <TransactionModel>[],
      error: (error, stack) => <TransactionModel>[],
    );

    // Update progress untuk setiap goal berdasarkan transaksi
    final updatedGoals = <GoalModel>[];

    for (final goal in goals) {
      final goalTransactions =
          transactions.where((t) => t.goalId == goal.id).toList();

      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in goalTransactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpense += transaction.amount;
        }
      }

      // Hitung current amount (income - expense)
      final currentAmount = totalIncome - totalExpense;

      // Update status berdasarkan progress
      GoalStatus newStatus = goal.status;
      if (currentAmount >= goal.targetAmount &&
          goal.status != GoalStatus.completed) {
        newStatus = GoalStatus.completed;
      } else if (currentAmount < goal.targetAmount &&
          goal.status == GoalStatus.completed) {
        newStatus = GoalStatus.inProgress;
      }

      // Buat goal yang sudah di-update
      final updatedGoal = goal.copyWith(
        currentAmount: currentAmount,
        status: newStatus,
      );

      updatedGoals.add(updatedGoal);
    }

    return updatedGoals;
  });
});

// Provider legacy untuk backward compatibility
final goalsStreamProvider = StreamProvider.autoDispose<List<GoalModel>>((ref) {
  return ref.watch(goalRepositoryProvider).getGoalsStream();
});

final goalControllerProvider =
    StateNotifierProvider.autoDispose<GoalController, bool>((ref) {
      return GoalController(
        goalRepository: ref.watch(goalRepositoryProvider),
        ref: ref,
      );
    });

class GoalController extends StateNotifier<bool> {
  final GoalRepository _goalRepository;
  final Ref _ref;

  GoalController({required GoalRepository goalRepository, required Ref ref})
    : _goalRepository = goalRepository,
      _ref = ref,
      super(false);

  Future<bool> addGoal(GoalModel goal) async {
    state = true;
    try {
      await _goalRepository.addGoal(goal);
      _ref.invalidate(goalsStreamProvider);
      _ref.invalidate(goalsWithProgressProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      rethrow;
    }
  }

  Future<bool> updateGoal(GoalModel goal) async {
    state = true;
    try {
      await _goalRepository.updateGoal(goal);
      _ref.invalidate(goalsStreamProvider);
      _ref.invalidate(goalsWithProgressProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      rethrow;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    state = true;
    try {
      await _goalRepository.deleteGoal(goalId);
      _ref.invalidate(goalsStreamProvider);
      _ref.invalidate(goalsWithProgressProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      rethrow;
    }
  }

  Future<bool> addFundsToGoal({
    required String goalId,
    required double amount,
    required String fromAccountName,
  }) async {
    state = true;
    try {
      await _goalRepository.addFundsToGoal(
        goalId: goalId,
        amount: amount,
        fromAccountName: fromAccountName,
      );
      if (!mounted) return false;
      _ref.invalidate(goalsStreamProvider);
      _ref.invalidate(goalsWithProgressProvider);
      _ref.invalidate(transactionsStreamProvider);
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      rethrow;
    }
  }
}
