class SubCategory {
  final int id;
  final int categoryId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? categoryType;
  final double amountMonth;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryType,
    required this.amountMonth,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount_month'];
    return SubCategory(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categoryType: json['category_type'] as String?,
      amountMonth: rawAmount != null
          ? (rawAmount as num).toDouble()
          : 0.0,
    );
  }
}
