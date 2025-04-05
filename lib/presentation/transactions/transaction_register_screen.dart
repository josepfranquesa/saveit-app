import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/account.dart';
import '../../providers/transaction_register_provider.dart';
import '../../utils/ui/app_colors.dart';
import '../auth/login_screen.dart';
import '../../utils/helpers/utils_functions.dart';

class TransactionRegisterScreen extends StatefulWidget {
  static String id = 'transaction_register_screen';
  const TransactionRegisterScreen({super.key});

  @override
  _TransactionRegisterScreenState createState() => _TransactionRegisterScreenState();
}

class _TransactionRegisterScreenState extends State<TransactionRegisterScreen> {
  // Variables para la cuenta seleccionada
  String selectedAccount = "";
  double selectedBalance = 0.0;

  // Lista de transacciones fake (puedes reemplazarla cuando implementes la parte real)
  List<Map<String, dynamic>> transactions = List.generate(
    10,
    (index) => {
      'type': index % 2 == 0 ? 'Ingreso' : 'Gasto',
      'description': 'Transacción #$index',
      'amount': (index + 1) * 50.75,
      'date': '16 Mar 2025',
      'category': null,
    },
  );

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Registro Manual"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text("Cámara"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });
  }

  void _editTransaction(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Editar transacción: ${transactions[index]['description']}")),
    );
  }

  void _assignCategory(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Asignar categoría a: ${transactions[index]['description']}")),
    );
  }

  void _selectAccount(String accountTitle, double balance) {
    setState(() {
      selectedAccount = accountTitle;
      selectedBalance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se utiliza FutureBuilder para cargar las cuentas reales del usuario
    return Scaffold(
      backgroundColor: AppColors.backgroundInApp,
      appBar: AppBar(title: const Text("Registrar Movimiento")),
      body: Column(
        children: [
          // Fila de cuentas reales con scroll horizontal
          Padding(
            padding: const EdgeInsets.all(10),
            child: FutureBuilder<List<Account>>(
              future: Provider.of<TransactionRegisterProvider>(context, listen: false)
                  .getAccountsForUser(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text("Error al cargar las cuentas");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Row(
                    children: [
                      const Text("No hay cuentas disponibles"),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.blue),
                        onPressed: () {
                          // Acción para añadir cuenta
                        },
                      )
                    ],
                  );
                } else {
                  final accounts = snapshot.data!;
                  // Si aún no se ha seleccionado ninguna cuenta, se selecciona la primera.
                  if (selectedAccount.isEmpty && accounts.isNotEmpty) {
                    selectedAccount = accounts[0].title;
                    selectedBalance = accounts[0].balance;
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...accounts.map((account) => _accountContainer(account)).toList(),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.blue),
                          onPressed: () {
                            // Acción para añadir cuenta
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          // Contenedor de saldo de la cuenta seleccionada
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(selectedAccount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    "\$${selectedBalance.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Lista de transacciones (fake por ahora)
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No hay transacciones registradas."))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _transactionItem(transaction, index);
                    },
                  ),
          ),
        ],
      ),
      // Botón flotante +
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptions(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Widget para cada cuenta (usando el objeto Account) con ancho fijo
  Widget _accountContainer(Account account) {
    return GestureDetector(
      onTap: () => _selectAccount(account.title, account.balance),
      child: Container(
        width: 150, // ancho fijo
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedAccount == account.title ? Colors.blue.shade300 : Colors.blue.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(account.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 5),
            Text("${account.balance.toStringAsFixed(2)}€", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Widget para cada transacción fake
  Widget _transactionItem(Map<String, dynamic> transaction, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(
          transaction['type'] == 'Ingreso' ? Icons.arrow_circle_up : Icons.arrow_circle_down,
          color: transaction['type'] == 'Ingreso' ? Colors.green : Colors.red,
          size: 24,
        ),
        title: Text(
          transaction['description'] ?? "Sin descripción",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction['date'] ?? "Fecha desconocida", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              transaction['category'] != null && transaction['category'].toString().isNotEmpty
                  ? transaction['category']
                  : "Sin categoría",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "\$${(transaction['amount'] ?? 0.0).toStringAsFixed(2)}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: transaction['type'] == 'Ingreso' ? Colors.green.shade700 : Colors.red.shade700),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "edit") _editTransaction(index);
                if (value == "delete") _deleteTransaction(index);
                if (value == "category") _assignCategory(index);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: "edit", child: Text("Editar")),
                const PopupMenuItem(value: "category", child: Text("Asignar categoría")),
                const PopupMenuItem(value: "delete", child: Text("Eliminar")),
              ],
              icon: const Icon(Icons.more_vert, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
