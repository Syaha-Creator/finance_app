import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, transfer }

class TransactionModel extends Equatable {
  final String? id;
  final String userId;
  final String description;
  final double amount;
  final String category;
  final String account;
  final DateTime date;
  final TransactionType type;
  final String? goalId;

  const TransactionModel({
    this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.category,
    required this.account,
    required this.date,
    required this.type,
    this.goalId,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'Lainnya',
      account: data['account'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      type: _parseTransactionType(data['type']),
      goalId: data['goalId'],
    );
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'description': description,
      'amount': amount,
      'category': category,
      'account': account,
      'date': Timestamp.fromDate(date),
      'type': type.name,
      'goalId': goalId,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    String? category,
    String? account,
    DateTime? date,
    TransactionType? type,
    String? goalId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      account: account ?? this.account,
      date: date ?? this.date,
      type: type ?? this.type,
      goalId: goalId ?? this.goalId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    description,
    amount,
    category,
    account,
    date,
    type,
    goalId,
  ];
}
