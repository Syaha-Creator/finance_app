import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/models/asset_model.dart';
import '../provider/asset_provider.dart';

class AddEditAssetPage extends ConsumerStatefulWidget {
  final AssetModel? asset;
  const AddEditAssetPage({super.key, this.asset});

  @override
  ConsumerState<AddEditAssetPage> createState() => _AddEditAssetPageState();
}

class _AddEditAssetPageState extends ConsumerState<AddEditAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  AssetType? _selectedType;

  bool get _isEditMode => widget.asset != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final asset = widget.asset!;
      _nameController.text = asset.name;
      final formatter = NumberFormat('#,###', 'id_ID');
      _valueController.text = formatter.format(asset.value);
      _selectedType = asset.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_formKey.currentState!.validate()) {
      final value = double.parse(_valueController.text.replaceAll('.', ''));
      final userId = ref.read(authStateChangesProvider).value?.uid;

      if (userId == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Pengguna tidak ditemukan. Silakan login ulang.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_isEditMode) {
        final updatedAsset = widget.asset!.copyWith(
          name: _nameController.text,
          value: value,
          type: _selectedType,
        );
        final success = await ref
            .read(assetControllerProvider.notifier)
            .updateAsset(updatedAsset);
        if (success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Aset berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          navigator.pop();
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui aset'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final newAsset = AssetModel(
          userId: userId,
          name: _nameController.text,
          type: _selectedType!,
          value: value,
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        );
        final success = await ref
            .read(assetControllerProvider.notifier)
            .addAsset(newAsset);
        if (success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Aset berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          navigator.pop();
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan aset'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(assetControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Aset' : 'Tambah Aset Baru'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dropdown untuk memilih jenis aset
                  DropdownButtonFormField<AssetType>(
                    initialValue: _selectedType,
                    onChanged:
                        (newValue) => setState(() => _selectedType = newValue),
                    decoration: const InputDecoration(labelText: 'Jenis Aset'),
                    validator: (v) => v == null ? 'Pilih jenis aset' : null,
                    items:
                        AssetType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(assetTypeToString(type)),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Aset'),
                    validator:
                        (v) =>
                            (v == null || v.isEmpty)
                                ? 'Nama tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: 'Nilai / Saldo',
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandInputFormatter(),
                    ],
                    validator:
                        (v) =>
                            (v == null || v.isEmpty)
                                ? 'Nilai tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: const Text('SIMPAN'),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
