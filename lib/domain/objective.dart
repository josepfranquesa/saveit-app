class Objective {
  final int id;
  final int? userId;
  final int? accountId;
  final int? subcategoryId;
  // ignore: non_constant_identifier_names
  final String? limit_name;
  final String? title;
  final String type;    // "GOAL" o "LIMIT"
  final double amount;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;

  Objective({
    required this.id,
    this.userId,
    this.accountId,
    this.subcategoryId,
    // ignore: non_constant_identifier_names
    this.limit_name,
    this.title,
    required this.type,
    required this.amount,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  
  });

  factory Objective.fromJson(Map<String, dynamic> json) {
    return Objective(
      id: json['id'],
      userId: json['user_id'],
      accountId: json['account_id'],
      subcategoryId: json['subcategory_id'],
      limit_name: json['limit_name'],
      title: json['title'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
