import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../models/recurring_transaction_model.dart';

class RecurringTransactionRepository extends BaseRepository {
  RecurringTransactionRepository({
    required super.firestore,
    required super.firebaseAuth,
  });

  // Mendapatkan semua jadwal transaksi berulang milik pengguna
  Stream<List<RecurringTransactionModel>> getRecurringTransactionsStream() {
    return createStreamQuery<RecurringTransactionModel>(
      collectionName: FirestoreConstants.recurringTransactionsCollection,
      fromFirestore: (doc) => RecurringTransactionModel.fromFirestore(doc),
      orderByField: 'nextDueDate',
      descending: false,
      userIdField: 'userId',
    );
  }

  // Menambah jadwal baru
  Future<void> addRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    final data = transaction.toFirestore();
    await addDocument(
      collectionName: FirestoreConstants.recurringTransactionsCollection,
      data: data,
      requireUserId: true,
    );
  }

  // Mengupdate jadwal yang ada
  Future<void> updateRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    if (transaction.id == null) {
      throw Exception('Transaction ID is null, cannot update.');
    }

    final data = transaction.toFirestore();
    await updateDocument(
      collectionName: FirestoreConstants.recurringTransactionsCollection,
      documentId: transaction.id!,
      data: data,
      userIdField: 'userId',
    );
  }

  // Menghapus jadwal
  Future<void> deleteRecurringTransaction(String transactionId) async {
    await deleteDocument(
      collectionName: FirestoreConstants.recurringTransactionsCollection,
      documentId: transactionId,
      userIdField: 'userId',
    );
  }
}
