import 'package:flutter/material.dart';

class CategoryIcons {
  // Private constructor
  CategoryIcons._();

  static IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'makanan & minuman':
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
        return Icons.wallet;
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
}
