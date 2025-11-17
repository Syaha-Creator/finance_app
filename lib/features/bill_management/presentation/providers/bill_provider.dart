import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/models/bill_model.dart';
import '../../data/repositories/bill_repository.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

final billsProvider = StreamProvider.autoDispose<List<BillModel>>((ref) {
  final billRepository = ref.watch(billRepositoryProvider);
  return billRepository.getBills();
});

final billsSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final bills = await ref.watch(billsProvider.future);

  final totalBills = bills.length;
  final pendingBills =
      bills.where((b) => b.status == BillStatus.pending).length;
  final paidBills = bills.where((b) => b.status == BillStatus.paid).length;
  final overdueBills =
      bills.where((b) => b.status == BillStatus.overdue).length;
  final totalAmount = bills.fold<double>(0, (sum, bill) => sum + bill.amount);
  final pendingAmount = bills
      .where((b) => b.status == BillStatus.pending)
      .fold<double>(0, (sum, bill) => sum + bill.amount);

  return {
    'totalBills': totalBills,
    'pendingBills': pendingBills,
    'paidBills': paidBills,
    'overdueBills': overdueBills,
    'totalAmount': totalAmount,
    'pendingAmount': pendingAmount,
  };
});

final billNotifierProvider =
    StateNotifierProvider.autoDispose<BillController, AsyncValue<void>>((ref) {
      return BillController(
        billRepository: ref.watch(billRepositoryProvider),
        ref: ref,
      );
    });

class BillController extends StateNotifier<AsyncValue<void>> {
  final BillRepository _billRepository;
  final Ref _ref;

  BillController({required BillRepository billRepository, required Ref ref})
    : _billRepository = billRepository,
      _ref = ref,
      super(const AsyncValue.data(null));

  Future<void> addBill(BillModel bill) async {
    state = const AsyncValue.loading();
    try {
      await _billRepository.addBill(bill);
      _ref.invalidate(billsProvider);
      _ref.invalidate(billsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateBill(BillModel bill) async {
    state = const AsyncValue.loading();
    try {
      await _billRepository.updateBill(bill);
      _ref.invalidate(billsProvider);
      _ref.invalidate(billsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteBill(String billId) async {
    state = const AsyncValue.loading();
    try {
      await _billRepository.deleteBill(billId);
      _ref.invalidate(billsProvider);
      _ref.invalidate(billsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsPaid(String billId) async {
    state = const AsyncValue.loading();
    try {
      await _billRepository.markAsPaid(billId);
      _ref.invalidate(billsProvider);
      _ref.invalidate(billsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsCancelled(String billId) async {
    state = const AsyncValue.loading();
    try {
      await _billRepository.markAsCancelled(billId);
      _ref.invalidate(billsProvider);
      _ref.invalidate(billsSummaryProvider);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
