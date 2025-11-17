import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/setting_model.dart';
import '../providers/settings_provider.dart';

class MasterDataExpansionTile extends ConsumerStatefulWidget {
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
  ConsumerState<MasterDataExpansionTile> createState() =>
      _MasterDataExpansionTileState();
}

class _MasterDataExpansionTileState
    extends ConsumerState<MasterDataExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataState = ref.watch(widget.provider);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          onExpansionChanged: (expanded) {
            if (expanded) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primaryLight.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(widget.icon, color: AppColors.primary, size: 22),
          ),
          title: Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
          subtitle: Text(
            'Kelola data ${widget.title.toLowerCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Item count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: dataState.when(
                  data:
                      (items) => Text(
                        '${items.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                  loading:
                      () => const SizedBox(
                        width: 12,
                        height: 12,
                        child: CoreLoadingState(size: 12),
                      ),
                  error:
                      (_, __) => const Text(
                        '0',
                        style: TextStyle(color: AppColors.error),
                      ),
                ),
              ),
              const SizedBox(width: 8),
              // Add button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _showAddItemDialog(context, ref),
                  tooltip: 'Tambah ${widget.title} Baru',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  // Divider with gradient
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          theme.colorScheme.outline.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content with animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: dataState.when(
                            loading: () => _buildLoadingState(context, theme),
                            error:
                                (err, stack) =>
                                    _buildErrorState(context, theme, err),
                            data:
                                (items) =>
                                    _buildDataContent(context, theme, items),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Column(
          children: [
            CoreLoadingState(size: 24),
            SizedBox(height: 12),
            Text('Memuat data...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, Object error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.error_outline, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terjadi Kesalahan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Error: $error',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataContent(
    BuildContext context,
    ThemeData theme,
    List<CategoryModel> items,
  ) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 32,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai tambahkan ${widget.title.toLowerCase()} pertama Anda',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddItemDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Tambah ${widget.title}'),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children:
          items.map((item) {
            return _buildDataChip(context, theme, item);
          }).toList(),
    );
  }

  Widget _buildDataChip(
    BuildContext context,
    ThemeData theme,
    CategoryModel item,
  ) {
    final isDefault = item.isDefault;
    final chipColor = isDefault ? AppColors.secondary : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: chipColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // Show item details or edit dialog
            _showItemDetailsDialog(context, theme, item);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  chipColor.withValues(alpha: 0.1),
                  chipColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: chipColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.star, color: chipColor, size: 12),
                  ),
                if (isDefault) const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: chipColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isDefault) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDeleteConfirmDialog(context, ref, item),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showItemDetailsDialog(
    BuildContext context,
    ThemeData theme,
    CategoryModel item,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Detail ${widget.title}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nama', item.name),
              _buildDetailRow('Status', item.isDefault ? 'Default' : 'Custom'),
              if (item.isDefault)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kategori default tidak dapat dihapus',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_box_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Tambah ${widget.title}'),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nama ${widget.title}',
                hintText: 'Masukkan nama ${widget.title.toLowerCase()}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  widget.icon,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                if (value.trim().length < 2) {
                  return 'Nama minimal 2 karakter';
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              final success = await widget.onAdd(
                                controller.text.trim(),
                              );
                              if (success && dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                                if (context.mounted) {
                                  CoreSnackbar.showSuccess(
                                    context,
                                    '${widget.title} berhasil ditambahkan',
                                  );
                                }
                              } else if (dialogContext.mounted) {
                                CoreSnackbar.showError(
                                  dialogContext,
                                  'Gagal menambah ${widget.title}',
                                );
                              }
                            }
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CoreLoadingState(size: 20),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Hapus ${widget.title}'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apakah Anda yakin ingin menghapus "${item.name}"?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tindakan ini tidak dapat dibatalkan',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  final success = await widget.onDelete(item.id);
                  if (success) {
                    if (context.mounted) {
                      CoreSnackbar.showSuccess(
                        context,
                        '${widget.title} berhasil dihapus',
                      );
                    }
                  } else if (dialogContext.mounted) {
                    CoreSnackbar.showError(
                      dialogContext,
                      'Gagal menghapus ${widget.title}',
                    );
                  }
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
