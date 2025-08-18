import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../models/debt_receivable_model.dart';

class DebtRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  DebtRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  CollectionReference get _debtCollection => _firestore.collection('debts');
  CollectionReference get _transactionCollection =>
      _firestore.collection('transactions');

  Stream<List<DebtReceivableModel>> getDebtsStream() {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return Stream.value([]);
      }

      final query = _firestore
          .collection('debts')
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate', descending: false);

      return query
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => DebtReceivableModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            return <DebtReceivableModel>[];
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> addDebt(DebtReceivableModel debt) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      final data = debt.toFirestore();
      await _firestore.collection('debts').add(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDebt(DebtReceivableModel debt) async {
    try {
      final data = debt.toFirestore();
      await _firestore.collection('debts').doc(debt.id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDebt(String debtId) async {
    try {
      await _firestore.collection('debts').doc(debtId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsPaid(DebtReceivableModel debt, String account) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final batch = _firestore.batch();

    final debtDocRef = _debtCollection.doc(debt.id);
    batch.update(debtDocRef, {'status': 'paid'});

    TransactionModel newTransaction;
    if (debt.type == DebtReceivableType.debt) {
      newTransaction = TransactionModel(
        userId: userId,
        description: 'Bayar utang ke ${debt.personName}',
        amount: debt.amount,
        category: 'Pembayaran Utang',
        account: account,
        date: DateTime.now(),
        type: TransactionType.expense,
      );
    } else {
      newTransaction = TransactionModel(
        userId: userId,
        description: 'Terima pembayaran dari ${debt.personName}',
        amount: debt.amount,
        category: 'Penerimaan Piutang',
        account: account,
        date: DateTime.now(),
        type: TransactionType.income,
      );
    }

    final newTransactionRef = _transactionCollection.doc();
    batch.set(newTransactionRef, newTransaction.toFirestore());

    await batch.commit();
  }
}
