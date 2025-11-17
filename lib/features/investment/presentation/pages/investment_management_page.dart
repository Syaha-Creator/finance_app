import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/investment_provider.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/investment_list_item.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';

class InvestmentManagementPage extends ConsumerStatefulWidget {
  const InvestmentManagementPage({super.key});

  @override
  ConsumerState<InvestmentManagementPage> createState() =>
      _InvestmentManagementPageState();
}

class _InvestmentManagementPageState
    extends ConsumerState<InvestmentManagementPage>
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
    final portfolioSummary = ref.watch(portfolioSummaryProvider);
    final activeInvestments = ref.watch(activeInvestmentsProvider);
    final allInvestments = ref.watch(investmentsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Portfolio Investasi',
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
            Tab(text: 'Overview'),
            Tab(text: 'Aktif'),
            Tab(text: 'Semua'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Portfolio Summary Card
          portfolioSummary.when(
            data: (summary) => PortfolioSummaryCard(summary: summary),
            loading:
                () => const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CoreLoadingState()),
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
                // Overview Tab
                _buildOverviewTab(summary: portfolioSummary),

                // Active Investments Tab
                _buildInvestmentsList(activeInvestments),

                // All Investments Tab
                _buildInvestmentsList(allInvestments),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-investment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Investasi'),
      ),
    );
  }

  Widget _buildOverviewTab({
    required AsyncValue<Map<String, dynamic>> summary,
  }) {
    return summary.when(
      data: (summaryData) {
        final typeBreakdown =
            summaryData['typeBreakdown'] as Map<String, dynamic>?;

        if (typeBreakdown == null || typeBreakdown.isEmpty) {
          return const Center(child: Text('Belum ada data investasi'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Asset Allocation Chart Placeholder
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alokasi Aset',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Chart akan ditampilkan di sini'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Type Breakdown
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Breakdown per Jenis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...typeBreakdown.entries.map((entry) {
                      final data = entry.value as Map<String, dynamic>;
                      final invested = data['invested'] as double;
                      final currentValue = data['currentValue'] as double;
                      final profitLoss = data['profitLoss'] as double;
                      final count = data['count'] as int;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '$count investasi',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rp ${currentValue.toStringAsFixed(0)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${profitLoss >= 0 ? '+' : ''}${profitLoss.toStringAsFixed(0)} (${((profitLoss / invested) * 100).toStringAsFixed(1)}%)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color:
                                          profitLoss >= 0
                                              ? AppColors.success
                                              : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CoreLoadingState()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildInvestmentsList(AsyncValue<List<dynamic>> investmentsAsync) {
    return investmentsAsync.when(
      data: (investments) {
        if (investments.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.trending_up_outlined,
              title: 'Belum ada investasi',
              subtitle: 'Tambahkan investasi pertama Anda',
              action: TextButton.icon(
                onPressed: () => context.push('/add-investment'),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Investasi'),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: investments.length,
          itemBuilder: (context, index) {
            final investment = investments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InvestmentListItem(investment: investment),
            );
          },
        );
      },
      loading: () => const Center(child: CoreLoadingState()),
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
                  'Gagal memuat data investasi',
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
