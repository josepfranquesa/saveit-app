import 'package:SaveIt/domain/objective.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/account.dart';
import '../../domain/transaction_register.dart';
import '../../providers/transaction_register_provider.dart';
import '../../utils/ui/app_colors.dart';
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
    // La cuenta seleccionada se asignará en el FutureBuilder si aún es null
  }

  Future<void> _showCreateRegisterDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    String origin = "";
    double amount = 0.0;
    double enteredAmount = 0.0;
    int? selectedObjectiveId;
    double objectiveAmount = 0.0;
    final _amountController = TextEditingController();

    final prov = Provider.of<TransactionRegisterProvider>(context, listen: false);
    if (selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe seleccionar una cuenta primero")),
      );
      return;
    }

    // Carga list de objetivos antes de abrir el diálogo
    final List<Objective> objectives =
        await prov.getObjectivesForAccount(selectedAccount!.id);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Nuevo Registro"),
            content: Form(
              key: _formKey,
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Origen / título de la transacción
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Origen"),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Ingrese un origen" : null,
                      onSaved: (v) => origin = v!.trim(),
                    ),
                    const SizedBox(height: 16),

                    // Importe (puede ser negativo para gasto)
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: "Importe"),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        setState(() {
                          enteredAmount = parsed != null ? parsed : 0.0;
                        });
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Ingrese un importe";
                        if (double.tryParse(v) == null) return "Importe inválido";
                        return null;
                      },
                      onSaved: (v) => amount = double.parse(v!),
                    ),

                    const SizedBox(height: 24),

                    // Sólo mostramos el selector de objetivo si el importe es positivo
                    if (enteredAmount > 0) ...[
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: "Asociar a objetivo",
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                        ),                        
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text("— Ninguno —"),
                          ),
                          ...objectives.map((obj) => DropdownMenuItem<int>(
                                value: obj.id,
                                child: Text(obj.title ?? 'Sin título'),
                              )),
                        ],
                        value: selectedObjectiveId,
                        onChanged: (id) => setState(() {
                          selectedObjectiveId = id;
                        }),
                        // Permitimos null como opción inicial
                        validator: (_) => null,
                      ),

                      // Si elegimos un objetivo distinto de "ninguno",
                      // mostramos el campo para la parte de importe
                      if (selectedObjectiveId != null) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Importe para objetivo",
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (selectedObjectiveId != null) {
                              if (v == null || v.isEmpty) {
                                return "Ingrese un valor para el objetivo";
                              }
                              if (double.tryParse(v) == null) {
                                return "Importe inválido";
                              }
                              if (double.parse(v) > enteredAmount) {
                                return "No puede exceder el importe total";
                              }
                            }
                            return null;
                          },
                          onSaved: (v) {
                            if (v != null && v.isNotEmpty) {
                              objectiveAmount = double.parse(v);
                            }
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text("Crear"),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  await prov.createRegister(
                    accountId: selectedAccount!.id,
                    amount: amount,
                    origin: origin,
                    objectiveId: selectedObjectiveId,
                    objectiveAmount:
                        selectedObjectiveId != null ? objectiveAmount : null,
                    subcategoryId: null,
                    periodicId: null,
                  );

                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
    _amountController.dispose();
  }



  void _showAddAccountOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Añadir Cuenta"),
          content: const Text("Seleccione una opción:"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showJoinAccountDialog(context);
              },
              child: const Text("Unirse a una cuenta"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCreateAccountDialog(context);
              },
              child: const Text("Crear una cuenta"),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para unirse a una cuenta
  void _showJoinAccountDialog(BuildContext context) {
    final TextEditingController _accountIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Unirse a una Cuenta"),
          content: TextField(
            controller: _accountIdController,
            decoration: const InputDecoration(labelText: "ID de la Cuenta"),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              
              onPressed: () {
                String idText = _accountIdController.text.trim();
                int? accountId = int.tryParse(idText);
                if (accountId != null) {
                  Provider.of<TransactionRegisterProvider>(context, listen: false).joinAccount(context,accountId);
                  Navigator.of(context).pop();
                  AppUtils.toast(context, title: "Solicitud enviada para unirse", type: "success");
                } else {
                  AppUtils.toast(context, title: "Ingrese un ID válido", type: "error");
                }
              },
              child: const Text("Unirse"),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para crear una nueva cuenta
  void _showCreateAccountDialog(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Crear Cuenta"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: _balanceController,
                decoration: const InputDecoration(labelText: "Balance Inicial (€)"),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                String title = _titleController.text.trim();
                String balanceText = _balanceController.text.trim();
                double? balance = double.tryParse(balanceText);
                if (title.isNotEmpty && balance != null) {
                  Provider.of<TransactionRegisterProvider>(context, listen: false).createAccount(context, title, balance);
                  Navigator.of(context).pop();
                  AppUtils.toast(context, title: "Cuenta creada", type: "success");
                } else {
                  AppUtils.toast(context, title: "Ingrese datos válidos", type: "error");
                }
              },
              child: const Text("Crear"),
            ),
          ],
        );
      },
    );
  }

  // Actualiza la cuenta seleccionada y carga sus transacciones
  void _selectAccount(Account account) {
    setState(() {
      selectedAccount = account;
    });
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
                          _showCreateRegisterDialog(context);
                        },
                      )
                    ],
                  );
                } else {
                  final accounts = snapshot.data!;
                  if (selectedAccount == null && accounts.isNotEmpty) {
                    selectedAccount = accounts[0];
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
                            _showAddAccountOptions(context);
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
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(selectedAccount?.title ?? "",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
        onPressed: () => _showCreateRegisterDialog(context), 
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
          color: selectedAccount?.id == account.id ? AppColors.normalBlue : AppColors.softBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(account.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 5),
            Text("${account.balance.toStringAsFixed(2)}€",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
          color: transaction.amount >= 0 ? AppColors.green : AppColors.red,
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
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            Text(
              transaction.origin,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.grey),
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
                color: transaction.amount >= 0 ? AppColors.green : AppColors.red,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                // Aquí se pueden implementar las acciones para editar, eliminar o asignar categoría
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

  

