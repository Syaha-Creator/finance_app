import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  TransactionRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  Stream<List<TransactionModel>> getTransactionsStream() {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return Stream.value([]);
      }

      final query = _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      return query
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => TransactionModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            return <TransactionModel>[];
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      final data = transaction.toFirestore();
      await _firestore.collection('transactions').add(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final data = transaction.toFirestore();
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTransfer({
    required double amount,
    required String fromAccount,
    required String toAccount,
    required DateTime date,
    required String description,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final batch = _firestore.batch();
    final collection = _firestore.collection(
      FirestoreConstants.transactionsCollection,
    );

    final expenseTransaction = TransactionModel(
      userId: userId,
      description: 'Transfer ke $toAccount: $description',
      amount: amount,
      category: 'Transfer Keluar',
      account: fromAccount,
      date: date,
      type: TransactionType.expense,
    );
    batch.set(collection.doc(), expenseTransaction.toFirestore());

    final incomeTransaction = TransactionModel(
      userId: userId,
      description: 'Transfer dari $fromAccount: $description',
      amount: amount,
      category: 'Transfer Masuk',
      account: toAccount,
      date: date,
      type: TransactionType.income,
    );
    batch.set(collection.doc(), incomeTransaction.toFirestore());

    await batch.commit();
  }

  Future<List<TransactionModel>> getTransactionsByGoalId(String goalId) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final snapshot =
          await _firestore
              .collection(FirestoreConstants.transactionsCollection)
              .where('userId', isEqualTo: userId)
              .where('goalId', isEqualTo: goalId)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting transactions by goal ID: $e');
      return [];
    }
  }

  Future<List<String>> getExpenseCategories() async {
    final snapshot = await _firestore.collection('expense_categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<List<String>> getIncomeCategories() async {
    final snapshot = await _firestore.collection('income_categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<List<String>> getAccounts() async {
    final snapshot = await _firestore.collection('accounts').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }
}
