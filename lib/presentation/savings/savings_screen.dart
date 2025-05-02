// lib/screens/savings_screen.dart

import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/objective.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/providers/account_list_provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
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
    // 1) Cargo las cuentas globales
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProv = context.read<AuthProvider>();
      final accountProv = context.read<AccountListProvider>();
      final savingsProv = context.read<SavingsProvider>();

      await accountProv.fetchAccounts(authProv.user!.id);

      // 2) Inicializo SavingsProvider con la primera cuenta (si existe)
      if (accountProv.accounts.isNotEmpty) {
        savingsProv.selectAccount(accountProv.accounts.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountProv = context.watch<AccountListProvider>();
    final savingsProv = context.watch<SavingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundInApp,
      appBar: AppBar(title: const Text('Ahorros')),
      body: Column(
        children: [
          // --- 1) Fila de cuentas (desde AccountListProvider) ---
          Padding(
            padding: const EdgeInsets.all(10),
            child: _buildAccountsRow(
              accountProv.accounts,
              accountProv.isLoading,
              savingsProv,
            ),
          ),

          // --- 2) Botones Crear Objetivo/Límite ---
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
                    onPressed: () => _showCreateObjectiveDialog(savingsProv),
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
                    onPressed: () => _showCreateLimitDialog(savingsProv),
                    child: const Text("+ Límite"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- 3) Listado de Objetivos y Límites ---
          Expanded(
            child: savingsProv.isLoadingObjectives
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(child: _buildObjectiveList(savingsProv.goals)),
                      Expanded(child: _buildLimitList(savingsProv.limits)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsRow(
      List<Account> accounts,
      bool isLoadingAccounts,
      SavingsProvider savingsProv,
  ) {
    if (isLoadingAccounts) {
      return const Center(child: CircularProgressIndicator());
    }
    if (accounts.isEmpty) {
      return const Row(
        children: [Text("No hay cuentas disponibles")],
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: accounts
            .map((acc) => _accountContainer(acc, savingsProv))
            .toList(),
      ),
    );
  }

  Widget _accountContainer(Account account, SavingsProvider prov) {
    final isSelected = prov.selectedAccount?.id == account.id;
    return GestureDetector(
      onTap: () => prov.selectAccount(account),
      child: Container(
        width: 150,
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 5),
            Text("${account.balance.toStringAsFixed(2)}€",
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

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
                TextFormField(
                  decoration: const InputDecoration(labelText: "Título"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Ingrese un título" : null,
                  onSaved: (v) => title = v!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Importe"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Ingrese un importe";
                    if (double.tryParse(v) == null) return "Importe inválido";
                    return null;
                  },
                  onSaved: (v) => amount = double.parse(v!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();
              await prov.createGoal(title: title, amount: amount);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateLimitDialog(SavingsProvider prov) async {
    final _formKey = GlobalKey<FormState>();
    double amount = 0.0;
    final subs = prov.subCategories;

    if (subs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay subcategorías disponibles")),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        SubCategory? selectedSub = subs.first;
        return StatefulBuilder(
          builder: (ctx, setState) {
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
                        ...subs.map((sub) {
                          return RadioListTile<SubCategory>(
                            value: sub,
                            groupValue: selectedSub,
                            title: Text(sub.name),
                            onChanged: (v) => setState(() => selectedSub = v),
                            dense: true,
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Importe"),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Ingrese un importe";
                            if (double.tryParse(v) == null) return "Importe inválido";
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
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancelar")),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate() ||
                        selectedSub == null) return;
                    _formKey.currentState!.save();
                    await prov.createLimit(
                        subcategoryId: selectedSub!.id, amount: amount);
                    if (mounted) Navigator.pop(ctx);
                  },
                  child: const Text("Crear"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildObjectiveList(List<Objective> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay Objetivos'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        final obj = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundInApp,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(obj.title ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${obj.amount.toStringAsFixed(2)} / ${obj.total.toStringAsFixed(2)} €'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLimitList(List<Objective> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay Límites'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        final lim = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundInApp,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lim.limit_name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${lim.total.toStringAsFixed(2)} €'),
            ],
          ),
        );
      },
    );
  }
}
