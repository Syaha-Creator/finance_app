import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

enum GoalStatus { inProgress, completed }

@freezed
class GoalModel with _$GoalModel {
  const factory GoalModel({
    String? id,
    required String userId,
    required String name,
    required double targetAmount,
    @Default(0.0) double currentAmount,
    required DateTime createdAt,
    required DateTime targetDate,
    @Default(GoalStatus.inProgress) GoalStatus status,
  }) = _GoalModel;

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);

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

  const GoalModel._();

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
}

extension GoalModelMetrics on GoalModel {
  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining < 0 ? 0 : remaining;
  }
}
