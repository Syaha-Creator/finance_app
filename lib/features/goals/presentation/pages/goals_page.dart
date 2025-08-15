import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/models/goal_model.dart';
import '../providers/goal_provider.dart';
import 'add_edit_goal_page.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tujuan Saya')),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/goal.json', width: 350, height: 350),
                  const SizedBox(height: 16),
                  const Text(
                    'Anda belum punya tujuan.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ayo buat tujuan keuangan pertamamu!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          // --- Urutkan daftar: yang belum selesai di atas ---
          goals.sort((a, b) {
            if (a.status == b.status) return 0;
            return a.status == GoalStatus.inProgress ? -1 : 1;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalListItem(goal: goal);
            },
          );
        },
      ),
    );
  }
}

class _GoalListItem extends ConsumerWidget {
  final GoalModel goal;
  const _GoalListItem({required this.goal});

  // --- Dialog Konfirmasi Hapus ---
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Hapus Tujuan'),
            content: Text(
              'Apakah Anda yakin ingin menghapus tujuan "${goal.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  ref
                      .read(goalControllerProvider.notifier)
                      .deleteGoal(goal.id!);
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // --- Fungsi untuk Menandai Selesai ---
  void _markAsComplete(WidgetRef ref) {
    final updatedGoal = goal.copyWith(status: GoalStatus.completed);
    ref.read(goalControllerProvider.notifier).updateGoal(updatedGoal);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCompleted = goal.status == GoalStatus.completed;
    final canBeCompleted = goal.progressPercentage >= 1.0 && !isCompleted;

    return Card(
      // --- Ubah Tampilan Kartu Jika Selesai ---
      color: isCompleted ? AppColors.income.withAlpha(30) : theme.cardColor,
      elevation: isCompleted ? 0 : 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isCompleted
                              ? theme.textTheme.bodySmall?.color
                              : theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                // --- Tombol Edit & Hapus ---
                if (!isCompleted)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditGoalPage(goal: goal),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, ref);
                      }
                    },
                  )
                else
                  const Icon(Icons.check_circle, color: AppColors.income),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: goal.progressPercentage,
              backgroundColor: theme.dividerColor,
              color: AppColors.primary,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terkumpul: ${AppFormatters.currency.format(goal.currentAmount)}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Target: ${AppFormatters.currency.format(goal.targetAmount)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Target: ${DateFormat('dd MMMM yyyy', 'id_ID').format(goal.targetDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),

            // --- Tampilkan Tombol Jika Bisa Diselesaikan ---
            if (canBeCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsComplete(ref),
                    icon: const Icon(Icons.check),
                    label: const Text('Tandai Telah Tercapai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.income,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
