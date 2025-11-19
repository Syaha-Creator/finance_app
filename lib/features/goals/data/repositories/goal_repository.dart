import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../models/goal_model.dart';

class GoalRepository extends BaseRepository {
  GoalRepository({required super.firestore, required super.firebaseAuth});

  CollectionReference get _goalsCollection =>
      getCollection(FirestoreConstants.goalsCollection);
  CollectionReference get _transactionsCollection =>
      getCollection(FirestoreConstants.transactionsCollection);

  Stream<List<GoalModel>> getGoalsStream() {
    try {
      return _goalsCollection
          .where('userId', isEqualTo: requiredUserId)
          .orderBy('targetDate', descending: false)
          .orderBy(FieldPath.documentId, descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => GoalModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            Logger.error('getGoalsStream failed', error);
            return <GoalModel>[];
          });
    } catch (e) {
      Logger.error('getGoalsStream failed', e);
      return Stream.value(<GoalModel>[]);
    }
  }

  Future<void> addGoal(GoalModel goal) async {
    final newGoal = goal.copyWith(
      userId: requiredUserId,
      createdAt: DateTime.now(),
    );
    final data = newGoal.toFirestore();
    await addDocument(
      collectionName: FirestoreConstants.goalsCollection,
      data: data,
      requireUserId: false, // userId sudah di-set di copyWith
    );
  }

  Future<void> updateGoal(GoalModel goal) async {
    if (goal.id == null) {
      throw Exception('ID Tujuan tidak boleh kosong.');
    }
    final data = goal.toFirestore();
    await updateDocument(
      collectionName: FirestoreConstants.goalsCollection,
      documentId: goal.id!,
      data: data,
      userIdField: 'userId', // Security: validate user ownership
    );
  }

  Future<void> deleteGoal(String goalId) async {
    await deleteDocument(
      collectionName: FirestoreConstants.goalsCollection,
      documentId: goalId,
      userIdField: 'userId', // Security: validate user ownership
    );
  }

  Future<GoalModel?> getGoalById(String goalId) async {
    return getDocumentById<GoalModel>(
      collectionName: FirestoreConstants.goalsCollection,
      documentId: goalId,
      fromFirestore: (doc) => GoalModel.fromFirestore(doc),
      userIdField: 'userId', // Security: validate user ownership
    );
  }

  Future<void> addFundsToGoal({
    required String goalId,
    required double amount,
    required String fromAccountName,
  }) async {
    final WriteBatch batch = firestore.batch();

    final goalDocRef = _goalsCollection.doc(goalId);
    batch.update(goalDocRef, {'currentAmount': FieldValue.increment(amount)});

    final newTransaction = TransactionModel(
      userId: requiredUserId,
      description: 'Menabung untuk tujuan',
      amount: amount,
      category: 'Tujuan Keuangan',
      account: fromAccountName,
      date: DateTime.now(),
      type: TransactionType.expense,
    );
    final transactionDocRef = _transactionsCollection.doc();
    batch.set(transactionDocRef, newTransaction.toFirestore());

    await batch.commit();
  }
}
