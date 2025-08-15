import 'package:equatable/equatable.dart';

class DashboardSummaryModel extends Equatable {
  final double totalAssets;
  final double totalDebts;
  final double netWorth;

  const DashboardSummaryModel({
    required this.totalAssets,
    required this.totalDebts,
    required this.netWorth,
  });

  @override
  List<Object?> get props => [totalAssets, totalDebts, netWorth];
}
