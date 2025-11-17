import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';
import '../../../goals/data/models/goal_model.dart';

class OverallScoreGauge extends ConsumerWidget {
  const OverallScoreGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysis = ref.watch(dashboardAnalysisProvider);

    // Calculate overall score based on real data
    final score = _calculateOverallScore(analysis);
    final healthColor = _getHealthColor(score);
    final healthStatus = _getHealthStatus(score);
    final description = _getOverallDescription(score, analysis);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.assessment, color: healthColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skor Keseluruhan',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Evaluasi komprehensif keuangan Anda',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Score Display
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                // Circular Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            score.toStringAsFixed(0),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: healthColor,
                            ),
                          ),
                          Text(
                            '/100',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: healthColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      healthStatus,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOverallScore(DashboardAnalysis analysis) {
    double score = 0.0;
    int factors = 0;

    // Factor 1: Financial Stability (25% weight)
    if (analysis.totalIncome > 0) {
      final stabilityScore = _calculateStabilityScore(analysis);
      score += stabilityScore * 0.25;
      factors++;
    }

    // Factor 2: Budget Management (20% weight)
    if (analysis.budgets.isNotEmpty) {
      final budgetScore = _calculateBudgetScore(analysis);
      score += budgetScore * 0.20;
      factors++;
    }

    // Factor 3: Goals Achievement (20% weight)
    if (analysis.goals.isNotEmpty) {
      final goalScore = _calculateGoalScore(analysis);
      score += goalScore * 0.20;
      factors++;
    }

    // Factor 4: Expense Control (20% weight)
    if (analysis.totalIncome > 0) {
      final expenseScore = _calculateExpenseScore(analysis);
      score += expenseScore * 0.20;
      factors++;
    }

    // Factor 5: Savings Rate (15% weight)
    if (analysis.totalIncome > 0) {
      final savingsScore = _calculateSavingsScore(analysis);
      score += savingsScore * 0.15;
      factors++;
    }

    // Normalize score if no factors were calculated
    if (factors == 0) {
      return 50.0; // Default score
    }

    return score;
  }

  double _calculateStabilityScore(DashboardAnalysis analysis) {
    // Check if income is consistent and expenses are controlled
    if (analysis.totalIncome == 0) return 0.0;

    final expenseRatio = analysis.totalExpense / analysis.totalIncome;
    if (expenseRatio <= 0.7) return 100.0;
    if (expenseRatio <= 0.8) return 80.0;
    if (expenseRatio <= 0.9) return 60.0;
    if (expenseRatio <= 1.0) return 40.0;
    return 20.0;
  }

  double _calculateBudgetScore(DashboardAnalysis analysis) {
    if (analysis.budgets.isEmpty) return 50.0;

    int wellManagedBudgets = 0;
    for (final budget in analysis.budgets) {
      final spentAmount =
          analysis.expenseByCategory[budget.categoryName] ?? 0.0;
      final usagePercentage =
          budget.amount > 0 ? (spentAmount / budget.amount) : 0.0;
      if (usagePercentage <= 0.9) {
        wellManagedBudgets++;
      }
    }
    return (wellManagedBudgets / analysis.budgets.length) * 100;
  }

  double _calculateGoalScore(DashboardAnalysis analysis) {
    if (analysis.goals.isEmpty) return 50.0;

    final averageProgress =
        analysis.goals.fold<double>(
          0.0,
          (sum, goal) => sum + goal.progressPercentage,
        ) /
        analysis.goals.length;
    return averageProgress;
  }

  double _calculateExpenseScore(DashboardAnalysis analysis) {
    if (analysis.totalIncome == 0) return 0.0;

    final expenseRatio = analysis.totalExpense / analysis.totalIncome;
    if (expenseRatio <= 0.6) return 100.0;
    if (expenseRatio <= 0.7) return 90.0;
    if (expenseRatio <= 0.8) return 80.0;
    if (expenseRatio <= 0.9) return 60.0;
    if (expenseRatio <= 1.0) return 40.0;
    return 20.0;
  }

  double _calculateSavingsScore(DashboardAnalysis analysis) {
    if (analysis.totalIncome == 0) return 0.0;

    final savingsRate = analysis.balance / analysis.totalIncome;
    if (savingsRate >= 0.3) return 100.0;
    if (savingsRate >= 0.2) return 80.0;
    if (savingsRate >= 0.1) return 60.0;
    if (savingsRate >= 0) return 40.0;
    return 0.0;
  }

  Color _getHealthColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getHealthStatus(double score) {
    if (score >= 80) return 'Sangat Baik';
    if (score >= 60) return 'Baik';
    return 'Perlu Perbaikan';
  }

  String _getOverallDescription(double score, DashboardAnalysis analysis) {
    if (score >= 80) {
      return 'Skor keseluruhan Anda menunjukkan manajemen keuangan yang sangat baik. Pertahankan kebiasaan positif dan lanjutkan investasi untuk pertumbuhan yang lebih baik.';
    } else if (score >= 60) {
      return 'Skor keseluruhan Anda menunjukkan manajemen keuangan yang baik. Ada beberapa area yang bisa ditingkatkan untuk mencapai kondisi keuangan yang optimal.';
    } else {
      return 'Skor keseluruhan Anda menunjukkan ada beberapa area yang perlu diperbaiki. Fokus pada pengelolaan anggaran, pengendalian pengeluaran, dan peningkatan tabungan.';
    }
  }
}
