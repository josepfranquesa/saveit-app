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
      id: json['id'] ?? 0, // Si no viene 'id', asigna 0
      title: json['title'] ?? 'Sin título', // Valor por defecto si es null
      host: json['host'] ?? 0, // Valor por defecto para host
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0, // Maneja null
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(), // Si falta, toma la fecha actual
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }
}
