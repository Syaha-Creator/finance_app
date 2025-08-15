import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../data/models/goal_model.dart';
import '../../data/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

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
