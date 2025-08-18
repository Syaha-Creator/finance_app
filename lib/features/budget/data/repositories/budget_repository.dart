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

  Stream<List<BudgetModel>> getBudgetsForMonth(int month, int year) {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return Stream.value([]);
      }

      final query = _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year);

      return query
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BudgetModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            return <BudgetModel>[];
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> saveOrUpdateBudget(BudgetModel budget) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      final data = budget.toFirestore();

      if (budget.id == null) {
        // Create new budget
        await _firestore.collection('budgets').add(data);
      } else {
        // Update existing budget
        await _firestore.collection('budgets').doc(budget.id).update(data);
      }
    } catch (e) {
      rethrow;
    }
  }
}
