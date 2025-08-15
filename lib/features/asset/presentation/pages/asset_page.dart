import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/models/asset_model.dart';
import '../provider/asset_provider.dart';
import 'add_edit_asset_page.dart';

class AssetPage extends ConsumerWidget {
  const AssetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsyncValue = ref.watch(assetsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Aset Saya')),
      body: assetsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (assets) {
          if (assets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/asset.json', width: 350, height: 350),
                  const SizedBox(height: 16),
                  const Text(
                    'Aset Anda Masih Kosong',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ayo mulai catat aset pertamamu!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final totalValue = assets.fold<double>(
            0,
            (sum, item) => sum + item.value,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: AppColors.primary.withAlpha(26),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Nilai Aset',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppFormatters.currency.format(totalValue),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    return _AssetListItem(asset: asset);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AssetListItem extends ConsumerWidget {
  final AssetModel asset;
  const _AssetListItem({required this.asset});

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus aset "${asset.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(dialogContext);
                  await ref
                      .read(assetControllerProvider.notifier)
                      .deleteAsset(asset.id!);
                  navigator.pop();
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          asset.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(assetTypeToString(asset.type)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppFormatters.currency.format(asset.value),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.income,
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditAssetPage(asset: asset),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context, ref);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
