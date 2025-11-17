import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../provider/receipt_provider.dart';
import '../widgets/receipt_list_item.dart';
import '../widgets/receipt_summary_card.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';

class ReceiptManagementPage extends ConsumerStatefulWidget {
  const ReceiptManagementPage({super.key});

  @override
  ConsumerState<ReceiptManagementPage> createState() =>
      _ReceiptManagementPageState();
}

class _ReceiptManagementPageState extends ConsumerState<ReceiptManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receiptsSummary = ref.watch(receiptsSummaryProvider);
    final pendingReceipts = ref.watch(pendingReceiptsProvider);
    final processedReceipts = ref.watch(processedReceiptsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Manajemen Struk',
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
            Tab(text: 'Diproses'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          receiptsSummary.when(
            data: (summary) => ReceiptSummaryCard(summary: summary),
            loading:
                () => const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            error:
                (error, stack) => Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: $error'),
                  ),
                ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Receipts Tab
                _buildReceiptsList(ref.watch(receiptsProvider)),

                // Pending Receipts Tab
                _buildReceiptsList(pendingReceipts),

                // Processed Receipts Tab
                _buildReceiptsList(processedReceipts),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-receipt'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Struk'),
      ),
    );
  }

  Widget _buildReceiptsList(AsyncValue<List<dynamic>> receiptsAsync) {
    return receiptsAsync.when(
      data: (receipts) {
        if (receipts.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum ada struk',
              subtitle: 'Scan struk pertama Anda',
              action: TextButton.icon(
                onPressed: () => context.push('/add-receipt'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Struk'),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: receipts.length,
          itemBuilder: (context, index) {
            final receipt = receipts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ReceiptListItem(receipt: receipt),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat data struk',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
