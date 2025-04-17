// lib/screens/savings_screen.dart

import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/objective.dart';
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
          // --- Fila de cuentas ---
          Padding(
            padding: const EdgeInsets.all(10),
            child: prov.isLoading
                ? const Center(child: CircularProgressIndicator())
                : prov.accounts.isEmpty
                    ? const Text("No hay cuentas disponibles")
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...prov.accounts
                                .map((acc) => _accountTile(acc, prov))
                                .toList(),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                size: 30,
                                color: Colors.blue,
                              ),
                              onPressed: () =>
                                  prov.getAccountsForUser(context),
                            ),
                          ],
                        ),
                      ),
          ),

          // --- Botones Crear Objetivo/Límite ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: prov.selectedAccount == null
                    ? null
                    : () {
                        // _showCreateGoalDialog(prov);
                      },
                child: const Text('Crear Objetivo'),
              ),
              ElevatedButton(
                onPressed: prov.selectedAccount == null
                    ? null
                    : () {
                        // _showCreateLimitDialog(prov);
                      },
                child: const Text('Crear Límite'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Listado de LÍMITES y OBJETIVOS ---
          Expanded(
            child: prov.isLoadingObjectives
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(child: _buildList(prov.limits, 'Límites')),
                      Expanded(child: _buildList(prov.goals, 'Objetivos')),
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

  Widget _buildList(List<Objective> items, String title) {
    if (items.isEmpty) {
      return Center(child: Text('No hay $title'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final obj = items[i];
              return ListTile(
                title: Text(obj.title ?? '-'),
                subtitle: Text('\$${obj.amount.toStringAsFixed(2)}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
