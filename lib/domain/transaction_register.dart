class Transaction {
  final int id;
  final int userId;
  final int accountId;
  final int? objectiveId;
  final int? periodicId;
  final int? subcategoryId;
  final double amount;
  final String origin;

  // Fechas (opcional según API)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    this.objectiveId,
    this.periodicId,
    this.subcategoryId,
    required this.amount,
    required this.origin,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      accountId: json['account_id'] as int,
      objectiveId: json['objective_id'] != null ? json['objective_id'] as int : null,
      periodicId: json['periodic_id'] != null ? json['periodic_id'] as int : null,
      subcategoryId: json['subcategory_id'] != null ? json['subcategory_id'] as int : null,
      amount: double.parse(json['amount'].toString()),
      origin: json['origin'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'account_id': accountId,
      'objective_id': objectiveId,
      'periodic_id': periodicId,
      'subcategory_id': subcategoryId,
      'amount': amount,
      'origin': origin,
    };
  }
}
