import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum DebtReceivableType { debt, receivable }

enum PaymentStatus { unpaid, paid }

enum DebtType { productive, consumptive }

class DebtReceivableModel extends Equatable {
  final String? id;
  final String userId;
  final DebtReceivableType type;
  final String personName;
  final String description;
  final double amount;
  final DateTime createdAt;
  final DateTime? dueDate;
  final PaymentStatus status;

  final DebtType debtType;
  final double monthlyPayment;

  const DebtReceivableModel({
    this.id,
    required this.userId,
    required this.type,
    required this.personName,
    required this.description,
    required this.amount,
    required this.createdAt,
    this.dueDate,
    this.status = PaymentStatus.unpaid,

    this.debtType = DebtType.consumptive,
    this.monthlyPayment = 0.0,
  });

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

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    personName,
    description,
    amount,
    createdAt,
    dueDate,
    status,
    debtType,
    monthlyPayment,
  ];
}
