import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'transaction_model.dart'; // Import TransactionType

// Enum untuk frekuensi pengulangan
enum RecurringFrequency { daily, weekly, monthly, yearly }

class RecurringTransactionModel extends Equatable {
  final String? id;
  final String userId;
  final String description;
  final double amount;
  final String category;
  final String account;
  final TransactionType type;

  final RecurringFrequency frequency;
  final int dayOfWeek; // 1 (Senin) - 7 (Minggu)
  final int dayOfMonth; // 1 - 31

  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastGeneratedDate; // Kapan terakhir kali transaksi dibuat
  final bool isActive;

  const RecurringTransactionModel({
    this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.category,
    required this.account,
    required this.type,
    required this.frequency,
    this.dayOfWeek = 1,
    this.dayOfMonth = 1,
    required this.startDate,
    this.endDate,
    this.lastGeneratedDate,
    this.isActive = true,
  });

  factory RecurringTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecurringTransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      account: data['account'] ?? '',
      type:
          (data['type'] == 'income')
              ? TransactionType.income
              : TransactionType.expense,
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.name == data['frequency'],
        orElse: () => RecurringFrequency.monthly,
      ),
      dayOfWeek: data['dayOfWeek'] ?? 1,
      dayOfMonth: data['dayOfMonth'] ?? 1,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
      lastGeneratedDate:
          data['lastGeneratedDate'] != null
              ? (data['lastGeneratedDate'] as Timestamp).toDate()
              : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'description': description,
      'amount': amount,
      'category': category,
      'account': account,
      'type': type.name,
      'frequency': frequency.name,
      'dayOfWeek': dayOfWeek,
      'dayOfMonth': dayOfMonth,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'lastGeneratedDate':
          lastGeneratedDate != null
              ? Timestamp.fromDate(lastGeneratedDate!)
              : null,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    description,
    amount,
    frequency,
    startDate,
  ];
}
