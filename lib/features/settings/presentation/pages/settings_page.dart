import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_decorations.dart';
import '../../../../core/utils/app_spacing.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/master_data_expansion_tile.dart';
import '../widgets/settings_group.dart';
import '../widgets/user_profile_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      children: [
        const UserProfileCard(),
        SettingsGroup(
          title: 'PORTOFOLIO SAYA',
          children: [
            _buildGoNavListTile(
              context,
              title: 'Aset Saya',
              subtitle: 'Kelola aset dan investasi',
              icon: Icons.account_balance_wallet_outlined,
              route: RoutePaths.assets,
              color: AppColors.income,
            ),
            _buildGoNavListTile(
              context,
              title: 'Utang & Piutang',
              subtitle: 'Catat utang dan piutang',
              icon: Icons.credit_card_outlined,
              route: RoutePaths.debt,
              color: AppColors.warning,
            ),
            _buildGoNavListTile(
              context,
              title: 'Tujuan (Goals)',
              subtitle: 'Set dan capai tujuan finansial',
              icon: Icons.flag_outlined,
              route: RoutePaths.goals,
              color: AppColors.accent,
            ),
          ],
        ),
        SettingsGroup(
          title: 'ANALISIS & PERENCANAAN',
          children: [
            _buildGoNavListTile(
              context,
              title: 'Atur Anggaran Bulanan',
              subtitle: 'Kelola budget dan pengeluaran',
              icon: Icons.calculate_outlined,
              route: RoutePaths.budget,
              color: AppColors.primary,
            ),
            _buildGoNavListTile(
              context,
              title: 'Transaksi Berulang',
              subtitle: 'Atur transaksi otomatis',
              icon: Icons.repeat_on_outlined,
              route: RoutePaths.recurringTransactions,
              color: AppColors.secondary,
            ),
            _buildGoNavListTile(
              context,
              title: 'Cek Kesehatan Finansial',
              subtitle: 'Analisis kondisi keuangan',
              icon: Icons.health_and_safety_outlined,
              route: RoutePaths.financialHealth,
              color: AppColors.success,
            ),
          ],
        ),
        SettingsGroup(
          title: 'MANAJEMEN DATA MASTER',
          children: [
            MasterDataExpansionTile(
              title: 'Kategori Pengeluaran',
              icon: Icons.outbox_rounded,
              provider: expenseCategoriesProvider,
              onAdd:
                  (name) => ref
                      .read(settingsControllerProvider.notifier)
                      .addExpenseCategory(name),
              onDelete:
                  (docId) => ref
                      .read(settingsControllerProvider.notifier)
                      .deleteExpenseCategory(docId),
            ),
            MasterDataExpansionTile(
              title: 'Kategori Pemasukan',
              icon: Icons.inbox_rounded,
              provider: incomeCategoriesProvider,
              onAdd:
                  (name) => ref
                      .read(settingsControllerProvider.notifier)
                      .addIncomeCategory(name),
              onDelete:
                  (docId) => ref
                      .read(settingsControllerProvider.notifier)
                      .deleteIncomeCategory(docId),
            ),
            MasterDataExpansionTile(
              title: 'Akun',
              icon: Icons.account_balance_wallet_outlined,
              provider: accountsProvider,
              onAdd:
                  (name) => ref
                      .read(settingsControllerProvider.notifier)
                      .addAccount(name),
              onDelete:
                  (docId) => ref
                      .read(settingsControllerProvider.notifier)
                      .deleteAccount(docId),
            ),
          ],
        ),
        SettingsGroup(
          title: 'AKUN',
          children: [_buildEnhancedLogoutTile(context, ref)],
        ),
        AppSpacing.spaceLG,
      ],
    );
  }

  Widget _buildGoNavListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: AppDecorations.cardDecoration(
        context: context,
        borderRadius: 16.0,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: AppDecorations.iconContainerDecoration(
            color: color,
            borderRadius: 12.0,
            alpha: 0.1,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: AppDecorations.iconContainerDecoration(
            color: theme.colorScheme.outline,
            borderRadius: 8.0,
            alpha: 0.1,
          ),
          child: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 18,
          ),
        ),
        onTap: () => context.push(route),
      ),
    );
  }

  Widget _buildEnhancedLogoutTile(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
      decoration: AppDecorations.cardDecoration(
        context: context,
        borderRadius: 16.0,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: AppDecorations.iconContainerDecoration(
            color: AppColors.expense,
            borderRadius: 12.0,
            alpha: 0.1,
          ),
          child: Icon(Icons.logout, color: AppColors.expense, size: 22),
        ),
        title: Text(
          'Logout',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.expense,
          ),
        ),
        subtitle: Text(
          'Keluar dari aplikasi',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.expense.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: AppDecorations.iconContainerDecoration(
            color: AppColors.expense,
            borderRadius: 8.0,
            alpha: 0.1,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.expense,
            size: 16,
          ),
        ),
        onTap: () async {
          final bool? confirmLogout = await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconContainerDecoration(
                          color: AppColors.expense,
                          borderRadius: 8.0,
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.logout,
                          color: AppColors.expense,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Konfirmasi Logout'),
                    ],
                  ),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
          );
          if (confirmLogout == true) {
            ref.read(authControllerProvider.notifier).signOut();
          }
        },
      ),
    );
  }
}
