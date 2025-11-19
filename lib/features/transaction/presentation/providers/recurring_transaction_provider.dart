import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/models/recurring_transaction_model.dart';
import '../../data/repositories/recurring_transaction_repository.dart';

// 1. Provider untuk Repository
final recurringTransactionRepositoryProvider =
    Provider<RecurringTransactionRepository>((ref) {
      return RecurringTransactionRepository(
        firestore: ref.watch(firestoreProvider),
        firebaseAuth: ref.watch(firebaseAuthProvider),
      );
    });

// 2. StreamProvider untuk mendapatkan daftar jadwal
final recurringTransactionsStreamProvider =
    StreamProvider.autoDispose<List<RecurringTransactionModel>>((ref) {
      final repo = ref.watch(recurringTransactionRepositoryProvider);
      return repo.getRecurringTransactionsStream();
    });

// 3. Controller untuk menangani aksi (add, update, delete)
final recurringTransactionControllerProvider =
    StateNotifierProvider.autoDispose<
      RecurringTransactionController,
      AsyncValue<void>
    >((ref) {
      return RecurringTransactionController(
        repository: ref.watch(recurringTransactionRepositoryProvider),
        ref: ref,
      );
    });

class RecurringTransactionController extends BaseController {
  final RecurringTransactionRepository _repository;

  RecurringTransactionController({
    required RecurringTransactionRepository repository,
    required super.ref,
  }) : _repository = repository;

  Future<void> add(RecurringTransactionModel recurring) async {
    await executeWithLoading(
      () => _repository.addRecurringTransaction(recurring),
      providersToInvalidate: [recurringTransactionsStreamProvider],
    );
  }

  Future<void> update(RecurringTransactionModel recurring) async {
    await executeWithLoading(
      () => _repository.updateRecurringTransaction(recurring),
      providersToInvalidate: [recurringTransactionsStreamProvider],
    );
  }

  Future<void> delete(String id) async {
    await executeWithLoading(
      () => _repository.deleteRecurringTransaction(id),
      providersToInvalidate: [recurringTransactionsStreamProvider],
    );
  }
}
