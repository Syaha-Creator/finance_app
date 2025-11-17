import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../settings/data/models/setting_model.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final transactionsStreamProvider =
    StreamProvider.autoDispose<List<TransactionModel>>((ref) {
      final user = ref.watch(authStateChangesProvider).value;

      if (user == null) {
        return Stream.value([]);
      }

      return ref.watch(transactionRepositoryProvider).getTransactionsStream();
    });

final expenseCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryModel>>((ref) {
      // Provider ini sekarang bergantung pada SettingsRepository
      final settingsRepo = ref.watch(settingsRepositoryProvider);
      return settingsRepo.getCombinedStream('expense_categories');
    });

final incomeCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryModel>>((ref) {
      final settingsRepo = ref.watch(settingsRepositoryProvider);
      return settingsRepo.getCombinedStream('income_categories');
    });

final accountsProvider = StreamProvider.autoDispose<List<CategoryModel>>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.getCombinedStream('accounts');
});

// Provider untuk transaction controller
final transactionControllerProvider =
    StateNotifierProvider.autoDispose<TransactionController, bool>((ref) {
      return TransactionController(
        transactionRepository: ref.watch(transactionRepositoryProvider),
        ref: ref,
      );
    });

class TransactionController extends StateNotifier<bool> {
  final TransactionRepository _transactionRepository;
  final Ref _ref;

  TransactionController({
    required TransactionRepository transactionRepository,
    required Ref ref,
  }) : _transactionRepository = transactionRepository,
       _ref = ref,
       super(false);

  Future<bool> addTransaction(TransactionModel transaction) async {
    state = true;
    try {
      await _transactionRepository.addTransaction(transaction);

      // Invalidate semua provider yang terkait
      _ref.invalidate(transactionsStreamProvider);

      // Jika transaksi terkait dengan goal, invalidate goals provider juga
      if (transaction.goalId != null) {
        _ref.invalidate(goalsStreamProvider);
        // Invalidate provider goals yang baru jika ada
        try {
          _ref.invalidate(goalsWithProgressProvider);
        } catch (e) {
          // Provider mungkin belum ada, ignore error
        }
      }

      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    state = true;
    try {
      await _transactionRepository.updateTransaction(transaction);

      // Invalidate semua provider yang terkait
      _ref.invalidate(transactionsStreamProvider);

      // Jika transaksi terkait dengan goal, invalidate goals provider juga
      if (transaction.goalId != null) {
        _ref.invalidate(goalsStreamProvider);
        try {
          _ref.invalidate(goalsWithProgressProvider);
        } catch (e) {
          // Provider mungkin belum ada, ignore error
        }
      }

      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    state = true;
    try {
      // Get transaction first to check if it has goalId
      final transactions =
          await _transactionRepository.getTransactionsStream().first;
      final transaction = transactions.firstWhere((t) => t.id == transactionId);

      await _transactionRepository.deleteTransaction(transactionId);

      // Invalidate semua provider yang terkait
      _ref.invalidate(transactionsStreamProvider);

      // Jika transaksi terkait dengan goal, invalidate goals provider juga
      if (transaction.goalId != null) {
        _ref.invalidate(goalsStreamProvider);
        try {
          _ref.invalidate(goalsWithProgressProvider);
        } catch (e) {
          // Provider mungkin belum ada, ignore error
        }
      }

      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }
}
