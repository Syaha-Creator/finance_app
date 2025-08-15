import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';

class UserProfileCard extends ConsumerWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,

            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child:
                user?.photoURL == null
                    ? Icon(
                      Icons.person,
                      size: 30,
                      color: theme.colorScheme.onSurfaceVariant,
                    )
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Pengguna',

                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  user?.email ?? 'Tidak ada email',

                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
