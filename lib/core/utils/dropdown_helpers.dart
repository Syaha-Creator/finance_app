import 'package:flutter/material.dart';
import 'category_icons.dart';
import '../../../features/settings/data/models/setting_model.dart';

/// Helper extensions dan functions untuk membuat dropdown items
/// Mengurangi duplikasi kode dan meningkatkan maintainability

/// Extension untuk CategoryModel untuk membuat dropdown items dengan icon
extension CategoryModelDropdown on CategoryModel {
  /// Membuat DropdownMenuItem untuk kategori dengan icon dan color
  DropdownMenuItem<String> toDropdownItem({required bool isIncome}) {
    return DropdownMenuItem(
      value: name,
      child: Row(
        children: [
          Icon(
            CategoryIcons.getIconForCategory(name),
            color: CategoryIcons.getColorForCategory(name, isIncome),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
    );
  }
}

/// Extension untuk CategoryModel untuk membuat dropdown items untuk akun
extension AccountModelDropdown on CategoryModel {
  /// Membuat DropdownMenuItem untuk akun dengan icon dan color
  DropdownMenuItem<String> toAccountDropdownItem() {
    return DropdownMenuItem(
      value: name,
      child: Row(
        children: [
          Icon(
            CategoryIcons.getIconForAccount(name),
            color: CategoryIcons.getColorForAccount(name),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(name),
        ],
      ),
    );
  }
}

/// Helper functions untuk membuat dropdown items
class DropdownItemHelpers {
  DropdownItemHelpers._();

  /// Membuat list DropdownMenuItem untuk kategori
  static List<DropdownMenuItem<String>> createCategoryItems(
    List<CategoryModel> categories, {
    required bool isIncome,
  }) {
    return categories.map((c) => c.toDropdownItem(isIncome: isIncome)).toList();
  }

  /// Membuat list DropdownMenuItem untuk akun
  static List<DropdownMenuItem<String>> createAccountItems(
    List<CategoryModel> accounts,
  ) {
    return accounts.map((a) => a.toAccountDropdownItem()).toList();
  }

  /// Membuat DropdownMenuItem untuk kategori dari string
  static DropdownMenuItem<String> createCategoryItemFromString(
    String category, {
    required bool isIncome,
  }) {
    return DropdownMenuItem(
      value: category,
      child: Row(
        children: [
          Icon(
            CategoryIcons.getIconForCategory(category),
            color: CategoryIcons.getColorForCategory(category, isIncome),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(category),
        ],
      ),
    );
  }

  /// Membuat DropdownMenuItem untuk akun dari string
  static DropdownMenuItem<String> createAccountItemFromString(String account) {
    return DropdownMenuItem(
      value: account,
      child: Row(
        children: [
          Icon(
            CategoryIcons.getIconForAccount(account),
            color: CategoryIcons.getColorForAccount(account),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(account),
        ],
      ),
    );
  }
}

