import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String summary;
  const SummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
