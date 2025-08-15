import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/setting_model.dart';
import '../providers/settings_provider.dart';

class MasterDataExpansionTile extends ConsumerWidget {
  final String title;
  final IconData icon;
  final AutoDisposeStreamProvider<List<CategoryModel>> provider;
  final Future<bool> Function(String) onAdd;
  final Future<bool> Function(String) onDelete;

  const MasterDataExpansionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.provider,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.watch(provider);
    final theme = Theme.of(context);

    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: IconButton(
        icon: const Icon(Icons.add_box_outlined),
        onPressed: () => _showAddItemDialog(context, ref),
        tooltip: 'Tambah $title Baru',
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              const Divider(),
              dataState.when(
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error: (err, stack) => Text('Error: $err'),
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Belum ada data.'),
                    );
                  }
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        items.map((item) {
                          return Chip(
                            label: Text(item.name),
                            backgroundColor:
                                item.isDefault
                                    ? theme.colorScheme.secondaryContainer
                                    : theme.colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color:
                                  item.isDefault
                                      ? theme.colorScheme.onSecondaryContainer
                                      : theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            onDeleted:
                                item.isDefault
                                    ? null
                                    : () => _showDeleteConfirmDialog(
                                      context,
                                      ref,
                                      item,
                                    ),
                            deleteIconColor: theme
                                .colorScheme
                                .onPrimaryContainer
                                .withAlpha(180),
                            side: BorderSide.none,
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Tambah $title'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Nama $title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            Consumer(
              builder: (_, innerRef, __) {
                final isLoading = innerRef.watch(settingsControllerProvider);
                return ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              final success = await onAdd(
                                controller.text.trim(),
                              );
                              if (success && dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              } else if (dialogContext.mounted) {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menambah $title'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Simpan'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryModel item,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Hapus "$title"'),
            content: Text(
              'Apakah Anda yakin ingin menghapus kategori "${item.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  final success = await onDelete(item.id);
                  if (!success && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus $title'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
