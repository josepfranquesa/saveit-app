class Category {
  final int id;
  final String name;
  final String type; 
  final DateTime createdAt;
  final DateTime updatedAt;
  final double amountMonth;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.amountMonth,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount_month'];
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      amountMonth: rawAmount != null
          ? (rawAmount as num).toDouble()
          : 0.0,
    );
  }
}
