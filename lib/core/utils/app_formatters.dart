import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Hari Ini';
    } else if (date == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    }
  }

  /// Format date as relative time (e.g., "2 hari lalu", "Kemarin")
  ///
  /// Returns relative time string for dates within 7 days, otherwise returns formatted date
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd/MM/yyyy', 'id_ID').format(date);
    }
  }
}
