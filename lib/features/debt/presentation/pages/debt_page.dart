import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../data/models/debt_receivable_model.dart';
import '../provider/debt_provider.dart';
import 'add_edit_debt_page.dart';

class DebtPage extends ConsumerStatefulWidget {
  const DebtPage({super.key});

  @override
  ConsumerState<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends ConsumerState<DebtPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            // Custom App Bar dengan tombol back
            _buildCustomAppBar(context, theme),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCustomTab(
                      context,
                      theme,
                      title: 'Utang Saya',
                      icon: Icons.arrow_upward,
                      isSelected: _selectedTabIndex == 0,
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 0;
                          _tabController.animateTo(0);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCustomTab(
                      context,
                      theme,
                      title: 'Piutang Saya',
                      icon: Icons.arrow_downward,
                      isSelected: _selectedTabIndex == 1,
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 1;
                          _tabController.animateTo(1);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DebtList(type: DebtReceivableType.debt),
                  _DebtList(type: DebtReceivableType.receivable),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditDebtPage()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
    );
  }

  Widget _buildCustomTab(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary
                  : theme.colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Tombol back
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Judul halaman
          Expanded(
            child: Text(
              'Utang & Piutang',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtList extends ConsumerWidget {
  final DebtReceivableType type;
  const _DebtList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsyncValue = ref.watch(debtsStreamProvider);
    final theme = Theme.of(context);

    return debtsAsyncValue.when(
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      error:
          (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $err',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      data: (debts) {
        final filteredList = debts.where((d) => d.type == type).toList();

        if (filteredList.isEmpty) {
          return _buildEmptyState(context, theme, type);
        }

        // Hitung total dan statistik
        final totalAmount = filteredList.fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );
        final paidCount =
            filteredList.where((d) => d.status == PaymentStatus.paid).length;
        final unpaidCount = filteredList.length - paidCount;

        return CustomScrollView(
          slivers: [
            // Summary header
            SliverToBoxAdapter(
              child: _buildSummaryHeader(
                context,
                theme,
                totalAmount,
                paidCount,
                unpaidCount,
              ),
            ),

            // Debt list
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = filteredList[index];
                return _DebtListItem(debt: item);
              }, childCount: filteredList.length),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    DebtReceivableType type,
  ) {
    final isDebtTab = type == DebtReceivableType.debt;
    final String title =
        isDebtTab ? 'Hebat, Tidak Ada Utang!' : 'Tidak Ada Catatan Piutang';
    final String subtitle =
        isDebtTab
            ? 'Pertahankan terus kondisi keuangan yang sehat dan bebas utang.'
            : 'Semua piutang yang perlu ditagih akan muncul di sini.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/debt.json', width: 250, height: 250),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditDebtPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Catatan Pertama'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    ThemeData theme,
    double totalAmount,
    int paidCount,
    int unpaidCount,
  ) {
    final isDebtTab = type == DebtReceivableType.debt;
    final color = isDebtTab ? AppColors.expense : AppColors.income;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isDebtTab ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDebtTab ? 'Total Utang' : 'Total Piutang',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppFormatters.currency.format(totalAmount),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Statistics row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Belum Lunas',
                  unpaidCount.toString(),
                  Icons.schedule,
                  Colors.white,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Sudah Lunas',
                  paidCount.toString(),
                  Icons.check_circle,
                  Colors.white,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DebtListItem extends ConsumerWidget {
  final DebtReceivableModel debt;
  const _DebtListItem({required this.debt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaid = debt.status == PaymentStatus.paid;
    final color =
        debt.type == DebtReceivableType.debt
            ? AppColors.expense
            : AppColors.income;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              isPaid ? null : () => _showMarkAsPaidDialog(context, ref, debt),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon dan status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isPaid ? 0.1 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: isPaid ? 0.2 : 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    debt.type == DebtReceivableType.debt
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: isPaid ? Colors.grey : color,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                // Informasi utang/piutang
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.personName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration:
                              isPaid
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                          color:
                              isPaid
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        debt.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isPaid
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (debt.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Jatuh tempo: ${DateFormat('dd MMM yy', 'id_ID').format(debt.dueDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Jumlah dan menu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.currency.format(debt.amount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPaid ? Colors.grey : color,
                        decoration:
                            isPaid
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isPaid)
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddEditDebtPage(debt: debt),
                              ),
                            );
                          } else if (value == 'delete') {
                            _showDeleteConfirmationDialog(context, ref, debt);
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMarkAsPaidDialog(
    BuildContext context,
    WidgetRef ref,
    DebtReceivableModel debt,
  ) {
    String? selectedAccount;
    final formKey = GlobalKey<FormState>();
    final isPayingDebt = debt.type == DebtReceivableType.debt;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pelunasan'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPayingDebt
                      ? 'Pilih akun yang Anda gunakan untuk membayar utang ini:'
                      : 'Pilih akun di mana Anda menerima pembayaran piutang ini:',
                ),
                const SizedBox(height: 16),

                Consumer(
                  builder: (context, ref, child) {
                    final accountsValue = ref.watch(accountsProvider);
                    return accountsValue.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                      data:
                          (accounts) => DropdownButtonFormField<String>(
                            initialValue: selectedAccount,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Akun',
                            ),
                            items:
                                accounts
                                    .map(
                                      (a) => DropdownMenuItem(
                                        value: a.name,
                                        child: Text(a.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => selectedAccount = v,
                            validator: (v) => v == null ? 'Pilih akun' : null,
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            Consumer(
              builder: (context, innerRef, child) {
                final isLoading = innerRef.watch(debtControllerProvider);
                return ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              final navigator = Navigator.of(dialogContext);
                              final success = await innerRef
                                  .read(debtControllerProvider.notifier)
                                  .markAsPaid(debt, selectedAccount!);

                              if (success) navigator.pop();
                            }
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('LUNAS'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    DebtReceivableModel debt,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus catatan utang/piutang ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            Consumer(
              builder: (context, innerRef, child) {
                final isLoading = innerRef.watch(debtControllerProvider);
                return ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            final navigator = Navigator.of(dialogContext);
                            final success = await innerRef
                                .read(debtControllerProvider.notifier)
                                .deleteDebt(debt.id!);

                            if (success) navigator.pop();
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Hapus'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
