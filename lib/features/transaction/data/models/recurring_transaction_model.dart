import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction_model.dart'; // Import TransactionType
part 'recurring_transaction_model.freezed.dart';
part 'recurring_transaction_model.g.dart';

// Enum untuk frekuensi pengulangan
enum RecurringFrequency { daily, weekly, monthly, yearly }

@freezed
class RecurringTransactionModel with _$RecurringTransactionModel {
  const factory RecurringTransactionModel({
    String? id,
    required String userId,
    required String description,
    required double amount,
    required String category,
    required String account,
    required TransactionType type,
    required RecurringFrequency frequency,
    @Default(1) int dayOfWeek,
    @Default(1) int dayOfMonth,
    required DateTime startDate,
    DateTime? endDate,
    DateTime? lastGeneratedDate,
    @Default(true) bool isActive,
  }) = _RecurringTransactionModel;

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionModelFromJson(json);

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

  const RecurringTransactionModel._();

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
}
