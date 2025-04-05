import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/account.dart';
import '../../domain/transaction_register.dart';
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
  // Variable para la cuenta seleccionada (almacena el objeto Account completo)
  Account? selectedAccount;

  @override
  void initState() {
    super.initState();
    // Se podría inicializar la cuenta seleccionada cuando se obtengan las cuentas,
    // por eso en el FutureBuilder se asigna la primera si aún es null.
  }

  // Muestra las opciones de registro (manual o por cámara)
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

  // Actualiza la cuenta seleccionada y carga las transacciones de esa cuenta
  void _selectAccount(Account account) {
    setState(() {
      selectedAccount = account;
    });
    // Llama al provider para obtener las transacciones de la cuenta seleccionada
    Provider.of<TransactionRegisterProvider>(context, listen: false)
        .getTransactionsForAccount(account.id);
  }

  @override
  Widget build(BuildContext context) {
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
                  if (selectedAccount == null && accounts.isNotEmpty) {
                    selectedAccount = accounts[0];
                    // Cargamos sus transacciones
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Provider.of<TransactionRegisterProvider>(context, listen: false)
                          .getTransactionsForAccount(selectedAccount!.id);
                    });
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
                  Text(selectedAccount?.title ?? "", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    "${selectedAccount?.balance.toStringAsFixed(2) ?? "0.00"}€",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Lista de transacciones obtenidas del provider
          Expanded(
            child: Consumer<TransactionRegisterProvider>(
              builder: (context, transactionProvider, child) {
                if (transactionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (transactionProvider.transactions.isEmpty) {
                  return const Center(child: Text("No hay transacciones registradas."));
                } else {
                  return ListView.builder(
                    itemCount: transactionProvider.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactionProvider.transactions[index];
                      return _transactionItem(transaction, index);
                    },
                  );
                }
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
      onTap: () => _selectAccount(account),
      child: Container(
        width: 150, // ancho fijo
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedAccount?.id == account.id ? Colors.blue.shade300 : Colors.blue.shade100,
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

  // Widget para cada transacción (usando el objeto Transaction)
  Widget _transactionItem(Transaction transaction, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(
          transaction.amount >= 0 ? Icons.arrow_circle_up : Icons.arrow_circle_down,
          color: transaction.amount >= 0 ? Colors.green : Colors.red,
          size: 24,
        ),
        title: Text(
          "Transacción #${transaction.id}",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.createdAt != null ? transaction.createdAt.toString() : "Fecha desconocida",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              transaction.origin,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "€${transaction.amount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount >= 0 ? Colors.green.shade700 : Colors.red.shade700),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "edit") {
                  //_editTransaction(index);
                }
                if (value == "delete") {
                  //_deleteTransaction(index);
                }
                if (value == "category") {
                  //_assignCategory(index);
                }
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
