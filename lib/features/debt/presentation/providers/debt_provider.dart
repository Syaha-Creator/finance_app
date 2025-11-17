import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../data/models/debt_receivable_model.dart';
import '../../data/repositories/debt_repository.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final debtsStreamProvider =
    StreamProvider.autoDispose<List<DebtReceivableModel>>((ref) {
      final debtRepository = ref.watch(debtRepositoryProvider);
      return debtRepository.getDebtsStream();
    });

final debtNotifierProvider =
    StateNotifierProvider.autoDispose<DebtController, AsyncValue<void>>((ref) {
      return DebtController(
        debtRepository: ref.watch(debtRepositoryProvider),
        ref: ref,
      );
    });

class DebtController extends StateNotifier<AsyncValue<void>> {
  final DebtRepository _debtRepository;
  final Ref _ref;

  DebtController({required DebtRepository debtRepository, required Ref ref})
    : _debtRepository = debtRepository,
      _ref = ref,
      super(const AsyncValue.data(null));

  Future<void> addDebt(DebtReceivableModel debt) async {
    state = const AsyncValue.loading();
    try {
      await _debtRepository.addDebt(debt);
      _ref.invalidate(debtsStreamProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateDebt(DebtReceivableModel debt) async {
    state = const AsyncValue.loading();
    try {
      await _debtRepository.updateDebt(debt);
      _ref.invalidate(debtsStreamProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteDebt(String debtId) async {
    state = const AsyncValue.loading();
    try {
      await _debtRepository.deleteDebt(debtId);
      _ref.invalidate(debtsStreamProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsPaid(DebtReceivableModel debt, String account) async {
    state = const AsyncValue.loading();
    try {
      await _debtRepository.markAsPaid(debt, account);
      _ref.invalidate(transactionsStreamProvider);
      _ref.invalidate(debtsStreamProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
