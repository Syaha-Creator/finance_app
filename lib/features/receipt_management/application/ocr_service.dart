import 'dart:io';
import 'package:image_picker/image_picker.dart';

class OCRService {
  static final ImagePicker _picker = ImagePicker();

  // Simulate OCR processing
  static Future<Map<String, dynamic>> processReceiptImage(
    File imageFile,
  ) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate extracted data
    return {
      'merchantName': 'Toko Sejahtera',
      'merchantAddress': 'Jl. Sudirman No. 123, Jakarta',
      'transactionDate': DateTime.now(),
      'totalAmount': 150000.0,
      'currency': 'IDR',
      'items': [
        'Nasi Goreng - Rp 25.000',
        'Es Teh Manis - Rp 8.000',
        'Ayam Goreng - Rp 35.000',
        'Sayur Asem - Rp 12.000',
      ],
      'ocrText': '''
Toko Sejahtera
Jl. Sudirman No. 123, Jakarta
Telp: (021) 1234-5678

Tgl: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
No: INV-001

Nasi Goreng          Rp 25.000
Es Teh Manis         Rp  8.000
Ayam Goreng          Rp 35.000
Sayur Asem           Rp 12.000

Total:               Rp 80.000
PPN 10%:            Rp  8.000
Grand Total:         Rp 88.000

Terima kasih atas kunjungan Anda
      ''',
    };
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Extract amount from text
  static double? extractAmount(String text) {
    // Simple regex to find amount patterns
    final amountRegex = RegExp(r'Rp\s*([\d.,]+)');
    final match = amountRegex.firstMatch(text);

    if (match != null) {
      final amountStr = match.group(1)?.replaceAll('.', '').replaceAll(',', '');
      return double.tryParse(amountStr ?? '');
    }

    return null;
  }

  // Extract date from text
  static DateTime? extractDate(String text) {
    // Simple regex to find date patterns
    final dateRegex = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})');
    final match = dateRegex.firstMatch(text);

    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '');
      final month = int.tryParse(match.group(2) ?? '');
      final year = int.tryParse(match.group(3) ?? '');

      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  // Extract merchant name from text
  static String? extractMerchantName(String text) {
    // Simple logic to extract merchant name (first line after processing)
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.isNotEmpty) {
      final firstLine = lines.first.trim();
      // Skip if it looks like a date or amount
      if (!firstLine.contains('Rp') &&
          !firstLine.contains('/') &&
          firstLine.length > 3) {
        return firstLine;
      }
    }

    return null;
  }
}
