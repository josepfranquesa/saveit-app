class Transaction {
  final int id;
  final int userId;
  final int accountId;
  final double amount;
  final String origin;
  final DateTime createdAt;
  final int? subcategoryId;
  final String? subcategoryName;
  final int? objectiveId;
  final String? objectiveName;

  Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.amount,
    required this.origin,
    required this.createdAt,
    this.subcategoryId,
    this.subcategoryName,
    this.objectiveId,
    this.objectiveName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.parse(rawId.toString());
    final rawUserId = json['user_id'];
    final userId = rawUserId is int ? rawUserId : int.parse(rawUserId.toString());
    final rawAccountId = json['account_id'];
    final accountId = rawAccountId is int ? rawAccountId : int.parse(rawAccountId.toString());
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.parse(rawAmount.toString());
    final origin = json['origin'] as String;
    final createdAt = DateTime.parse(json['created_at'] as String);
    int? subcategoryId;
    String? subcategoryName;
    final rawSub = json['subcategory_id'];
    if (rawSub != null) {
      subcategoryId = rawSub is int
          ? rawSub
          : int.parse(rawSub.toString());
      if (json['subcategory'] is Map<String, dynamic>) {
        subcategoryName = json['subcategory']['name'] as String?;
      }
    }
    int? objectiveId;
    String? objectiveName;
    final rawObj = json['objective_id'];
    if (rawObj != null) {
      objectiveId = rawObj is int
          ? rawObj
          : int.parse(rawObj.toString());
      if (json['objective'] is Map<String, dynamic>) {
        objectiveName = json['objective']['title'] as String?;
      }
    }

    return Transaction(
      id: id,
      userId: userId,
      accountId: accountId,
      amount: amount,
      origin: origin,
      createdAt: createdAt,
      subcategoryId: subcategoryId,
      subcategoryName: subcategoryName,
      objectiveId: objectiveId,
      objectiveName: objectiveName,
    );
  }
}
