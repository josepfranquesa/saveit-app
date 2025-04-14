class SubCategory {
  final int id;
  final int categoryId;
  final String name;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  // Ejemplo de factory constructor para crear una instancia desde JSON
  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
