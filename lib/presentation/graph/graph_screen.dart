import 'package:SaveIt/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/providers/graph_provider.dart';
import 'package:SaveIt/providers/account_list_provider.dart';
import 'package:SaveIt/providers/savings_provider.dart';
import 'package:provider/provider.dart';

class GraphScreen extends StatelessWidget {
  static const String id = 'graph_screen';
  const GraphScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch cuentas y subcategorías inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<AccountListProvider>().fetchAccounts(userId);
        context.read<SavingsProvider>().getAccountsForUser(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Gráficos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPeriodAndAccountRow(context),
            const SizedBox(height: 12),
            _buildSelectorRow(context),
            const SizedBox(height: 12),
            _buildFilterButtonRow(context),
            const SizedBox(height: 12),
            _buildCreateButtonRow(context),
            const SizedBox(height: 24),
            _buildGraphPlaceholder(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodAndAccountRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer<GraphProvider>(
            builder: (ctx, gp, _) => DropdownButtonFormField<PeriodType>(
              value: gp.periodType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                labelText: 'Periodo',
              ),
              items: PeriodType.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.toString().split('.').last.toUpperCase()),
              )).toList(),
              onChanged: (t) {
                if (t != null) gp.periodType = t;
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Consumer2<AccountListProvider, GraphProvider>(
            builder: (ctx, ap, gp, _) {
              if (ap.isLoading) return const Center(child: CircularProgressIndicator());
              return DropdownButtonFormField<Account>(
                value: gp.selectedAccount,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  labelText: 'Cuenta',
                ),
                items: ap.accounts.map((acct) => DropdownMenuItem(
                  value: acct,
                  child: Text(acct.title),
                )).toList(),
                onChanged: (acct) {
                  gp.selectedAccount = acct;
                  if (acct != null) {
                    gp.getCategoriesForAccount(acct.id);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorRow(BuildContext context) {
    return Consumer<GraphProvider>(
      builder: (ctx, gp, _) {
        if (gp.periodType == PeriodType.custom) {
          // Campos de rango personalizado omitidos por brevedad
          return Column(children: []);
        }
        return DropdownButtonFormField<String>(
          value: gp.selectedOption,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            labelText: 'Selecciona',
          ),
          items: gp.options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
          onChanged: (val) => gp.selectedOption = val,
        );
      },
    );
  }

  Widget _buildFilterButtonRow(BuildContext context) {
    return Consumer<GraphProvider>(
      builder: (ctx, gp, _) {
        final hasAccount = gp.selectedAccount != null;
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.filter_list),
            label: const Text('Filtrar categorías'),
            onPressed: hasAccount ? () => _showFilterDialog(context) : null,
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final gp = context.read<GraphProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Seleccionar categorías'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView(
              children: gp.categories.map((cat) {
                final subs = gp.subcategoriesMap[cat.id] ?? [];
                return ExpansionTile(
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  onExpansionChanged: (open) {
                    if (open && subs.isEmpty) gp.getSubcategoriesForCategory(cat.id);
                  },
                  children: subs.map((sub) {
                    final selected = gp.selectedSubs.contains(sub);
                    return CheckboxListTile(
                      title: Text(sub.name),
                      value: selected,
                      onChanged: (_) => gp.toggleSubCategory(sub),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
        );
      },
    );
  }

  Widget _buildCreateButtonRow(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Crear gráfico usando gp.selectedAccount, gp.selectedSubs...
      },
      child: const Text('Crear gráfico'),
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(36)),
    );
  }

  Widget _buildGraphPlaceholder(BuildContext context) {
    final gp = context.watch<GraphProvider>();
    final label = gp.periodType == PeriodType.custom
      ? (gp.customRange != null ? 'Personalizado' : 'Ninguno')
      : gp.selectedOption ?? '';
    return Expanded(
      child: Center(
        child: Text('Gráfico para: \$label\nCuenta: \${gp.selectedAccount?.title}'),
      ),
    );
  }
}
