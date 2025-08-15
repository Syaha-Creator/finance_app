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

  const TransactionModel({
    this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.category,
    required this.account,
    required this.date,
    required this.type,
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
    };
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
  ];
}
