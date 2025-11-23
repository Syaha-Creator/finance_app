import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_decorations.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/async_value_helper.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/asset_model.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_provider.dart';

class AssetPage extends ConsumerWidget {
  const AssetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsyncValue = ref.watch(assetsStreamProvider);
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
            const CustomAppBar(title: 'Aset Saya'),

            // Content
            Expanded(
              child: assetsAsyncValue.when(
                loading: () => const CoreLoadingState(),
                error: (err, stack) => AppErrorWidget(message: err.toString()),
                data: (assets) {
                  if (assets.isEmpty) {
                    return _buildEmptyState(context, theme);
                  }

                  final totalValue = assets.fold<double>(
                    0,
                    (sum, item) => sum + item.value,
                  );

                  return CustomScrollView(
                    slivers: [
                      // Header dengan gradient
                      SliverToBoxAdapter(
                        child: _buildHeader(context, theme, totalValue),
                      ),

                      // Asset statistics
                      SliverToBoxAdapter(
                        child: _buildAssetStatistics(context, theme, assets),
                      ),

                      // Asset list
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final asset = assets[index];
                          return _AssetListItem(asset: asset);
                        }, childCount: assets.length),
                      ),

                      // Bottom padding
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final assetsAsyncValue = ref.watch(assetsStreamProvider);
          return assetsAsyncValue.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (assets) {
              // Hanya tampilkan FAB jika ada data
              if (assets.isNotEmpty) {
                return FloatingActionButton.extended(
                  onPressed: () => context.push('/add-asset'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Aset'),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/asset.json', width: 250, height: 250),
          const SizedBox(height: 20),
          Text(
            'Aset Anda Masih Kosong',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat aset pertamamu untuk melacak kekayaan!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-asset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Aset Pertama'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    double totalValue,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
            AppColors.primaryDark,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
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
            child: const Icon(
              Icons.account_balance_wallet_outlined,
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
                  'Total Nilai Aset',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.currency.format(totalValue),
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
    );
  }

  Widget _buildAssetStatistics(
    BuildContext context,
    ThemeData theme,
    List<AssetModel> assets,
  ) {
    // Hitung statistik aset
    final assetTypes = assets.map((a) => a.type).toSet();
    final totalAssets = assets.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: AppSpacing.paddingAll,
      decoration: AppDecorations.cardDecoration(
        context: context,
        borderRadius: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Aset',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Aset',
                  totalAssets.toString(),
                  Icons.inventory_2_outlined,
                  AppColors.primary,
                  theme,
                ),
              ),
              AppSpacing.widthMD,
              Expanded(
                child: _buildStatItem(
                  context,
                  'Jenis Aset',
                  assetTypes.length.toString(),
                  Icons.category_outlined,
                  AppColors.secondary,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
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
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AssetListItem extends ConsumerWidget {
  final AssetModel asset;
  const _AssetListItem({required this.asset});

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    DialogHelper.showDeleteConfirmation(
      context: context,
      title: 'Konfirmasi Hapus',
      itemName: asset.name,
      onConfirm: () async {
        await ref.read(assetNotifierProvider.notifier).deleteAsset(asset.id!);
        final state = ref.read(assetNotifierProvider);
        if (!context.mounted) return;
        AsyncValueHelper.handleFormResult(
          context: context,
          state: state,
          successMessage: 'Aset berhasil dihapus',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
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
          onTap: () => context.push('/add-asset', extra: {'asset': asset}),
          child: Padding(
            padding: AppSpacing.paddingAll,
            child: Row(
              children: [
                // Icon dan tipe aset
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getAssetTypeColor(
                      asset.type,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAssetTypeIcon(asset.type),
                    color: _getAssetTypeColor(asset.type),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Informasi aset
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assetTypeToString(asset.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Diperbarui: ${AppFormatters.formatRelativeDate(asset.lastUpdatedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nilai aset dan menu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppFormatters.currency.format(asset.value),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.income,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                          context.push('/add-asset', extra: {'asset': asset});
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, ref);
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

  Color _getAssetTypeColor(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return AppColors.success;
      case AssetType.bankAccount:
        return AppColors.primary;
      case AssetType.eWallet:
        return AppColors.secondary;
      case AssetType.stocks:
        return AppColors.accent;
      case AssetType.mutualFunds:
        return AppColors.info;
      case AssetType.crypto:
        return AppColors.warning;
      case AssetType.property:
        return AppColors.primaryDark;
      case AssetType.vehicle:
        return AppColors.secondary;
      case AssetType.other:
        return AppColors.lightTextSecondary;
    }
  }

  IconData _getAssetTypeIcon(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return Icons.attach_money;
      case AssetType.bankAccount:
        return Icons.account_balance;
      case AssetType.eWallet:
        return Icons.account_balance_wallet;
      case AssetType.stocks:
        return Icons.trending_up;
      case AssetType.mutualFunds:
        return Icons.pie_chart;
      case AssetType.crypto:
        return Icons.currency_bitcoin;
      case AssetType.property:
        return Icons.home;
      case AssetType.vehicle:
        return Icons.directions_car;
      case AssetType.other:
        return Icons.category;
    }
  }

}
