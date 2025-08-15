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
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          const UserProfileCard(),
          SettingsGroup(
            title: 'PORTOFOLIO SAYA',
            children: [
              _buildNavListTile(
                context,
                title: 'Aset Saya',
                icon: Icons.account_balance_wallet_outlined,
                page: const AssetPage(),
              ),
              const Divider(height: 1, indent: 56),
              _buildNavListTile(
                context,
                title: 'Utang & Piutang',
                icon: Icons.credit_card_outlined,
                page: const DebtPage(),
              ),
              const Divider(height: 1, indent: 56),
              _buildNavListTile(
                context,
                title: 'Tujuan (Goals)',
                icon: Icons.flag_outlined,
                page: const GoalsPage(),
              ),
            ],
          ),
          SettingsGroup(
            title: 'ANALISIS & PERENCANAAN',
            children: [
              _buildNavListTile(
                context,
                title: 'Atur Anggaran Bulanan',
                icon: Icons.calculate_outlined,
                page: const BudgetPage(),
              ),
              const Divider(height: 1, indent: 56),
              _buildNavListTile(
                context,
                title: 'Transaksi Berulang',
                icon: Icons.repeat_on_outlined,
                page: const RecurringTransactionPage(),
              ),
              const Divider(height: 1, indent: 56),
              _buildNavListTile(
                context,
                title: 'Cek Kesehatan Finansial',
                icon: Icons.health_and_safety_outlined,
                page: const FinancialHealthPage(),
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
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.expense),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.expense),
                ),
                onTap: () async {
                  final bool? confirmLogout = await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin keluar?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirmLogout == true) {
                    ref.read(authControllerProvider.notifier).signOut();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
