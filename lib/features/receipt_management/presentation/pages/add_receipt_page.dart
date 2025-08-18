import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../application/ocr_service.dart';
import '../../data/models/receipt_model.dart';
import '../provider/receipt_provider.dart';

class AddReceiptPage extends ConsumerStatefulWidget {
  const AddReceiptPage({super.key});

  @override
  ConsumerState<AddReceiptPage> createState() => _AddReceiptPageState();
}

class _AddReceiptPageState extends ConsumerState<AddReceiptPage> {
  final _formKey = GlobalKey<FormState>();
  final _merchantNameController = TextEditingController();
  final _merchantAddressController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  File? _selectedImage;
  bool _isProcessing = false;
  bool _isOcrCompleted = false;
  Map<String, dynamic>? _ocrData;

  @override
  void dispose() {
    _merchantNameController.dispose();
    _merchantAddressController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tambah Struk Baru'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Selection Section
            _buildImageSection(),

            const SizedBox(height: 24),

            // OCR Results Section
            if (_isOcrCompleted && _ocrData != null) ...[
              _buildOcrResultsSection(),
              const SizedBox(height: 24),
            ],

            // Form Fields
            _buildFormFields(),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _selectedImage != null ? _saveReceipt : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isProcessing
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Memproses...'),
                        ],
                      )
                      : const Text(
                        'Simpan Struk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto Struk',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            if (_selectedImage != null) ...[
              // Selected Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Process OCR Button
              if (!_isOcrCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processOcr,
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Proses OCR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Change Image Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selectImage,
                  icon: const Icon(Icons.edit),
                  label: const Text('Ganti Foto'),
                ),
              ),
            ] else ...[
              // Image Selection Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOcrResultsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: AppColors.accent, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Hasil OCR',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // OCR Data Display
            if (_ocrData!['merchantName'] != null) ...[
              _buildOcrDataRow('Nama Merchant:', _ocrData!['merchantName']),
            ],
            if (_ocrData!['merchantAddress'] != null) ...[
              _buildOcrDataRow('Alamat:', _ocrData!['merchantAddress']),
            ],
            if (_ocrData!['totalAmount'] != null) ...[
              _buildOcrDataRow(
                'Total:',
                AppFormatters.currency.format(_ocrData!['totalAmount']),
              ),
            ],
            if (_ocrData!['items'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Item:',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...(_ocrData!['items'] as List<String>)
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 2),
                      child: Text(
                        '• $item',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOcrDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Struk',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Merchant Name
            _buildTextField(
              controller: _merchantNameController,
              label: 'Nama Merchant',
              hint: 'Masukkan nama merchant',
              icon: Icons.store,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama merchant harus diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Merchant Address
            _buildTextField(
              controller: _merchantAddressController,
              label: 'Alamat Merchant (Opsional)',
              hint: 'Masukkan alamat merchant',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Amount
            _buildTextField(
              controller: _amountController,
              label: 'Total Amount',
              hint: '0',
              icon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandInputFormatter()],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Total amount harus diisi';
                }
                final amount = double.tryParse(value.replaceAll('.', ''));
                if (amount == null || amount <= 0) {
                  return 'Total amount harus lebih dari 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Notes
            _buildTextField(
              controller: _notesController,
              label: 'Catatan (Opsional)',
              hint: 'Catatan tambahan',
              icon: Icons.note_outlined,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      File? imageFile;
      if (source == ImageSource.camera) {
        imageFile = await OCRService.pickImageFromCamera();
      } else {
        imageFile = await OCRService.pickImageFromGallery();
      }

      if (imageFile != null) {
        if (mounted) {
          setState(() {
            _selectedImage = imageFile;
            _isOcrCompleted = false;
            _ocrData = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

  void _selectImage() {
    _pickImage(ImageSource.gallery);
  }

  Future<void> _processOcr() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final ocrData = await OCRService.processReceiptImage(_selectedImage!);

      if (mounted) {
        setState(() {
          _ocrData = ocrData;
          _isOcrCompleted = true;
          _isProcessing = false;
        });

        // Auto-fill form fields with OCR data
        if (ocrData['merchantName'] != null) {
          _merchantNameController.text = ocrData['merchantName'];
        }
        if (ocrData['merchantAddress'] != null) {
          _merchantAddressController.text = ocrData['merchantAddress'];
        }
        if (ocrData['totalAmount'] != null) {
          _amountController.text = ocrData['totalAmount'].toString();
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OCR berhasil diproses!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memproses OCR: $e')));
      }
    }
  }

  void _saveReceipt() {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final amount = double.parse(_amountController.text.replaceAll('.', ''));

      final receipt = ReceiptModel(
        id: '',
        userId: '',
        imageUrl: '',
        ocrText: _ocrData?['ocrText'],
        merchantName: _merchantNameController.text.trim(),
        merchantAddress:
            _merchantAddressController.text.trim().isEmpty
                ? null
                : _merchantAddressController.text.trim(),
        transactionDate: _ocrData?['transactionDate'] ?? DateTime.now(),
        totalAmount: amount,
        currency: _ocrData?['currency'] ?? 'IDR',
        items:
            _ocrData?['items'] != null
                ? List<String>.from(_ocrData!['items'])
                : null,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        status: ReceiptStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ref
          .read(receiptNotifierProvider.notifier)
          .addReceipt(receipt, _selectedImage!);
      Navigator.pop(context);
    }
  }
}
