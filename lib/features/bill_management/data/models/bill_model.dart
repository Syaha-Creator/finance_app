import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BillStatus { pending, paid, overdue, cancelled }

enum BillFrequency { oneTime, monthly, quarterly, yearly }

class BillModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime dueDate;
  final BillStatus status;
  final BillFrequency frequency;
  final DateTime? nextDueDate;
  final DateTime? paidDate;
  final String? notes;
  final bool isRecurring;
  final bool hasReminder;
  final int reminderDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BillModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.dueDate,
    required this.status,
    required this.frequency,
    this.nextDueDate,
    this.paidDate,
    this.notes,
    required this.isRecurring,
    required this.hasReminder,
    required this.reminderDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: BillStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => BillStatus.pending,
      ),
      frequency: BillFrequency.values.firstWhere(
        (e) => e.toString() == data['frequency'],
        orElse: () => BillFrequency.oneTime,
      ),
      nextDueDate:
          data['nextDueDate'] != null
              ? (data['nextDueDate'] as Timestamp).toDate()
              : null,
      paidDate:
          data['paidDate'] != null
              ? (data['paidDate'] as Timestamp).toDate()
              : null,
      notes: data['notes'],
      isRecurring: data['isRecurring'] ?? false,
      hasReminder: data['hasReminder'] ?? false,
      reminderDays: data['reminderDays'] ?? 3,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status.toString(),
      'frequency': frequency.toString(),
      'nextDueDate':
          nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'notes': notes,
      'isRecurring': isRecurring,
      'hasReminder': hasReminder,
      'reminderDays': reminderDays,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BillModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? amount,
    String? category,
    DateTime? dueDate,
    BillStatus? status,
    BillFrequency? frequency,
    DateTime? nextDueDate,
    DateTime? paidDate,
    String? notes,
    bool? isRecurring,
    bool? hasReminder,
    int? reminderDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderDays: reminderDays ?? this.reminderDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    amount,
    category,
    dueDate,
    status,
    frequency,
    nextDueDate,
    paidDate,
    notes,
    isRecurring,
    hasReminder,
    reminderDays,
    createdAt,
    updatedAt,
  ];
}
