import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../data/models/ocr_result.dart';

class OCRService {
  static final ImagePicker _picker = ImagePicker();

  // Real OCR processing using Google ML Kit
  static Future<OcrResult> processReceiptImage(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      final String fullText = recognizedText.text;

      // Parse extracted fields from recognized text
      final String? merchantName = extractMerchantName(fullText);
      final DateTime? date = extractDate(fullText);
      final double? amount =
          _extractTotalPreferTotalLines(fullText) ?? extractAmount(fullText);

      // Derive simple list of item-like lines (best-effort)
      final List<String> items = fullText
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .where((l) => _looksLikeItemLine(l))
          .toList(growable: false);

      return OcrResult(
        merchantName: merchantName,
        merchantAddress: null,
        transactionDate: date,
        totalAmount: amount,
        currency: 'IDR',
        items: items.isNotEmpty ? items : null,
        ocrText: fullText,
      );
    } finally {
      try {
        await textRecognizer.close();
      } catch (_) {
        // Ignore close errors (e.g., MissingPluginException during hot restart)
      }
    }
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

  // Try to find a line with keywords first, then extract amount
  static double? _extractTotalPreferTotalLines(String text) {
    final lines = text.split('\n');
    final totalLike = lines.reversed.firstWhere(
      (l) =>
          l.toLowerCase().contains('grand total') ||
          l.toLowerCase().contains('total'),
      orElse: () => '',
    );
    if (totalLike.isEmpty) return null;
    return extractAmount(totalLike);
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

  static bool _looksLikeItemLine(String line) {
    if (line.isEmpty) return false;
    // Heuristic: contains currency or digits with separators and some text
    final bool hasAmountPattern =
        RegExp(r'(rp|idr)', caseSensitive: false).hasMatch(line) ||
        RegExp(r'[\d][\d.,]{2,}').hasMatch(line);
    final bool hasLetters = RegExp(r'[A-Za-z]').hasMatch(line);
    return hasAmountPattern && hasLetters;
  }
}
