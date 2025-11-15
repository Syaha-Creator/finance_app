import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BudgetModel extends Equatable {
  final String? id;
  final String userId;
  final String categoryName;
  final double amount;
  final int month;
  final int year;

  const BudgetModel({
    this.id,
    required this.userId,
    required this.categoryName,
    required this.amount,
    required this.month,
    required this.year,
  });

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

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'categoryName': categoryName,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }

  @override
  List<Object?> get props => [id, userId, categoryName, amount, month, year];
}
