import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryIcons {
  // Private constructor
  CategoryIcons._();

  static IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'makanan & minuman':
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'tagihan':
        return Icons.receipt_long;
      case 'belanja':
        return Icons.shopping_cart;
      case 'hiburan':
        return Icons.movie;
      case 'kesehatan':
        return Icons.local_hospital;
      case 'gaji':
        return Icons.work;
      case 'bonus':
        return Icons.card_giftcard;
      case 'transfer masuk':
        return Icons.south_west;
      case 'transfer keluar':
        return Icons.north_east;
      default:
        return Icons.category;
    }
  }

  static Color getColorForCategory(String category, bool isIncome) {
    if (isIncome) {
      // Income categories dengan warna yang lebih bervariasi
      switch (category.toLowerCase()) {
        case 'gaji':
          return Colors.blue;
        case 'bonus':
          return Colors.amber;
        case 'investasi':
        case 'dividen':
          return Colors.teal;
        case 'freelance':
        case 'side income':
          return Colors.purple;
        case 'transfer masuk':
          return Colors.indigo;
        case 'hiburan':
        case 'penghasilan lain':
          return Colors.pink;
        default:
          return AppColors.income;
      }
    }

    // Expense categories
    switch (category.toLowerCase()) {
      case 'makanan & minuman':
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.blue;
      case 'tagihan':
        return Colors.red;
      case 'belanja':
        return Colors.purple;
      case 'hiburan':
        return Colors.pink;
      case 'kesehatan':
        return Colors.green;
      default:
        return AppColors.expense;
    }
  }

  // Account icons - optimized dengan pattern matching
  static IconData getIconForAccount(String accountName) {
    final name = accountName.toLowerCase();

    // Bank accounts - check specific banks first, then generic
    const bankKeywords = ['bca', 'mandiri', 'bni', 'bri', 'bank', 'rekening'];
    if (bankKeywords.any((keyword) => name.contains(keyword))) {
      return Icons.account_balance;
    }

    // E-wallet
    const eWalletKeywords = [
      'gopay',
      'go-pay',
      'ovo',
      'dana',
      'linkaja',
      'link aja',
      'shopeepay',
      'shopee pay',
      'ewallet',
      'e-wallet',
      'dompet digital',
    ];
    if (eWalletKeywords.any((keyword) => name.contains(keyword))) {
      return Icons.account_balance_wallet;
    }

    // Cash
    const cashKeywords = ['tunai', 'cash', 'uang tunai'];
    if (cashKeywords.any((keyword) => name.contains(keyword))) {
      return Icons.money;
    }

    // Savings
    const savingsKeywords = ['tabungan', 'saving'];
    if (savingsKeywords.any((keyword) => name.contains(keyword))) {
      return Icons.savings;
    }

    // Investment
    const investmentKeywords = ['investasi', 'investment'];
    if (investmentKeywords.any((keyword) => name.contains(keyword))) {
      return Icons.trending_up;
    }

    // Credit card
    const creditCardKeywords = ['kartu kredit', 'credit card', 'cc'];
    if (creditCardKeywords.any((keyword) => name.contains(keyword))) {
      return Icons.credit_card;
    }

    // Default
    return Icons.account_balance_wallet_outlined;
  }

  // Account colors - optimized dengan pattern matching
  static Color getColorForAccount(String accountName) {
    final name = accountName.toLowerCase();

    // Bank accounts - Blue
    if (name.contains('bank') || name.contains('rekening')) {
      return Colors.blue;
    }

    // E-wallet - Green
    const eWalletKeywords = [
      'gopay',
      'ovo',
      'dana',
      'linkaja',
      'shopeepay',
      'ewallet',
      'e-wallet',
      'dompet digital',
    ];
    if (eWalletKeywords.any((keyword) => name.contains(keyword))) {
      return Colors.green;
    }

    // Cash - Orange
    if (name.contains('tunai') ||
        name.contains('cash') ||
        name.contains('uang tunai')) {
      return Colors.orange;
    }

    // Savings - Teal
    if (name.contains('tabungan') || name.contains('saving')) {
      return Colors.teal;
    }

    // Investment - Purple
    if (name.contains('investasi') || name.contains('investment')) {
      return Colors.purple;
    }

    // Credit card - Red
    if (name.contains('kartu kredit') ||
        name.contains('credit card') ||
        name.contains('cc')) {
      return Colors.red;
    }

    // Default - Primary color
    return AppColors.primary;
  }
}
