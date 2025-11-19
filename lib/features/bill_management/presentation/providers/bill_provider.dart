import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../data/models/bill_model.dart';
import '../../data/repositories/bill_repository.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
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

class BillController extends BaseController {
  final BillRepository _billRepository;

  BillController({required BillRepository billRepository, required super.ref})
    : _billRepository = billRepository;

  Future<void> addBill(BillModel bill) async {
    await executeWithLoading(
      () => _billRepository.addBill(bill),
      providersToInvalidate: [billsProvider, billsSummaryProvider],
    );
  }

  Future<void> updateBill(BillModel bill) async {
    await executeWithLoading(
      () => _billRepository.updateBill(bill),
      providersToInvalidate: [billsProvider, billsSummaryProvider],
    );
  }

  Future<void> deleteBill(String billId) async {
    await executeWithLoading(
      () => _billRepository.deleteBill(billId),
      providersToInvalidate: [billsProvider, billsSummaryProvider],
    );
  }

  Future<void> markAsPaid(String billId) async {
    await executeWithLoading(
      () => _billRepository.markAsPaid(billId),
      providersToInvalidate: [billsProvider, billsSummaryProvider],
    );
  }

  Future<void> markAsCancelled(String billId) async {
    await executeWithLoading(
      () => _billRepository.markAsCancelled(billId),
      providersToInvalidate: [billsProvider, billsSummaryProvider],
    );
  }
}
