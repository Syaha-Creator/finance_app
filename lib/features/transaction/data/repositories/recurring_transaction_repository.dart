import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../models/recurring_transaction_model.dart';

class RecurringTransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  RecurringTransactionRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  // Mendapatkan semua jadwal transaksi berulang milik pengguna
  Stream<List<RecurringTransactionModel>> getRecurringTransactionsStream() {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return Stream.value([]);
      }

      final query = _firestore
          .collection(FirestoreConstants.recurringTransactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('nextDueDate', descending: false);

      return query
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => RecurringTransactionModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            return <RecurringTransactionModel>[];
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Menambah jadwal baru
  Future<void> addRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      final data = transaction.toFirestore();
      await _firestore
          .collection(FirestoreConstants.recurringTransactionsCollection)
          .add(data);
    } catch (e) {
      rethrow;
    }
  }

  // Mengupdate jadwal yang ada
  Future<void> updateRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    try {
      final data = transaction.toFirestore();
      await _firestore
          .collection(FirestoreConstants.recurringTransactionsCollection)
          .doc(transaction.id)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Menghapus jadwal
  Future<void> deleteRecurringTransaction(String transactionId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.recurringTransactionsCollection)
          .doc(transactionId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}
