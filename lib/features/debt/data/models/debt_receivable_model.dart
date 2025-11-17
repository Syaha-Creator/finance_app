import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'debt_receivable_model.freezed.dart';
part 'debt_receivable_model.g.dart';

enum DebtReceivableType { debt, receivable }

enum PaymentStatus { unpaid, paid }

enum DebtType { productive, consumptive }

@freezed
class DebtReceivableModel with _$DebtReceivableModel {
  const factory DebtReceivableModel({
    String? id,
    required String userId,
    required DebtReceivableType type,
    required String personName,
    required String description,
    required double amount,
    required DateTime createdAt,
    DateTime? dueDate,
    @Default(PaymentStatus.unpaid) PaymentStatus status,

    @Default(DebtType.consumptive) DebtType debtType,
    @Default(0.0) double monthlyPayment,
  }) = _DebtReceivableModel;

  factory DebtReceivableModel.fromJson(Map<String, dynamic> json) =>
      _$DebtReceivableModelFromJson(json);

  factory DebtReceivableModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DebtReceivableModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type:
          (data['type'] == 'debt')
              ? DebtReceivableType.debt
              : DebtReceivableType.receivable,
      personName: data['personName'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate:
          data['dueDate'] != null
              ? (data['dueDate'] as Timestamp).toDate()
              : null,
      status:
          (data['status'] == 'paid')
              ? PaymentStatus.paid
              : PaymentStatus.unpaid,

      debtType:
          (data['debtType'] == 'productive')
              ? DebtType.productive
              : DebtType.consumptive,
      monthlyPayment: (data['monthlyPayment'] ?? 0.0).toDouble(),
    );
  }

  const DebtReceivableModel._();

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type == DebtReceivableType.debt ? 'debt' : 'receivable',
      'personName': personName,
      'description': description,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'status': status == PaymentStatus.paid ? 'paid' : 'unpaid',

      'debtType':
          debtType == DebtType.productive ? 'productive' : 'consumptive',
      'monthlyPayment': monthlyPayment,
    };
  }

}
