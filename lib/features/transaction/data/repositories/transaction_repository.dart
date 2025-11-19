import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/result.dart';
import '../models/transaction_model.dart';

class TransactionRepository extends BaseRepository {
  TransactionRepository({
    required super.firestore,
    required super.firebaseAuth,
  });

  CollectionReference get _transactionsCollection =>
      getCollection(FirestoreConstants.transactionsCollection);

  Stream<List<TransactionModel>> getTransactionsStream() {
    return createStreamQuery<TransactionModel>(
      collectionName: FirestoreConstants.transactionsCollection,
      fromFirestore: (doc) => TransactionModel.fromFirestore(doc),
      orderByField: 'date',
      descending: true,
      userIdField: 'userId',
    );
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final data = transaction.toFirestore();
    await addDocument(
      collectionName: FirestoreConstants.transactionsCollection,
      data: data,
      requireUserId: true,
    );
  }

  Future<Result<void>> addTransactionR(TransactionModel transaction) async {
    try {
      await addTransaction(transaction);
      return const Success(null);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null || transaction.id!.isEmpty) {
      throw Exception('Transaction ID is null or empty, cannot update.');
    }

    final data = transaction.toFirestore();
    await updateDocument(
      collectionName: FirestoreConstants.transactionsCollection,
      documentId: transaction.id!,
      data: data,
      userIdField: 'userId',
    );
  }

  Future<Result<void>> updateTransactionR(TransactionModel transaction) async {
    try {
      await updateTransaction(transaction);
      return const Success(null);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    await deleteDocument(
      collectionName: FirestoreConstants.transactionsCollection,
      documentId: transactionId,
      userIdField: 'userId',
    );
  }

  Future<Result<void>> deleteTransactionR(String transactionId) async {
    try {
      await deleteTransaction(transactionId);
      return const Success(null);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<void> addTransfer({
    required double amount,
    required String fromAccount,
    required String toAccount,
    required DateTime date,
    required String description,
  }) async {
    final userId = requiredUserId;

    final batch = firestore.batch();
    final collection = _transactionsCollection;

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

  Future<Result<void>> addTransferR({
    required double amount,
    required String fromAccount,
    required String toAccount,
    required DateTime date,
    required String description,
  }) async {
    try {
      await addTransfer(
        amount: amount,
        fromAccount: fromAccount,
        toAccount: toAccount,
        date: date,
        description: description,
      );
      return const Success(null);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<List<TransactionModel>> getTransactionsByGoalId(String goalId) async {
    try {
      return await getDocumentsByQuery<TransactionModel>(
        collectionName: FirestoreConstants.transactionsCollection,
        fromFirestore: (doc) => TransactionModel.fromFirestore(doc),
        userIdField: 'userId',
        whereConditions: [WhereCondition(field: 'goalId', value: goalId)],
        orderByField: 'date',
        descending: true,
      );
    } catch (e) {
      Logger.error('Error getting transactions by goal ID', e);
      return [];
    }
  }

  Future<Result<List<TransactionModel>>> getTransactionsByGoalIdR(
    String goalId,
  ) async {
    try {
      final list = await getTransactionsByGoalId(goalId);
      return Success(list);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<List<String>> getExpenseCategories() async {
    // Master data - no userId filtering needed
    final snapshot =
        await firestore
            .collection(FirestoreConstants.expenseCategoriesCollection)
            .get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<Result<List<String>>> getExpenseCategoriesR() async {
    try {
      final list = await getExpenseCategories();
      return Success(list);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<List<String>> getIncomeCategories() async {
    // Master data - no userId filtering needed
    final snapshot =
        await firestore
            .collection(FirestoreConstants.incomeCategoriesCollection)
            .get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<Result<List<String>>> getIncomeCategoriesR() async {
    try {
      final list = await getIncomeCategories();
      return Success(list);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<List<String>> getAccounts() async {
    // Master data - no userId filtering needed
    final snapshot =
        await firestore.collection(FirestoreConstants.accountsCollection).get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<Result<List<String>>> getAccountsR() async {
    try {
      final list = await getAccounts();
      return Success(list);
    } catch (e, st) {
      return Failure(e, st);
    }
  }
}
