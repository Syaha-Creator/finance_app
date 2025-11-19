import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/providers/firebase_providers.dart';
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
    StateNotifierProvider.autoDispose<GoalController, AsyncValue<void>>((ref) {
      return GoalController(
        goalRepository: ref.watch(goalRepositoryProvider),
        ref: ref,
      );
    });

class GoalController extends BaseController {
  final GoalRepository _goalRepository;

  GoalController({required GoalRepository goalRepository, required super.ref})
    : _goalRepository = goalRepository;

  List<ProviderOrFamily> get _goalProvidersToInvalidate => [
    goalsStreamProvider,
    goalsWithProgressProvider,
  ];

  Future<void> addGoal(GoalModel goal) async {
    await executeWithLoading(
      () => _goalRepository.addGoal(goal),
      providersToInvalidate: _goalProvidersToInvalidate,
    );
  }

  Future<void> updateGoal(GoalModel goal) async {
    await executeWithLoading(
      () => _goalRepository.updateGoal(goal),
      providersToInvalidate: _goalProvidersToInvalidate,
    );
  }

  Future<void> deleteGoal(String goalId) async {
    await executeWithLoading(
      () => _goalRepository.deleteGoal(goalId),
      providersToInvalidate: _goalProvidersToInvalidate,
    );
  }

  Future<void> addFundsToGoal({
    required String goalId,
    required double amount,
    required String fromAccountName,
  }) async {
    await executeWithLoading(
      () => _goalRepository.addFundsToGoal(
        goalId: goalId,
        amount: amount,
        fromAccountName: fromAccountName,
      ),
      providersToInvalidate: [
        ..._goalProvidersToInvalidate,
        transactionsStreamProvider,
      ],
    );
  }
}
