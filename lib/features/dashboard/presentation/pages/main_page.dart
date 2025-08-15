import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../asset/presentation/pages/add_edit_asset_page.dart';
import '../../../debt/presentation/pages/add_edit_debt_page.dart';
import '../../../goals/presentation/pages/add_edit_goal_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../transaction/presentation/pages/add_edit_transaction_page.dart';
import '../../../transaction/presentation/pages/transaction_page.dart';
import 'dashboard_page.dart';

final mainPageProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  final List<Widget> _pages = const [
    DashboardPage(),
    TransactionPage(),
    ReportsPage(),
    SettingsPage(),
  ];

  final List<String> _pageTitles = const [
    'Dashboard',
    'Transaksi',
    'Laporan',
    'Profil',
  ];

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Tambah Transaksi'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const AddEditTransactionPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Tambah Aset'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const AddEditAssetPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.credit_card_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Tambah Utang/Piutang'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const AddEditDebtPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Tambah Tujuan (Goal)'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const AddEditGoalPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainPageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[selectedIndex],
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: IndexedStack(index: selectedIndex, children: _pages),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context,
              ref,
              icon: Icons.dashboard_outlined,
              index: 0,
              label: 'Dashboard',
            ),
            _buildNavItem(
              context,
              ref,
              icon: Icons.receipt_long_outlined,
              index: 1,
              label: 'Transaksi',
            ),
            _buildNavItem(
              context,
              ref,
              icon: Icons.analytics_outlined,
              index: 2,
              label: 'Laporan',
            ),
            _buildNavItem(
              context,
              ref,
              icon: Icons.person_outline,
              index: 3,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required int index,
    required String label,
  }) {
    final selectedIndex = ref.watch(mainPageProvider);
    final isSelected = selectedIndex == index;
    final color =
        isSelected ? Theme.of(context).primaryColor : Colors.grey.shade500;

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () => ref.read(mainPageProvider.notifier).state = index,
      tooltip: label,
    );
  }
}
