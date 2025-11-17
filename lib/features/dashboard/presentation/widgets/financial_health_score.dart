import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';
import '../../../goals/data/models/goal_model.dart';

class FinancialHealthScore extends ConsumerWidget {
  const FinancialHealthScore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysis = ref.watch(dashboardAnalysisProvider);

    // Calculate financial health score based on real data
    final score = _calculateFinancialHealthScore(analysis);
    final healthColor = _getHealthColor(score);
    final healthStatus = _getHealthStatus(score);
    final description = _getHealthDescription(score, analysis);

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
                  child: Icon(Icons.favorite, color: healthColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skor Kesehatan Keuangan',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Evaluasi kondisi keuangan Anda',
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

  double _calculateFinancialHealthScore(DashboardAnalysis analysis) {
    double score = 0.0;
    int factors = 0;

    // Factor 1: Savings Rate (30% weight)
    if (analysis.totalIncome > 0) {
      final savingsRate = analysis.balance / analysis.totalIncome;
      if (savingsRate >= 0.3) {
        score += 30;
      } else if (savingsRate >= 0.2) {
        score += 25;
      } else if (savingsRate >= 0.1) {
        score += 20;
      } else if (savingsRate >= 0) {
        score += 10;
      } else {
        score += 0;
      }
      factors++;
    }

    // Factor 2: Expense Control (25% weight)
    if (analysis.totalIncome > 0) {
      final expenseRatio = analysis.totalExpense / analysis.totalIncome;
      if (expenseRatio <= 0.7) {
        score += 25;
      } else if (expenseRatio <= 0.8) {
        score += 20;
      } else if (expenseRatio <= 0.9) {
        score += 15;
      } else if (expenseRatio <= 1.0) {
        score += 10;
      } else {
        score += 0;
      }
      factors++;
    }

    // Factor 3: Budget Management (20% weight)
    if (analysis.budgets.isNotEmpty) {
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
      final budgetScore = (wellManagedBudgets / analysis.budgets.length) * 20;
      score += budgetScore;
      factors++;
    }

    // Factor 4: Goals Progress (15% weight)
    if (analysis.goals.isNotEmpty) {
      final averageProgress =
          analysis.goals.fold<double>(
            0.0,
            (sum, goal) => sum + goal.progressPercentage,
          ) /
          analysis.goals.length;
      final goalScore = (averageProgress / 100) * 15;
      score += goalScore;
      factors++;
    }

    // Factor 5: Income Stability (10% weight)
    if (analysis.totalIncome > 0) {
      score += 10; // Simplified for now
      factors++;
    }

    // Normalize score if no factors were calculated
    if (factors == 0) {
      return 50.0; // Default score
    }

    return score;
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

  String _getHealthDescription(double score, DashboardAnalysis analysis) {
    if (score >= 80) {
      return 'Skor Anda menunjukkan kondisi keuangan yang sangat baik. Pertahankan kebiasaan menabung dan kelola pengeluaran dengan bijak.';
    } else if (score >= 60) {
      return 'Skor Anda menunjukkan kondisi keuangan yang baik. Ada beberapa area yang bisa ditingkatkan untuk mencapai kesehatan keuangan yang optimal.';
    } else {
      return 'Skor Anda menunjukkan ada beberapa area yang perlu diperbaiki. Fokus pada menabung lebih banyak dan mengontrol pengeluaran.';
    }
  }
}
