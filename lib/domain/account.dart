class Account {
  final int id;
  final String title;
  final int host;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.title,
    required this.host,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      title: json['title'],
      host: json['host'],
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
