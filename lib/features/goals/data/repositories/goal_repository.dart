import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../models/goal_model.dart';

class GoalRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  GoalRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  String get _currentUserId {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Pengguna tidak login.');
    }
    return user.uid;
  }

  CollectionReference get _goalsCollection => _firestore.collection('goals');
  CollectionReference get _transactionsCollection =>
      _firestore.collection('transactions');

  Stream<List<GoalModel>> getGoalsStream() {
    try {
      return _goalsCollection
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('targetDate', descending: false)
          .orderBy(FieldPath.documentId, descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => GoalModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            return <GoalModel>[];
          });
    } catch (e) {
      return Stream.value(<GoalModel>[]);
    }
  }

  Future<void> addGoal(GoalModel goal) async {
    final newGoal = goal.copyWith(
      userId: _currentUserId,
      createdAt: DateTime.now(),
    );
    await _goalsCollection.add(newGoal.toFirestore());
  }

  Future<void> updateGoal(GoalModel goal) async {
    if (goal.id == null) throw Exception('ID Tujuan tidak boleh kosong.');
    await _goalsCollection.doc(goal.id).update(goal.toFirestore());
  }

  Future<void> deleteGoal(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }

  Future<GoalModel?> getGoalById(String goalId) async {
    try {
      final doc = await _goalsCollection.doc(goalId).get();
      if (doc.exists) {
        return GoalModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting goal by ID: $e');
      return null;
    }
  }

  Future<void> addFundsToGoal({
    required String goalId,
    required double amount,
    required String fromAccountName,
  }) async {
    final WriteBatch batch = _firestore.batch();

    final goalDocRef = _goalsCollection.doc(goalId);
    batch.update(goalDocRef, {'currentAmount': FieldValue.increment(amount)});

    final newTransaction = TransactionModel(
      userId: _currentUserId,
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
