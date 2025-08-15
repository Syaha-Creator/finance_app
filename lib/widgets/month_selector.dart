import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../features/dashboard/presentation/providers/dashboard_providers.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    final theme = Theme.of(context);

    void changeMonth(int monthIncrement) {
      final newDate = DateTime(
        selectedDate.year,
        selectedDate.month + monthIncrement,
        1,
      );
      ref.read(selectedDateProvider.notifier).state = newDate;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

      color: theme.appBarTheme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(selectedDate),

            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => changeMonth(1),
          ),
        ],
      ),
    );
  }
}
