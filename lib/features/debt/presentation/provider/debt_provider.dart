import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final debtControllerProvider =
    StateNotifierProvider.autoDispose<DebtController, bool>((ref) {
      return DebtController(
        debtRepository: ref.watch(debtRepositoryProvider),
        ref: ref,
      );
    });

class DebtController extends StateNotifier<bool> {
  final DebtRepository _debtRepository;
  final Ref _ref;

  DebtController({required DebtRepository debtRepository, required Ref ref})
    : _debtRepository = debtRepository,
      _ref = ref,
      super(false);

  Future<bool> addDebt(DebtReceivableModel debt) async {
    state = true;
    try {
      await _debtRepository.addDebt(debt);
      _ref.invalidate(debtsStreamProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> updateDebt(DebtReceivableModel debt) async {
    state = true;
    try {
      await _debtRepository.updateDebt(debt);
      _ref.invalidate(debtsStreamProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> deleteDebt(String debtId) async {
    state = true;
    try {
      await _debtRepository.deleteDebt(debtId);
      _ref.invalidate(debtsStreamProvider);
      if (!mounted) return false;
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }

  Future<bool> markAsPaid(DebtReceivableModel debt, String account) async {
    state = true;
    try {
      await _debtRepository.markAsPaid(debt, account);

      if (!mounted) return false;

      _ref.invalidate(transactionsStreamProvider);
      _ref.invalidate(debtsStreamProvider);
      state = false;
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = false;
      return false;
    }
  }
}
