import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/data/base_repository.dart';
import '../models/budget_model.dart';

class BudgetRepository extends BaseRepository {
  BudgetRepository({required super.firestore, required super.firebaseAuth});

  Stream<List<BudgetModel>> getBudgetsForMonth(int month, int year) {
    return createStreamQuery<BudgetModel>(
      collectionName: FirestoreConstants.budgetsCollection,
      fromFirestore: (doc) => BudgetModel.fromFirestore(doc),
      userIdField: 'userId',
      whereConditions: [
        WhereCondition(field: 'month', value: month),
        WhereCondition(field: 'year', value: year),
      ],
    );
  }

  Future<void> saveOrUpdateBudget(BudgetModel budget) async {
    final data = budget.toFirestore();

    if (budget.id == null) {
      // Create new budget
      await addDocument(
        collectionName: FirestoreConstants.budgetsCollection,
        data: data,
        requireUserId: true,
      );
    } else {
      // Update existing budget
      await updateDocument(
        collectionName: FirestoreConstants.budgetsCollection,
        documentId: budget.id!,
        data: data,
        userIdField: 'userId',
      );
    }
  }
}
