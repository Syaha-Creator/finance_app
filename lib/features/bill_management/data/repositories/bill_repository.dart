import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../../../../core/utils/logger.dart';
import '../models/bill_model.dart';

class BillRepository extends BaseRepository {
  BillRepository({required super.firestore, required super.firebaseAuth});

  CollectionReference get _billsCollection =>
      getCollection(FirestoreConstants.billsCollection);

  // Get all bills for current user
  // Note: Using manual implementation due to double orderBy requirement
  Stream<List<BillModel>> getBills() {
    try {
      final userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      return _billsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BillModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            Logger.error('getBills failed', error);
            return <BillModel>[];
          });
    } catch (e) {
      Logger.error('getBills failed', e);
      return Stream.value(<BillModel>[]);
    }
  }

  // Get bills by status
  // Note: Using manual implementation due to double orderBy requirement
  Stream<List<BillModel>> getBillsByStatus(BillStatus status) {
    try {
      final userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      return _billsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('dueDate', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BillModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            Logger.error('getBillsByStatus failed', error);
            return <BillModel>[];
          });
    } catch (e) {
      Logger.error('getBillsByStatus failed', e);
      return Stream.value(<BillModel>[]);
    }
  }

  // Get overdue bills
  // Note: Using manual implementation due to double orderBy requirement
  Stream<List<BillModel>> getOverdueBills() {
    try {
      final userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      final now = DateTime.now();
      return _billsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: BillStatus.pending.name)
          .where('dueDate', isLessThan: now)
          .orderBy('dueDate', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BillModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            Logger.error('getOverdueBills failed', error);
            return <BillModel>[];
          });
    } catch (e) {
      Logger.error('getOverdueBills failed', e);
      return Stream.value(<BillModel>[]);
    }
  }

  // Get upcoming bills (due in next 7 days)
  // Note: Using manual implementation due to double orderBy requirement
  Stream<List<BillModel>> getUpcomingBills() {
    try {
      final userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));
      return _billsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: BillStatus.pending.name)
          .where('dueDate', isGreaterThanOrEqualTo: now)
          .where('dueDate', isLessThanOrEqualTo: nextWeek)
          .orderBy('dueDate', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BillModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            Logger.error('getUpcomingBills failed', error);
            return <BillModel>[];
          });
    } catch (e) {
      Logger.error('getUpcomingBills failed', e);
      return Stream.value(<BillModel>[]);
    }
  }

  // Add new bill
  Future<void> addBill(BillModel bill) async {
    final billData = bill.copyWith(
      userId: requiredUserId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await addDocument(
      collectionName: FirestoreConstants.billsCollection,
      data: billData.toFirestore(),
      requireUserId: false, // userId sudah di-set di copyWith
    );
  }

  // Update bill
  Future<void> updateBill(BillModel bill) async {
    final billData = bill.copyWith(updatedAt: DateTime.now());

    await updateDocument(
      collectionName: FirestoreConstants.billsCollection,
      documentId: bill.id,
      data: billData.toFirestore(),
      userIdField: 'userId',
    );
  }

  // Delete bill
  Future<void> deleteBill(String billId) async {
    await deleteDocument(
      collectionName: FirestoreConstants.billsCollection,
      documentId: billId,
      userIdField: 'userId',
    );
  }

  // Mark bill as paid
  Future<void> markAsPaid(String billId) async {
    final now = DateTime.now();
    await updateDocument(
      collectionName: FirestoreConstants.billsCollection,
      documentId: billId,
      data: {
        'status': BillStatus.paid.name,
        'paidDate': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
      userIdField: 'userId',
    );
  }

  // Mark bill as cancelled
  Future<void> markAsCancelled(String billId) async {
    final now = DateTime.now();
    await updateDocument(
      collectionName: FirestoreConstants.billsCollection,
      documentId: billId,
      data: {
        'status': BillStatus.cancelled.name,
        'updatedAt': Timestamp.fromDate(now),
      },
      userIdField: 'userId',
    );
  }

  // Get bills that need reminders
  Stream<List<BillModel>> getBillsNeedingReminders() {
    try {
      final userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        return Stream.value(<BillModel>[]);
      }

      final now = DateTime.now();
      return _billsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: BillStatus.pending.name)
          .where('hasReminder', isEqualTo: true)
          .where('dueDate', isGreaterThan: now)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BillModel.fromFirestore(doc))
                .where((bill) {
                  final reminderDate = bill.dueDate.subtract(
                    Duration(days: bill.reminderDays),
                  );
                  return now.isAfter(reminderDate) &&
                      now.isBefore(bill.dueDate);
                })
                .toList();
          })
          .handleError((error) {
            Logger.error('getBillsNeedingReminders failed', error);
            return <BillModel>[];
          });
    } catch (e) {
      Logger.error('getBillsNeedingReminders failed', e);
      return Stream.value(<BillModel>[]);
    }
  }

  // Get bills summary for dashboard
  Future<Map<String, dynamic>> getBillsSummary() async {
    try {
      final bills = await getDocumentsByQuery<BillModel>(
        collectionName: FirestoreConstants.billsCollection,
        fromFirestore: (doc) => BillModel.fromFirestore(doc),
        userIdField: 'userId',
      );

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
      final userId = currentUserId;
      if (userId == null || userId.isEmpty) {
        return Stream.value({
          'totalBills': 0,
          'pendingBills': 0,
          'overdueBills': 0,
          'paidBills': 0,
          'totalAmount': 0.0,
        });
      }

      return _billsCollection
          .where('userId', isEqualTo: userId)
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
            Logger.error('getBillsSummaryStream failed', error);
            return {
              'totalBills': 0,
              'pendingBills': 0,
              'overdueBills': 0,
              'paidBills': 0,
              'totalAmount': 0.0,
            };
          });
    } catch (e) {
      Logger.error('getBillsSummaryStream failed', e);
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
