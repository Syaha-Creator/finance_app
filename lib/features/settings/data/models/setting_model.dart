class CategoryModel {
  final String id;
  final String name;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    this.isDefault = false,
  });
}
