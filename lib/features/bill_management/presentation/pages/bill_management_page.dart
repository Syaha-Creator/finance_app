import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_widget.dart';
import '../provider/bill_provider.dart';
import '../widgets/bill_list_item.dart';
import '../widgets/bill_summary_card.dart';
import '../../data/models/bill_model.dart';
import 'add_edit_bill_page.dart';

enum BillFilter { all, pending, overdue, upcoming, paid }

class BillManagementPage extends ConsumerStatefulWidget {
  const BillManagementPage({super.key});

  @override
  ConsumerState<BillManagementPage> createState() => _BillManagementPageState();
}

class _BillManagementPageState extends ConsumerState<BillManagementPage> {
  BillFilter _selectedFilter = BillFilter.all;

  @override
  Widget build(BuildContext context) {
    final billsSummary = ref.watch(billsSummaryProvider);
    final bills = ref.watch(billsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Manajemen Tagihan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary Card
          billsSummary.when(
            data:
                (summary) => BillSummaryCard(
                  summary: summary,
                  onSelect: (selection) {
                    setState(() {
                      switch (selection) {
                        case BillSummarySelection.all:
                          _selectedFilter = BillFilter.all;
                          break;
                        case BillSummarySelection.pending:
                          _selectedFilter = BillFilter.pending;
                          break;
                        case BillSummarySelection.overdue:
                          _selectedFilter = BillFilter.overdue;
                          break;
                        case BillSummarySelection.paid:
                          _selectedFilter = BillFilter.paid;
                          break;
                      }
                    });
                  },
                ),
            loading:
                () => const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            error:
                (error, stack) => AppErrorWidget(
                  title: 'Gagal Memuat Data',
                  message:
                      'Tidak dapat memuat ringkasan tagihan. Silakan coba lagi.',
                  actionLabel: 'Coba Lagi',
                  onAction: () => ref.refresh(billsSummaryProvider),
                ),
          ),

          // Bills List
          Expanded(child: _buildFilteredBillsList(bills)),
        ],
      ),
      floatingActionButton: bills.when(
        data: (billsList) {
          if (billsList.isEmpty) return null;
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditBillPage(),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Tagihan'),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildFilteredBillsList(AsyncValue<List<BillModel>> billsAsync) {
    return billsAsync.when(
      data: (allBills) {
        final filteredBills = _filterBills(allBills);

        if (filteredBills.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          itemCount: filteredBills.length,
          itemBuilder: (context, index) {
            final bill = filteredBills[index];
            return BillListItem(bill: bill);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => AppErrorWidget(
            title: 'Gagal Memuat Data',
            message: 'Tidak dapat memuat daftar tagihan. Silakan coba lagi.',
            actionLabel: 'Coba Lagi',
            onAction: () => ref.refresh(billsProvider),
          ),
    );
  }

  List<BillModel> _filterBills(List<BillModel> allBills) {
    switch (_selectedFilter) {
      case BillFilter.all:
        return allBills;
      case BillFilter.pending:
        return allBills
            .where((bill) => bill.status.toString() == 'BillStatus.pending')
            .toList();
      case BillFilter.overdue:
        return allBills
            .where(
              (bill) =>
                  bill.status.toString() == 'BillStatus.pending' &&
                  bill.dueDate.isBefore(DateTime.now()),
            )
            .toList();
      case BillFilter.upcoming:
        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));
        return allBills
            .where(
              (bill) =>
                  bill.status.toString() == 'BillStatus.pending' &&
                  bill.dueDate.isAfter(now) &&
                  bill.dueDate.isBefore(nextWeek),
            )
            .toList();
      case BillFilter.paid:
        return allBills
            .where((bill) => bill.status.toString() == 'BillStatus.paid')
            .toList();
    }
  }

  Widget _buildEmptyState() {
    String title, message;
    IconData icon;

    switch (_selectedFilter) {
      case BillFilter.all:
        title = 'Belum Ada Tagihan';
        message = 'Tambahkan tagihan pertama Anda untuk memulai';
        icon = Icons.receipt_long_outlined;
        break;
      case BillFilter.pending:
        title = 'Tidak Ada Tagihan Pending';
        message = 'Semua tagihan sudah diproses';
        icon = Icons.schedule;
        break;
      case BillFilter.overdue:
        title = 'Tidak Ada Tagihan Jatuh Tempo';
        message = 'Bagus! Semua tagihan dibayar tepat waktu';
        icon = Icons.warning;
        break;
      case BillFilter.upcoming:
        title = 'Tidak Ada Tagihan Mendatang';
        message = 'Tidak ada tagihan yang akan jatuh tempo';
        icon = Icons.event;
        break;
      case BillFilter.paid:
        title = 'Belum Ada Tagihan Lunas';
        message = 'Tagihan yang sudah dibayar akan muncul di sini';
        icon = Icons.check_circle;
        break;
    }

    return EmptyStateWidget(
      title: title,
      message: message,
      icon: icon,
      actionLabel: _selectedFilter == BillFilter.all ? 'Tambah Tagihan' : null,
      onAction:
          _selectedFilter == BillFilter.all
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditBillPage(),
                  ),
                );
              }
              : null,
      iconColor: AppColors.primary,
    );
  }
}
