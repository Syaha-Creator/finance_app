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
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _debtCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final docs = snapshot.docs;

      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>?;
        final dataB = b.data() as Map<String, dynamic>?;

        if (dataA == null || dataB == null) return 0;

        final dateA = dataA['createdAt'] as Timestamp;
        final dateB = dataB['createdAt'] as Timestamp;
        return dateB.compareTo(dateA);
      });

      return docs.map((doc) => DebtReceivableModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addDebt(DebtReceivableModel debt) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final debtWithUser = DebtReceivableModel(
      userId: userId,
      type: debt.type,
      personName: debt.personName,
      description: debt.description,
      amount: debt.amount,
      createdAt: debt.createdAt,
      dueDate: debt.dueDate,
      status: debt.status,
    );
    await _debtCollection.add(debtWithUser.toFirestore());
  }

  Future<void> updateDebt(DebtReceivableModel debt) async {
    if (debt.id == null) throw Exception('Debt ID is null, cannot update');
    try {
      await _debtCollection.doc(debt.id).update(debt.toFirestore());
    } catch (e) {
      throw Exception('Gagal mengupdate catatan: $e');
    }
  }

  Future<void> deleteDebt(String debtId) async {
    try {
      await _debtCollection.doc(debtId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus catatan: $e');
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
