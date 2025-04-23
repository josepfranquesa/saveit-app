// lib/screens/savings_screen.dart

import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/objective.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/providers/savings_provider.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingsScreen extends StatefulWidget {
  static String id = 'savings_screen';
  const SavingsScreen({Key? key}) : super(key: key);
  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavingsProvider>(context, listen: false)
          .getAccountsForUser(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<SavingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundInApp,
      appBar: AppBar(title: const Text('Ahorros')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: _buildAccountsRow(prov),
          ),
          // --- Botones Crear Objetivo/Límite --- 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.principal,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () {
                      _showCreateObjectiveDialog(prov);
                    },
                    child: const Text("+ Objetivo"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.principal,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () {
                      _showCreateLimitDialog(prov);
                    },
                    child: const Text("+ Límite"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- Listado de LÍMITES y OBJETIVOS ---
          Expanded(
            child: prov.isLoadingObjectives
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(child: _buildObjectiveList(prov.goals)),
                      Expanded(child: _buildLimitList(prov.limits)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _accountTile(Account acc, SavingsProvider prov) {
    final isSelected = prov.selectedAccount?.id == acc.id;
    return GestureDetector(
      onTap: () => prov.selectAccount(acc),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.principal : AppColors.softGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(acc.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('\$${acc.balance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsRow(SavingsProvider prov) {
    if (prov.accounts.isEmpty) {
      return const Row(
        children: [
          Text("No hay cuentas disponibles"),
        ],
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: prov.accounts
              .map((account) => _accountContainer(account, prov))
              .toList(),
        ),
      );
    }
  }

  Widget _accountContainer(Account account, SavingsProvider prov) {
    final isSelected = prov.selectedAccount?.id == account.id;
    return GestureDetector(
      onTap: () => _selectAccount(account, prov),
      child: Container(
        width: 150, // ancho fijo
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.normalBlue : AppColors.softBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(account.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 5),
            Text("${account.balance.toStringAsFixed(2)}€",
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Selecciona la cuenta actual en el provider
  void _selectAccount(Account account, SavingsProvider prov) {
    prov.selectAccount(account);
  }

  /// Diálogo para crear un objetivo
  Future<void> _showCreateObjectiveDialog(SavingsProvider prov) async {
    final _formKey = GlobalKey<FormState>();
    String title = "";
    double amount = 0.0;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Objetivo"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo título
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Título",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese un título";
                    }
                    return null;
                  },
                  onSaved: (value) => title = value!.trim(),
                ),
                const SizedBox(height: 16),
                // Campo importe
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Importe",
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese un importe";
                    }
                    if (double.tryParse(value) == null) {
                      return "Importe inválido";
                    }
                    return null;
                  },
                  onSaved: (value) => amount = double.parse(value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Crear"),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();
              await prov.createGoal(title: title, amount: amount);

              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateLimitDialog(SavingsProvider prov) async {
    final _formKey = GlobalKey<FormState>();
    double amount = 0.0;

    final subCategories = prov.subCategories;
    if (subCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay subcategorías disponibles")),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        SubCategory? selectedSub = subCategories.first;
        return StatefulBuilder(
          builder: (context, setState) {
            int lastCategoryId = -1;
            final List<Widget> subcategoryTiles = [];
            for (final sub in subCategories) {
              final isNewCategory = sub.categoryId != lastCategoryId;
              final displayName = isNewCategory
                  ? sub.name.toUpperCase()
                  : sub.name.toLowerCase();
              lastCategoryId = sub.categoryId;
              subcategoryTiles.add(
                RadioListTile<SubCategory>(
                  value: sub,
                  groupValue: selectedSub,
                  title: Text(
                    displayName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onChanged: (val) => setState(() => selectedSub = val),
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                ),
              );
            }

            return AlertDialog(
              title: const Text("Crear Límite"),
              content: Form(
                key: _formKey,
                child: SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...subcategoryTiles,
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Importe"),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Ingrese un importe";
                            }
                            if (double.tryParse(v) == null) {
                              return "Importe inválido";
                            }
                            return null;
                          },
                          onSaved: (v) => amount = double.parse(v!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancelar"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Crear"),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    _formKey.currentState!.save();
                    if (selectedSub == null) return;

                    // Llamada al provider para crear el límite
                    await prov.createLimit(
                      subcategoryId: selectedSub!.id,
                      amount: amount,
                    );

                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildLimitList(List<Objective> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay Límites'));
    }
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.principal,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: const Center(
              child: Text(
                'Límites',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Lista
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final obj = items[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundInApp,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obj.limit_name?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${obj.total.toStringAsFixed(2)} €',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveList(List<Objective> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay Objetivos'));
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.principal,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: const Center(
              child: Text(
                'Objetivos',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final obj = items[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundInApp,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(obj.title ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        '${obj.amount.toStringAsFixed(2)} / ${obj.total.toStringAsFixed(2)} €',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
