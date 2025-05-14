import 'package:SaveIt/providers/graph_provider.dart';

/// Modelo que representa un gráfico generado en el backend.
class Graphic {
  final int id;
  final int accountId;
  final PeriodType periodType;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> labels;
  final List<double> data;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Graphic({
    required this.id,
    required this.accountId,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.labels,
    required this.data,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Graphic.fromJson(Map<String, dynamic> json) {
    return Graphic(
      id: json['id'] as int,
      accountId: json['account_id'] as int,
      periodType: PeriodType.values.firstWhere(
        (e) => e.toString() == json['periodo'] as String,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      labels: List<String>.from(json['labels'] as List<dynamic>),
      data: (json['data'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }
}
