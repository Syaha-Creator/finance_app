import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_widget.dart';
import '../provider/bill_provider.dart';
import '../widgets/bill_list_item.dart';
import '../widgets/bill_summary_card.dart';
import 'add_edit_bill_page.dart';

class BillManagementPage extends ConsumerStatefulWidget {
  const BillManagementPage({super.key});

  @override
  ConsumerState<BillManagementPage> createState() => _BillManagementPageState();
}

class _BillManagementPageState extends ConsumerState<BillManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billsSummary = ref.watch(billsSummaryProvider);
    final pendingBills = ref.watch(pendingBillsProvider);
    final overdueBills = ref.watch(overdueBillsProvider);
    final upcomingBills = ref.watch(upcomingBillsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Manajemen Tagihan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pending'),
            Tab(text: 'Jatuh Tempo'),
            Tab(text: 'Mendatang'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          billsSummary.when(
            data: (summary) => BillSummaryCard(summary: summary),
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

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Bills Tab
                _buildBillsList(ref.watch(billsProvider)),

                // Pending Bills Tab
                _buildBillsList(pendingBills),

                // Overdue Bills Tab
                _buildBillsList(overdueBills),

                // Upcoming Bills Tab
                _buildBillsList(upcomingBills),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditBillPage()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tagihan'),
      ),
    );
  }

  Widget _buildBillsList(AsyncValue<List<dynamic>> billsAsync) {
    return billsAsync.when(
      data: (bills) {
        if (bills.isEmpty) {
          return EmptyStateWidget(
            title: 'Belum Ada Tagihan',
            message: 'Tambahkan tagihan pertama Anda untuk memulai',
            icon: Icons.receipt_long_outlined,
            actionLabel: 'Tambah Tagihan',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditBillPage(),
                ),
              );
            },
            iconColor: AppColors.primary,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            final bill = bills[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BillListItem(bill: bill),
            );
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
}
