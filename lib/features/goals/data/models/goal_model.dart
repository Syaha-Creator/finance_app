import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum GoalStatus { inProgress, completed }

class GoalModel extends Equatable {
  final String? id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime targetDate;
  final GoalStatus status;

  const GoalModel({
    this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdAt,
    required this.targetDate,
    this.status = GoalStatus.inProgress,
  });

  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining < 0 ? 0 : remaining;
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),

      status:
          (data['status'] == 'completed')
              ? GoalStatus.completed
              : GoalStatus.inProgress,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetDate': Timestamp.fromDate(targetDate),

      'status': status == GoalStatus.completed ? 'completed' : 'inProgress',
    };
  }

  GoalModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    GoalStatus? status,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    targetAmount,
    currentAmount,
    createdAt,
    targetDate,
    status,
  ];
}
