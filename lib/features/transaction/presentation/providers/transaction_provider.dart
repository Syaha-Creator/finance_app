import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
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
    StateNotifierProvider.autoDispose<TransactionController, AsyncValue<void>>((
      ref,
    ) {
      return TransactionController(
        transactionRepository: ref.watch(transactionRepositoryProvider),
        ref: ref,
      );
    });

class TransactionController extends BaseController {
  final TransactionRepository _transactionRepository;

  TransactionController({
    required TransactionRepository transactionRepository,
    required super.ref,
  }) : _transactionRepository = transactionRepository;

  List<ProviderOrFamily> _getProvidersToInvalidate(String? goalId) {
    final providers = <ProviderOrFamily>[transactionsStreamProvider];
    if (goalId != null) {
      providers.add(goalsStreamProvider);
      try {
        providers.add(goalsWithProgressProvider);
      } catch (e) {
        // Provider mungkin belum ada, ignore error
      }
    }
    return providers;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await executeWithLoading(
      () => _transactionRepository.addTransaction(transaction),
      providersToInvalidate: _getProvidersToInvalidate(transaction.goalId),
    );
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await executeWithLoading(
      () => _transactionRepository.updateTransaction(transaction),
      providersToInvalidate: _getProvidersToInvalidate(transaction.goalId),
    );
  }

  Future<void> deleteTransaction(String transactionId) async {
    // Get transaction first to check if it has goalId
    final transactions =
        await _transactionRepository.getTransactionsStream().first;
    final transaction = transactions.firstWhere((t) => t.id == transactionId);

    await executeWithLoading(
      () => _transactionRepository.deleteTransaction(transactionId),
      providersToInvalidate: _getProvidersToInvalidate(transaction.goalId),
    );
  }
}
