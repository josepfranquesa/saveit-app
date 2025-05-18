class Transaction {
  final int id;
  final int userId;
  final int accountId;
  final double amount;
  final String origin;
  final DateTime createdAt;
  final int? subcategoryId;
  final String? nameCategory;    // Extras: solo este campo
  final int? objectiveId;
  final String? objectiveName;
  final int? periodicId;
  final int? periodicInterval;
  final String? periodicUnit;

  Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.amount,
    required this.origin,
    required this.createdAt,
    this.subcategoryId,
    this.nameCategory,           // ajustado
    this.objectiveId,
    this.objectiveName,
    this.periodicId,
    this.periodicInterval,
    this.periodicUnit,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // ID
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.parse(rawId.toString());

    // userId
    final rawUserId = json['user_id'];
    final userId = rawUserId is int
        ? rawUserId
        : int.parse(rawUserId.toString());

    // accountId
    final rawAccountId = json['account_id'];
    final accountId = rawAccountId is int
        ? rawAccountId
        : int.parse(rawAccountId.toString());

    // amount
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.parse(rawAmount.toString());

    // origin
    final origin = json['origin'] as String;

    // createdAt
    final createdAt = DateTime.parse(json['created_at'] as String);

    // subcategoryId + nameCategory
    int? subcategoryId;
    String? nameCategory;
    final rawSub = json['subcategory_id'];
    if (rawSub != null) {
      subcategoryId = rawSub is int
          ? rawSub
          : int.parse(rawSub.toString());
      nameCategory = json['name_category'] as String?;
    }

    // objective
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

    final rawPeriodicId = json['periodic_id'];
    final periodicId = rawPeriodicId != null
        ? (rawPeriodicId is int ? rawPeriodicId : int.parse(rawPeriodicId.toString()))
        : null;
    final periodicInterval = json['periodic_interval'] as int?;
    final periodicUnit = json['periodic_unit'] as String?;

    return Transaction(
      id: id,
      userId: userId,
      accountId: accountId,
      amount: amount,
      origin: origin,
      createdAt: createdAt,
      subcategoryId: subcategoryId,
      nameCategory: nameCategory,
      objectiveId: objectiveId,
      objectiveName: objectiveName,
      periodicId: periodicId,
      periodicInterval: periodicInterval,
      periodicUnit: periodicUnit,
    );
  }
}
