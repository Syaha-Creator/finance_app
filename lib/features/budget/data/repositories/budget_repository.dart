import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  BudgetRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  Stream<List<BudgetModel>> getBudgetsForMonth(int month, int year) {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BudgetModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> saveOrUpdateBudget(BudgetModel budget) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User tidak ditemukan. Silakan login ulang.');
    }

    final budgetWithUser = BudgetModel(
      id: budget.id,
      userId: userId,
      categoryName: budget.categoryName,
      amount: budget.amount,
      month: budget.month,
      year: budget.year,
    );

    final query = _firestore
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .where('categoryName', isEqualTo: budget.categoryName)
        .where('month', isEqualTo: budget.month)
        .where('year', isEqualTo: budget.year)
        .limit(1);

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      await _firestore
          .collection('budgets')
          .doc(docId)
          .update(budgetWithUser.toFirestore());
    } else {
      await _firestore.collection('budgets').add(budgetWithUser.toFirestore());
    }
  }
}
