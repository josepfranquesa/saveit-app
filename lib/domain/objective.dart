class Objective {
  final int id;
  final int? userId;
  final int? accountId;
  final int? subcategoryId;
  final String type;    // "GOAL" o "LIMIT"
  final double amount;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  Objective({
    required this.id,
    this.userId,
    this.accountId,
    this.subcategoryId,
    required this.type,
    required this.amount,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Objective.fromJson(Map<String, dynamic> json) {
    return Objective(
      id: json['id'],
      userId: json['user_id'],
      accountId: json['account_id'],
      subcategoryId: json['subcategory_id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
