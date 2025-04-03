import 'package:flutter/material.dart';

import '../../utils/ui/app_colors.dart';

class TransactionRegisterScreen extends StatefulWidget {
  static String id = 'transaction_register_screen';

  const TransactionRegisterScreen({super.key});

  @override
  _TransactionRegisterScreenState createState() => _TransactionRegisterScreenState();
}

class _TransactionRegisterScreenState extends State<TransactionRegisterScreen> {
  final Map<String, double> accounts = {
    'Cuenta 1': 1500.00,
    'Cuenta 2': 3200.00,
  };
  String selectedAccount = 'Cuenta 1';
  double selectedBalance = 1500.00;

  List<Map<String, dynamic>> transactions = List.generate(
    10,
        (index) => {
      'type': index % 2 == 0 ? 'Ingreso' : 'Gasto',
      'description': 'Transacción #$index',
      'amount': (index + 1) * 50.75,
      'date': '16 Mar 2025',
      'category': null, // Puede ser null
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

  void _selectAccount(String accountName) {
    setState(() {
      selectedAccount = accountName;
      selectedBalance = accounts[accountName]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundInApp,
      appBar: AppBar(title: const Text("Registrar Movimiento")),
      body: Column(
          children: [
          // Fila de Cuentas Fake
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _fakeAccountContainer("Cuenta 1"),
                _fakeAccountContainer("Cuenta 2"),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.blue),
                  onPressed: () {
                    // Acción para añadir cuenta
                  },
                ),
              ],
            ),
          ),

          // Contenedor de Saldo de la cuenta seleccionada
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

          // Lista de Transacciones Fake
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

      // Botón Flotante +
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptions(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Widget para cada cuenta fake
  Widget _fakeAccountContainer(String accountName) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectAccount(accountName),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selectedAccount == accountName ? Colors.blue.shade300 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(accountName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 5),
              Text("\$${accounts[accountName]!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para cada transacción fake con un menú desplegable
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
