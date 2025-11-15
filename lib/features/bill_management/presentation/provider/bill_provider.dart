import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/bill_model.dart';
import '../../data/repositories/bill_repository.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final billsProvider = StreamProvider<List<BillModel>>((ref) {
  try {
    final repository = ref.watch(billRepositoryProvider);
    return repository.getBills().handleError((error) {
      // Return empty list if there's an error
      return <BillModel>[];
    });
  } catch (e) {
    // Return empty stream if there's an error
    return Stream.value(<BillModel>[]);
  }
});

final pendingBillsProvider = StreamProvider<List<BillModel>>((ref) {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getBillsByStatus(BillStatus.pending);
});

final overdueBillsProvider = StreamProvider<List<BillModel>>((ref) {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getOverdueBills();
});

final upcomingBillsProvider = StreamProvider<List<BillModel>>((ref) {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getUpcomingBills();
});

final paidBillsProvider = StreamProvider<List<BillModel>>((ref) {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getBillsByStatus(BillStatus.paid);
});

final billsNeedingRemindersProvider = StreamProvider<List<BillModel>>((ref) {
  final repository = ref.watch(billRepositoryProvider);
  return repository.getBillsNeedingReminders();
});

final billsSummaryProvider = StreamProvider<Map<String, dynamic>>((ref) {
  try {
    final repository = ref.watch(billRepositoryProvider);
    return repository.getBillsSummaryStream().handleError((error) {
      // Return default values if there's an error
      return {
        'totalBills': 0,
        'pendingBills': 0,
        'overdueBills': 0,
        'paidBills': 0,
        'totalAmount': 0.0,
      };
    });
  } catch (e) {
    // Return empty stream if there's an error
    return Stream.value({
      'totalBills': 0,
      'pendingBills': 0,
      'overdueBills': 0,
      'paidBills': 0,
      'totalAmount': 0.0,
    });
  }
});

class BillNotifier extends StateNotifier<AsyncValue<void>> {
  final BillRepository _repository;

  BillNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addBill(BillModel bill) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addBill(bill);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateBill(BillModel bill) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateBill(bill);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteBill(String billId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteBill(billId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsPaid(String billId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsPaid(billId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsCancelled(String billId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsCancelled(billId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final billNotifierProvider =
    StateNotifierProvider<BillNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(billRepositoryProvider);
      return BillNotifier(repository);
    });
