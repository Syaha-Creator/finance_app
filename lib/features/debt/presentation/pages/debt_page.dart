import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../data/models/debt_receivable_model.dart';
import '../provider/debt_provider.dart';

class DebtPage extends StatelessWidget {
  const DebtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Utang & Piutang'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Utang Saya'), Tab(text: 'Piutang Saya')],
          ),
        ),
        body: const TabBarView(
          children: [
            _DebtList(type: DebtReceivableType.debt),
            _DebtList(type: DebtReceivableType.receivable),
          ],
        ),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (debts) {
        final filteredList = debts.where((d) => d.type == type).toList();
        if (filteredList.isEmpty) {
          final isDebtTab = type == DebtReceivableType.debt;

          // Pesan berbeda untuk tab Utang dan Piutang
          final String title =
              isDebtTab
                  ? 'Hebat, Tidak Ada Utang!'
                  : 'Tidak Ada Catatan Piutang';

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
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final item = filteredList[index];
            return _DebtListItem(debt: item);
          },
        );
      },
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isPaid ? 0.5 : 2,

      color: isPaid ? colorScheme.surface.withAlpha(128) : colorScheme.surface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(isPaid ? 20 : 40),
          child: Icon(
            debt.type == DebtReceivableType.debt
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: isPaid ? Colors.grey : color,
          ),
        ),
        title: Text(
          debt.personName,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            decoration:
                isPaid ? TextDecoration.lineThrough : TextDecoration.none,

            color:
                isPaid
                    ? colorScheme.onSurface.withAlpha(128)
                    : colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          debt.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color:
                isPaid
                    ? colorScheme.onSurface.withAlpha(128)
                    : textTheme.bodySmall?.color,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.currency.format(debt.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isPaid ? Colors.grey : color,
                decoration:
                    isPaid ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            if (debt.dueDate != null)
              Text(
                'Jatuh tempo: ${DateFormat('dd MMM yy', 'id_ID').format(debt.dueDate!)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
        onTap: isPaid ? null : () => _showMarkAsPaidDialog(context, ref, debt),
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
}
