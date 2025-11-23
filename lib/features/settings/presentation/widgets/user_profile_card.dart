import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../asset/presentation/providers/asset_provider.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

class UserProfileCard extends ConsumerWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileStreamProvider);

    // Get displayName: prefer Firestore, fallback to Firebase Auth, then default
    final displayName = userProfileAsync.value?.displayName ??
        user?.displayName ??
        'Pengguna';
    
    final profile = userProfileAsync.value;

    // Watch real data from providers
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final assetsAsync = ref.watch(assetsStreamProvider);
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.primaryDark,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Picture & Basic Info
            Row(
              children: [
                // Enhanced Profile Picture
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    backgroundImage:
                        user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                    child:
                        user?.photoURL == null
                            ? Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white.withValues(alpha: 0.9),
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Tidak ada email',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (profile?.profession != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile!.profession!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if (profile?.city != null || profile?.country != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              [
                                profile?.city,
                                profile?.country,
                              ].where((e) => e != null).join(', '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Edit Profile Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/edit-profile'),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Edit Profil',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Stats Row with Real Data
            Row(
              children: [
                Expanded(
                  child: _buildQuickStat(
                    context,
                    'Transaksi',
                    transactionsAsync.when(
                      data: (transactions) => transactions.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickStat(
                    context,
                    'Aset',
                    assetsAsync.when(
                      data: (assets) => assets.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickStat(
                    context,
                    'Goals',
                    goalsAsync.when(
                      data: (goals) => goals.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.flag_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
