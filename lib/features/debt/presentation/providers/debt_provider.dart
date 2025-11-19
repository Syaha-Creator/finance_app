import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
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

class DebtController extends BaseController {
  final DebtRepository _debtRepository;

  DebtController({required DebtRepository debtRepository, required super.ref})
    : _debtRepository = debtRepository;

  Future<void> addDebt(DebtReceivableModel debt) async {
    await executeWithLoading(
      () => _debtRepository.addDebt(debt),
      providersToInvalidate: [debtsStreamProvider],
    );
  }

  Future<void> updateDebt(DebtReceivableModel debt) async {
    await executeWithLoading(
      () => _debtRepository.updateDebt(debt),
      providersToInvalidate: [debtsStreamProvider],
    );
  }

  Future<void> deleteDebt(String debtId) async {
    await executeWithLoading(
      () => _debtRepository.deleteDebt(debtId),
      providersToInvalidate: [debtsStreamProvider],
    );
  }

  Future<void> markAsPaid(DebtReceivableModel debt, String account) async {
    await executeWithLoading(
      () => _debtRepository.markAsPaid(debt, account),
      providersToInvalidate: [transactionsStreamProvider, debtsStreamProvider],
    );
  }
}
