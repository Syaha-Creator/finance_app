import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

enum TransactionType { income, expense, transfer }

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    String? id,
    required String userId,
    required String description,
    required double amount,
    required String category,
    required String account,
    required DateTime date,
    required TransactionType type,
    String? goalId,
    double? latitude,
    double? longitude,
    String? locationAddress,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

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
      type: _parseTransactionType(data['type'] as String?),
      goalId: data['goalId'],
      latitude: data['latitude'] != null
          ? (data['latitude'] as num).toDouble()
          : null,
      longitude: data['longitude'] != null
          ? (data['longitude'] as num).toDouble()
          : null,
      locationAddress: data['locationAddress'] as String?,
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

  const TransactionModel._();

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
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
    };
  }
}
