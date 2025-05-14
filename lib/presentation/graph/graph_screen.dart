import 'package:SaveIt/domain/graphic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/account_list_provider.dart';
import 'package:SaveIt/providers/savings_provider.dart';
import 'package:SaveIt/providers/graph_provider.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/category.dart';
import 'package:SaveIt/domain/subcategory.dart';

class GraphScreen extends StatefulWidget {
  static const String id = 'graph_screen';
  const GraphScreen({Key? key}) : super(key: key);

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  bool _didFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      _didFetch = true;
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<AccountListProvider>().fetchAccounts(userId);
        context.read<SavingsProvider>().getAccountsForUser(context);
      }
    }
  }

  String _periodLabel(PeriodType type) {
    switch (type) {
      case PeriodType.day:
        return 'Diario';
      case PeriodType.week:
        return 'Semanal';
      case PeriodType.month:
        return 'Mensual';
      case PeriodType.quarter:
        return 'Trimestral';
      case PeriodType.year:
        return 'Anual';
      case PeriodType.custom:
        return 'Personalizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gráficos')),
      body: Column(
        children: [
          // Selector de cuenta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer2<AccountListProvider, GraphProvider>(
              builder: (_, ap, gp, __) {
                if (ap.isLoading) return const Center(child: CircularProgressIndicator());
                return DropdownButtonFormField<Account>(
                  value: gp.selectedAccount,
                  decoration: const InputDecoration(
                    labelText: 'Cuenta',
                    border: OutlineInputBorder(),
                  ),
                  items: ap.accounts.map((acct) => DropdownMenuItem(
                    value: acct,
                    child: Text(
                      acct.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  )).toList(),
                  onChanged: (acct) {
                    gp.selectedAccount = acct;
                    if (acct != null) gp.getCategoriesForAccount(acct.id);
                  },
                );
              },
            ),
          ),
          // Botón para abrir configuración
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openGraphDialog(context),
                    child: const Text('Configurar gráfico'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Lista de gráficos
          Expanded(
            child: Consumer<GraphProvider>(
              builder: (_, gp, __) {
                if (gp.selectedAccount == null) {
                  return const Center(child: Text('Selecciona una cuenta'));
                }
                if (gp.graphics == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (gp.graphics!.isEmpty) {
                  return const Center(child: Text('No hay gráficos'));
                }
                return ListView.builder(
                  itemCount: gp.graphics!.length,
                  itemBuilder: (_, i) => _buildGraphCard(gp.graphics![i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard(Graphic g) {
    // 1. Convertir data y labels a FlSpots
    final spots = g.data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    // 2. Calcular intervalos
    final xCount = spots.length;
    // Queremos unas 5 etiquetas en X
    final desiredXLabels = 5;
    // Si hay pocos puntos, etiquetamos todos
    final xInterval = xCount > desiredXLabels
        ? (xCount - 1) / (desiredXLabels - 1)
        : 1.0;

    // Para Y, calculamos el máximo valor
    final maxY = g.data.isEmpty ? 0.0 : g.data.reduce((a, b) => a > b ? a : b);
    // Queremos unas 5 etiquetas en Y
    final desiredYLabels = 5;
    // Evitamos division cero
    final yInterval = maxY > 0
        ? maxY / (desiredYLabels - 1)
        : 1.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _periodLabel(g.periodType),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('dd/MM/yyyy').format(g.startDate)} - '
              '${DateFormat('dd/MM/yyyy').format(g.endDate)}',
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: xInterval,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          // Solo dibujamos si idx está dentro y es un múltiplo razonable
                          if (idx < 0 || idx >= g.labels.length) return const SizedBox();
                          // Redondeamos value/xInterval para evitar decimales
                          if ((idx / xInterval).roundToDouble() != idx / xInterval) {
                            return const SizedBox();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              g.labels[idx],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          // Redondeamos el valor a entero
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: yInterval,
                    verticalInterval: xInterval,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      dotData: FlDotData(show: true),
                      barWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _openGraphDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final height = MediaQuery.of(ctx).size.height * 0.9;
        return Container(
          height: height,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Configurar gráfico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Periodo
                      Consumer<GraphProvider>(
                        builder: (_, gp, __) => DropdownButtonFormField<PeriodType>(
                          value: gp.periodType,
                          decoration: const InputDecoration(labelText: 'Periodo'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                          items: PeriodType.values.map((t) => DropdownMenuItem(
                            value: t, child: Text(_periodLabel(t), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          )).toList(),
                          onChanged: (t) => t != null ? gp.periodType = t : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Opciones según periodo (excepto personalizado)
                      Consumer<GraphProvider>(
                        builder: (_, gp, __) {
                          if (gp.periodType == PeriodType.custom) return const SizedBox();
                          return DropdownButtonFormField<String>(
                            value: gp.selectedOption,
                            decoration: const InputDecoration(labelText: 'Selecciona'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                            items: gp.options.map((opt) => DropdownMenuItem(
                              value: opt, child: Text(opt, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            )).toList(),
                            onChanged: (val) => gp.selectedOption = val,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Rango personalizado
                      Consumer<GraphProvider>(
                        builder: (_, gp, __) {
                          if (gp.periodType != PeriodType.custom) return const SizedBox();
                          return TextButton(
                            onPressed: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                                locale: const Locale('es', 'ES'),
                              );
                              if (range != null) gp.customRange = range;
                            },
                            child: Text(
                              gp.customRange == null
                                ? 'Seleccionar fechas'
                                : '${DateFormat("EEEE d 'de' MMMM 'de' yyyy", 'es_ES').format(gp.customRange!.start)} - ${DateFormat("EEEE d 'de' MMMM 'de' yyyy", 'es_ES').format(gp.customRange!.end)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Filtrar categorías
                      Consumer<GraphProvider>(
                        builder: (_, gp, __) {
                          if (gp.selectedAccount == null) return const SizedBox();
                          return TextButton.icon(
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Filtrar categorías', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            onPressed: () => _showFilterDialog(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Llamar a creación de gráfico
                        try {
                          await context.read<GraphProvider>().createGraph();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gráfico creado correctamente')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al crear gráfico: \$e')),
                          );
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text('Crear', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final gp = context.read<GraphProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar categorías'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: gp.categories.map((cat) {
              final subs = gp.subcategoriesMap[cat.id] ?? [];
              return ExpansionTile(
                title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                onExpansionChanged: (open) { if (open && subs.isEmpty) gp.getSubcategoriesForCategory(cat.id); },
                children: subs.map((sub) {
                  final selected = gp.selectedSubs.contains(sub);
                  return CheckboxListTile(
                    title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    value: selected,
                    onChanged: (_) => gp.toggleSubCategory(sub),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)))],
      ),
    );
  }

}