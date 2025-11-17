import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_model.freezed.dart';
part 'budget_model.g.dart';

@freezed
class BudgetModel with _$BudgetModel {
  const factory BudgetModel({
    String? id,
    required String userId,
    required String categoryName,
    required double amount,
    required int month,
    required int year,
  }) = _BudgetModel;

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      month: data['month'] ?? 0,
      year: data['year'] ?? 0,
    );
  }

  const BudgetModel._();

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'categoryName': categoryName,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }
}
