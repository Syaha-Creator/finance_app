import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    StateNotifierProvider.autoDispose<RecurringTransactionController, bool>((
      ref,
    ) {
      return RecurringTransactionController(
        repository: ref.watch(recurringTransactionRepositoryProvider),
        ref: ref,
      );
    });

class RecurringTransactionController extends StateNotifier<bool> {
  final RecurringTransactionRepository _repository;
  final Ref _ref;

  RecurringTransactionController({
    required RecurringTransactionRepository repository,
    required Ref ref,
  }) : _repository = repository,
       _ref = ref,
       super(false);

  Future<bool> add(RecurringTransactionModel recurring) async {
    state = true;
    try {
      await _repository.addRecurringTransaction(recurring);
      _ref.invalidate(recurringTransactionsStreamProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> update(RecurringTransactionModel recurring) async {
    state = true;
    try {
      await _repository.updateRecurringTransaction(recurring);
      _ref.invalidate(recurringTransactionsStreamProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> delete(String id) async {
    state = true;
    try {
      await _repository.deleteRecurringTransaction(id);
      _ref.invalidate(recurringTransactionsStreamProvider);
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
