import 'package:equatable/equatable.dart';

class FinancialRatio extends Equatable {
  final String name;
  final double value;
  final String description;
  final HealthStatus status;
  final String recommendation;

  const FinancialRatio({
    required this.name,
    required this.value,
    required this.description,
    required this.status,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [name, value, description, status, recommendation];
}

enum HealthStatus { sehat, cukup, kurang }

class FinancialHealthAnalysis extends Equatable {
  final double overallScore;
  final HealthStatus overallStatus;
  final List<FinancialRatio> ratios;
  final String summary;

  const FinancialHealthAnalysis({
    required this.overallScore,
    required this.overallStatus,
    required this.ratios,
    required this.summary,
  });

  factory FinancialHealthAnalysis.empty() {
    return const FinancialHealthAnalysis(
      overallScore: 0,
      overallStatus: HealthStatus.cukup,
      ratios: [],
      summary: 'Belum ada data yang cukup untuk dianalisis.',
    );
  }

  @override
  List<Object?> get props => [overallScore, overallStatus, ratios, summary];
}
