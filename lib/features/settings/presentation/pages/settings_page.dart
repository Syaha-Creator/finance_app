import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../asset/presentation/pages/asset_page.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../budget/presentation/pages/budget_page.dart';
import '../../../debt/presentation/pages/debt_page.dart';
import '../../../financial_health/presentation/pages/financial_health_page.dart';
import '../../../goals/presentation/pages/goals_page.dart';
import '../../../transaction/presentation/pages/recurring_transaction_page.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/master_data_expansion_tile.dart';
import '../widgets/settings_group.dart';
import '../widgets/user_profile_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          children: [
            const UserProfileCard(),
            SettingsGroup(
              title: 'PORTOFOLIO SAYA',
              children: [
                _buildEnhancedNavListTile(
                  context,
                  title: 'Aset Saya',
                  subtitle: 'Kelola aset dan investasi',
                  icon: Icons.account_balance_wallet_outlined,
                  page: const AssetPage(),
                  color: AppColors.income,
                ),
                _buildEnhancedNavListTile(
                  context,
                  title: 'Utang & Piutang',
                  subtitle: 'Catat utang dan piutang',
                  icon: Icons.credit_card_outlined,
                  page: const DebtPage(),
                  color: AppColors.warning,
                ),
                _buildEnhancedNavListTile(
                  context,
                  title: 'Tujuan (Goals)',
                  subtitle: 'Set dan capai tujuan finansial',
                  icon: Icons.flag_outlined,
                  page: const GoalsPage(),
                  color: AppColors.accent,
                ),
              ],
            ),
            SettingsGroup(
              title: 'ANALISIS & PERENCANAAN',
              children: [
                _buildEnhancedNavListTile(
                  context,
                  title: 'Atur Anggaran Bulanan',
                  subtitle: 'Kelola budget dan pengeluaran',
                  icon: Icons.calculate_outlined,
                  page: const BudgetPage(),
                  color: AppColors.primary,
                ),
                _buildEnhancedNavListTile(
                  context,
                  title: 'Transaksi Berulang',
                  subtitle: 'Atur transaksi otomatis',
                  icon: Icons.repeat_on_outlined,
                  page: const RecurringTransactionPage(),
                  color: AppColors.secondary,
                ),
                _buildEnhancedNavListTile(
                  context,
                  title: 'Cek Kesehatan Finansial',
                  subtitle: 'Analisis kondisi keuangan',
                  icon: Icons.health_and_safety_outlined,
                  page: const FinancialHealthPage(),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedNavListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget page,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
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
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 18,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedLogoutTile(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.expense.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.expense.withValues(alpha: 0.2),
              width: 1,
            ),
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
          decoration: BoxDecoration(
            color: AppColors.expense.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
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
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
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
