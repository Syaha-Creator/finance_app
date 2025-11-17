import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../models/bill_model.dart';

class BillRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BillRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all bills for current user
  Stream<List<BillModel>> getBills() {
    try {
      // Check if user is logged in
      if (_userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      return _firestore
          .collection(FirestoreConstants.billsCollection)
          .where('userId', isEqualTo: _userId)
          .orderBy('dueDate', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BillModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            return <BillModel>[];
          });
    } catch (e) {
      return Stream.value(<BillModel>[]);
    }
  }

  // Get bills by status
  Stream<List<BillModel>> getBillsByStatus(BillStatus status) {
    try {
      if (_userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      return _firestore
          .collection(FirestoreConstants.billsCollection)
          .where('userId', isEqualTo: _userId)
          .where('status', isEqualTo: status.name)
          .orderBy('dueDate', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .snapshots()
          .map((snapshot) {
            final bills =
                snapshot.docs
                    .map((doc) => BillModel.fromFirestore(doc))
                    .toList();
            return bills;
          })
          .handleError((error) {
            return <BillModel>[];
          });
    } catch (e) {
      return Stream.value(<BillModel>[]);
    }
  }

  // Get overdue bills
  Stream<List<BillModel>> getOverdueBills() {
    try {
      if (_userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      final now = DateTime.now();
      return _firestore
          .collection(FirestoreConstants.billsCollection)
          .where('userId', isEqualTo: _userId)
          .where('status', isEqualTo: BillStatus.pending.name)
          .where('dueDate', isLessThan: now)
          .orderBy('dueDate', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .snapshots()
          .map((snapshot) {
            final bills =
                snapshot.docs
                    .map((doc) => BillModel.fromFirestore(doc))
                    .toList();

            return bills;
          })
          .handleError((error) {
            return <BillModel>[];
          });
    } catch (e) {
      return Stream.value(<BillModel>[]);
    }
  }

  // Get upcoming bills (due in next 7 days)
  Stream<List<BillModel>> getUpcomingBills() {
    try {
      if (_userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));
      return _firestore
          .collection(FirestoreConstants.billsCollection)
          .where('userId', isEqualTo: _userId)
          .where('status', isEqualTo: BillStatus.pending.name)
          .where('dueDate', isGreaterThanOrEqualTo: now)
          .where('dueDate', isLessThanOrEqualTo: nextWeek)
          .orderBy('dueDate', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .snapshots()
          .map((snapshot) {
            final bills =
                snapshot.docs
                    .map((doc) => BillModel.fromFirestore(doc))
                    .toList();
            return bills;
          })
          .handleError((error) {
            return <BillModel>[];
          });
    } catch (e) {
      return Stream.value(<BillModel>[]);
    }
  }

  // Add new bill
  Future<void> addBill(BillModel bill) async {
    try {
      // Check if user is logged in
      if (_userId.isEmpty) {
        throw Exception(
          'User tidak terautentikasi. Silakan login terlebih dahulu.',
        );
      }

      final billData = bill.copyWith(
        userId: _userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final billMap = billData.toFirestore();

      await _firestore
          .collection(FirestoreConstants.billsCollection)
          .add(billMap);
    } catch (e) {
      throw Exception('Gagal menambahkan tagihan: $e');
    }
  }

  // Update bill
  Future<void> updateBill(BillModel bill) async {
    final billData = bill.copyWith(updatedAt: DateTime.now());

    await _firestore
        .collection(FirestoreConstants.billsCollection)
        .doc(bill.id)
        .update(billData.toFirestore());
  }

  // Delete bill
  Future<void> deleteBill(String billId) async {
    await _firestore
        .collection(FirestoreConstants.billsCollection)
        .doc(billId)
        .delete();
  }

  // Mark bill as paid
  Future<void> markAsPaid(String billId) async {
    final now = DateTime.now();
    await _firestore
        .collection(FirestoreConstants.billsCollection)
        .doc(billId)
        .update({
      'status': BillStatus.paid.name,
      'paidDate': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  // Mark bill as cancelled
  Future<void> markAsCancelled(String billId) async {
    final now = DateTime.now();
    await _firestore
        .collection(FirestoreConstants.billsCollection)
        .doc(billId)
        .update({
      'status': BillStatus.cancelled.name,
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  // Get bills that need reminders
  Stream<List<BillModel>> getBillsNeedingReminders() {
    final now = DateTime.now();
    return _firestore
        .collection(FirestoreConstants.billsCollection)
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: BillStatus.pending.name)
        .where('hasReminder', isEqualTo: true)
        .where('dueDate', isGreaterThan: now)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).where(
            (bill) {
              final reminderDate = bill.dueDate.subtract(
                Duration(days: bill.reminderDays),
              );
              return now.isAfter(reminderDate) && now.isBefore(bill.dueDate);
            },
          ).toList();
        });
  }

  // Get bills summary for dashboard
  Future<Map<String, dynamic>> getBillsSummary() async {
    try {
      // Check if user is logged in
      if (_userId.isEmpty) {
        throw Exception('User tidak terautentikasi');
      }

      final billsSnapshot =
          await _firestore
              .collection(FirestoreConstants.billsCollection)
              .where('userId', isEqualTo: _userId)
              .get();

      final bills =
          billsSnapshot.docs
              .map((doc) => BillModel.fromFirestore(doc))
              .toList();

      final now = DateTime.now();
      final totalBills = bills.length;
      final pendingBills =
          bills.where((b) => b.status == BillStatus.pending).length;
      final overdueBills =
          bills
              .where(
                (b) =>
                    b.status == BillStatus.pending && b.dueDate.isBefore(now),
              )
              .length;
      final paidBills = bills.where((b) => b.status == BillStatus.paid).length;
      final totalAmount = bills
          .where((b) => b.status == BillStatus.pending)
          .fold(0.0, (total, bill) => total + bill.amount);

      return {
        'totalBills': totalBills,
        'pendingBills': pendingBills,
        'overdueBills': overdueBills,
        'paidBills': paidBills,
        'totalAmount': totalAmount,
      };
    } catch (e) {
      // Return default values if there's an error
      return {
        'totalBills': 0,
        'pendingBills': 0,
        'overdueBills': 0,
        'paidBills': 0,
        'totalAmount': 0.0,
      };
    }
  }

  // Get bills summary stream for real-time updates
  Stream<Map<String, dynamic>> getBillsSummaryStream() {
    try {
      // Check if user is logged in
      if (_userId.isEmpty) {
        return Stream.value({
          'totalBills': 0,
          'pendingBills': 0,
          'overdueBills': 0,
          'paidBills': 0,
          'totalAmount': 0.0,
        });
      }

      return _firestore
          .collection('bills')
          .where('userId', isEqualTo: _userId)
          .snapshots()
          .map((snapshot) {
            final bills =
                snapshot.docs
                    .map((doc) => BillModel.fromFirestore(doc))
                    .toList();

            final now = DateTime.now();
            final totalBills = bills.length;
            final pendingBills =
                bills.where((b) => b.status == BillStatus.pending).length;
            final overdueBills =
                bills
                    .where(
                      (b) =>
                          b.status == BillStatus.pending &&
                          b.dueDate.isBefore(now),
                    )
                    .length;
            final paidBills =
                bills.where((b) => b.status == BillStatus.paid).length;
            final totalAmount = bills
                .where((b) => b.status == BillStatus.pending)
                .fold(0.0, (total, bill) => total + bill.amount);

            return {
              'totalBills': totalBills,
              'pendingBills': pendingBills,
              'overdueBills': overdueBills,
              'paidBills': paidBills,
              'totalAmount': totalAmount,
            };
          })
          .handleError((error) {
            return {
              'totalBills': 0,
              'pendingBills': 0,
              'overdueBills': 0,
              'paidBills': 0,
              'totalAmount': 0.0,
            };
          });
    } catch (e) {
      return Stream.value({
        'totalBills': 0,
        'pendingBills': 0,
        'overdueBills': 0,
        'paidBills': 0,
        'totalAmount': 0.0,
      });
    }
  }
}
