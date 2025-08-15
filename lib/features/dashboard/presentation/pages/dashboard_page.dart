// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import provider dan widget-widget yang sudah kita buat
import '../providers/dashboard_viewmodel_provider.dart';
import '../widgets/net_worth_trend_card.dart';
import '../widgets/cash_flow_card.dart';
import '../widgets/upcoming_bills_card.dart';
// import '../widgets/dashboard_header.dart'; // Masih nonaktif

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Panggil provider ViewModel kita
    final asyncData = ref.watch(dashboardViewModelProvider);
    final textTheme = Theme.of(context).textTheme;

    // Kita langsung return Widget yang bisa di-scroll, tanpa Scaffold/AppBar
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Terjadi kesalahan saat memuat data:\n$err',
                textAlign: TextAlign.center,
              ),
            ),
          ),
      // Jika data berhasil dimuat, kita bangun UI-nya
      data: (viewModel) {
        return RefreshIndicator(
          onRefresh: () async {
            // Invalidate provider untuk memuat ulang data
            ref.invalidate(dashboardViewModelProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header sementara
              Text(
                'Selamat Datang!',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Berikut ringkasan keuanganmu.',
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Kartu Grafik Kekayaan Bersih
              NetWorthTrendCard(
                netWorth: viewModel.netWorth,
                history: viewModel.netWorthHistory,
              ),
              const SizedBox(height: 16),

              // Kartu Cash Flow Bulanan
              CashFlowCard(cashFlow: viewModel.monthlyCashFlow),
              const SizedBox(height: 16),

              // Kartu Tagihan Akan Datang
              UpcomingBillsCard(bills: viewModel.upcomingBills),
              const SizedBox(height: 24),

              // Menu Akses Cepat yang sudah kita buat sebelumnya
              Text(
                "Akses Cepat",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickAccessButton(
                    icon: Icons.add_card_outlined,
                    label: 'Transaksi',
                    onTap: () {},
                  ),
                  _QuickAccessButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Anggaran',
                    onTap: () {},
                  ),
                  _QuickAccessButton(
                    icon: Icons.pie_chart_outline_rounded,
                    label: 'Laporan',
                    onTap: () {},
                  ),
                  _QuickAccessButton(
                    icon: Icons.savings_outlined,
                    label: 'Tujuan',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Helper widget untuk tombol akses cepat
class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
