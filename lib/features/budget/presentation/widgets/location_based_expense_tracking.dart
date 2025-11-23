import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/routes/route_paths.dart';
import '../../data/models/location_expense_model.dart';
import '../widgets/location_expense_item_widget.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Provider untuk mendapatkan expense berdasarkan lokasi
final locationBasedExpensesProvider = FutureProvider<List<LocationExpense>>((
  ref,
) async {
  final userId = ref.watch(authStateChangesProvider).value?.uid;
  if (userId == null) return [];

  final repo = ref.read(transactionRepositoryProvider);
  // Get transactions from stream and convert to list
  final transactionsStream = repo.getTransactionsStream();
  final transactions = await transactionsStream.first;

  // Filter hanya expense dengan lokasi
  final expensesWithLocation =
      transactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                t.latitude != null &&
                t.longitude != null,
          )
          .toList();

  // Group by location (dalam radius 100 meter)
  final Map<String, LocationExpense> locationMap = {};

  for (final transaction in expensesWithLocation) {
    String locationKey =
        transaction.locationAddress ??
        '${transaction.latitude!.toStringAsFixed(4)},${transaction.longitude!.toStringAsFixed(4)}';

    // Cek apakah ada lokasi yang dekat (dalam 100m)
    bool foundNearby = false;
    for (final key in locationMap.keys) {
      final existing = locationMap[key]!;
      if (existing.latitude != null && existing.longitude != null) {
        final distance = Geolocator.distanceBetween(
          existing.latitude!,
          existing.longitude!,
          transaction.latitude!,
          transaction.longitude!,
        );
        if (distance < 100) {
          // Update existing location
          locationMap[key] = LocationExpense(
            locationName: existing.locationName,
            totalAmount: existing.totalAmount + transaction.amount,
            transactionCount: existing.transactionCount + 1,
            latitude: existing.latitude,
            longitude: existing.longitude,
            lastTransactionDate:
                transaction.date.isAfter(existing.lastTransactionDate)
                    ? transaction.date
                    : existing.lastTransactionDate,
          );
          foundNearby = true;
          break;
        }
      }
    }

    if (!foundNearby) {
      // Add new location
      locationMap[locationKey] = LocationExpense(
        locationName: transaction.locationAddress ?? 'Lokasi Tidak Diketahui',
        totalAmount: transaction.amount,
        transactionCount: 1,
        latitude: transaction.latitude,
        longitude: transaction.longitude,
        lastTransactionDate: transaction.date,
      );
    }
  }

  // Sort by total amount descending
  final sortedLocations =
      locationMap.values.toList()
        ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  return sortedLocations;
});

/// Widget untuk menampilkan location-based expense tracking
class LocationBasedExpenseTracking extends ConsumerWidget {
  const LocationBasedExpenseTracking({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expensesAsync = ref.watch(locationBasedExpensesProvider);

    return expensesAsync.when(
      loading:
          () => Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Center(child: CoreLoadingState()),
            ),
          ),
      error:
          (error, stack) => Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Error: $error', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
      data: (expenses) {
        if (expenses.isEmpty) {
          return Card(
            margin:
                EdgeInsets.zero, // Remove default margin to match other cards
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengeluaran dengan lokasi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan lokasi saat mencatat transaksi untuk melihat analisis berdasarkan lokasi',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero, // Remove default margin to match other cards
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengeluaran Berdasarkan Lokasi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${expenses.length} lokasi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...expenses
                    .take(5)
                    .map(
                      (expense) => LocationExpenseItemWidget(
                        expense: expense,
                        showFullDetails: false,
                      ),
                    ),
                if (expenses.length > 5) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.push(RoutePaths.locationExpenseDetail);
                    },
                    child: Text('Lihat Semua (${expenses.length})'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
