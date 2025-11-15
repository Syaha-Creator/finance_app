import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/goal_model.dart';
import '../data/repositories/goal_repository.dart';
import '../presentation/providers/goal_provider.dart';
import '../../transaction/data/models/transaction_model.dart';
import '../../transaction/data/repositories/transaction_repository.dart';
import '../../transaction/presentation/providers/transaction_provider.dart';

class GoalProgressService {
  final GoalRepository _goalRepository;
  final TransactionRepository _transactionRepository;

  GoalProgressService({
    required GoalRepository goalRepository,
    required TransactionRepository transactionRepository,
  }) : _goalRepository = goalRepository,
       _transactionRepository = transactionRepository;

  /// Update goal progress based on transactions
  Future<void> updateGoalProgress(String goalId) async {
    try {
      // Get the goal
      final goal = await _goalRepository.getGoalById(goalId);
      if (goal == null) return;

      // Get all transactions for this goal
      final transactions = await _transactionRepository.getTransactionsByGoalId(
        goalId,
      );

      // Calculate new progress
      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpense += transaction.amount;
        }
      }

      // Calculate current amount (income - expense)
      final currentAmount = totalIncome - totalExpense;

      // Calculate progress percentage
      final progressPercentage =
          goal.targetAmount > 0
              ? (currentAmount / goal.targetAmount).clamp(0.0, 1.0)
              : 0.0;

      // Check if goal should be auto-completed
      GoalStatus newStatus = goal.status;
      if (progressPercentage >= 1.0 && goal.status != GoalStatus.completed) {
        newStatus = GoalStatus.completed;
      } else if (progressPercentage < 1.0 &&
          goal.status == GoalStatus.completed) {
        newStatus = GoalStatus.inProgress;
      }

      // Update goal with new progress
      final updatedGoal = goal.copyWith(
        currentAmount: currentAmount,
        status: newStatus,
      );

      await _goalRepository.updateGoal(updatedGoal);
    } catch (e) {
      // Log error but don't throw to avoid breaking transaction flow
      print('Error updating goal progress: $e');
    }
  }

  /// Get goal progress summary
  Future<Map<String, dynamic>> getGoalProgressSummary(String goalId) async {
    try {
      final goal = await _goalRepository.getGoalById(goalId);
      if (goal == null) {
        return {
          'currentAmount': 0.0,
          'progressPercentage': 0.0,
          'totalIncome': 0.0,
          'totalExpense': 0.0,
          'remainingAmount': 0.0,
        };
      }

      final transactions = await _transactionRepository.getTransactionsByGoalId(
        goalId,
      );

      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpense += transaction.amount;
        }
      }

      final currentAmount = totalIncome - totalExpense;
      final progressPercentage =
          goal.targetAmount > 0
              ? (currentAmount / goal.targetAmount).clamp(0.0, 1.0)
              : 0.0;
      final remainingAmount = (goal.targetAmount - currentAmount).clamp(
        0.0,
        double.infinity,
      );

      return {
        'currentAmount': currentAmount,
        'progressPercentage': progressPercentage,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'remainingAmount': remainingAmount,
      };
    } catch (e) {
      print('Error getting goal progress summary: $e');
      return {
        'currentAmount': 0.0,
        'progressPercentage': 0.0,
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'remainingAmount': 0.0,
      };
    }
  }
}

// Provider for GoalProgressService
final goalProgressServiceProvider = Provider<GoalProgressService>((ref) {
  final goalRepository = ref.watch(goalRepositoryProvider);
  final transactionRepository = ref.watch(transactionRepositoryProvider);

  return GoalProgressService(
    goalRepository: goalRepository,
    transactionRepository: transactionRepository,
  );
});
