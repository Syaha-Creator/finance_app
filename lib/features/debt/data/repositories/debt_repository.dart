import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../models/debt_receivable_model.dart';

class DebtRepository extends BaseRepository {
  DebtRepository({required super.firestore, required super.firebaseAuth});

  CollectionReference get _debtCollection =>
      getCollection(FirestoreConstants.debtsCollection);
  CollectionReference get _transactionCollection =>
      getCollection(FirestoreConstants.transactionsCollection);

  Stream<List<DebtReceivableModel>> getDebtsStream() {
    return createStreamQuery<DebtReceivableModel>(
      collectionName: FirestoreConstants.debtsCollection,
      fromFirestore: (doc) => DebtReceivableModel.fromFirestore(doc),
      orderByField: 'dueDate',
      descending: false,
      userIdField: 'userId',
    );
  }

  Future<void> addDebt(DebtReceivableModel debt) async {
    final data = debt.toFirestore();
    await addDocument(
      collectionName: FirestoreConstants.debtsCollection,
      data: data,
      requireUserId: true,
    );
  }

  Future<void> updateDebt(DebtReceivableModel debt) async {
    if (debt.id == null) {
      throw Exception('Debt ID is null, cannot update.');
    }
    final data = debt.toFirestore();
    await updateDocument(
      collectionName: FirestoreConstants.debtsCollection,
      documentId: debt.id!,
      data: data,
      userIdField: 'userId', // Security: validate user ownership
    );
  }

  Future<void> deleteDebt(String debtId) async {
    await deleteDocument(
      collectionName: FirestoreConstants.debtsCollection,
      documentId: debtId,
      userIdField: 'userId', // Security: validate user ownership
    );
  }

  Future<void> markAsPaid(DebtReceivableModel debt, String account) async {
    if (debt.id == null) {
      throw Exception('Debt ID is null, cannot mark as paid.');
    }

    // Security: Validate that debt belongs to current user
    final userId = requiredUserId;
    final debtDoc = await _debtCollection.doc(debt.id!).get();
    if (!debtDoc.exists) {
      throw Exception('Utang/Piutang tidak ditemukan');
    }
    final debtData = debtDoc.data() as Map<String, dynamic>?;
    if (debtData == null || debtData['userId'] != userId) {
      throw Exception('Anda tidak memiliki izin untuk mengubah data ini');
    }

    final batch = firestore.batch();
    final debtDocRef = _debtCollection.doc(debt.id!);
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
