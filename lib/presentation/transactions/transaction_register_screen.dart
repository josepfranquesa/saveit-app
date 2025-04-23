import 'package:SaveIt/domain/objective.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/domain/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/account.dart';
import '../../domain/transaction_register.dart';
import '../../providers/transaction_register_provider.dart';
import '../../utils/ui/app_colors.dart';
import '../../utils/helpers/utils_functions.dart';
import 'package:intl/intl.dart';

class TransactionRegisterScreen extends StatefulWidget {
  static String id = 'transaction_register_screen';
  const TransactionRegisterScreen({Key? key}) : super(key: key);

  @override
  _TransactionRegisterScreenState createState() => _TransactionRegisterScreenState();
}

class _TransactionRegisterScreenState extends State<TransactionRegisterScreen> {
  Account? selectedAccount;

  @override
  void initState() {
    super.initState();
    // Nothing here; first account will be set in FutureBuilder
  }

  /// Selecciona una cuenta y carga sus transacciones
  void _selectAccount(Account account) {
    setState(() {
      selectedAccount = account;
    });
    Provider.of<TransactionRegisterProvider>(context, listen: false)
        .getTransactionsForAccount(account.id);
  }

  /// Diálogo para crear un nuevo registro
  Future<void> _showCreateRegisterDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String origin = '';
    double amount = 0.0;
    double enteredAmount = 0.0;
    int? selectedSubcategoryId;
    int? selectedObjectiveId;
    double objectiveAmount = 0.0;
    final amountController = TextEditingController();

    final prov = Provider.of<TransactionRegisterProvider>(context, listen: false);
    if (selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una cuenta primero')),
      );
      return;
    }

    // Carga objetivos y subcategorías antes de mostrar diálogo
    final objectives = await prov.getObjectivesForAccount(selectedAccount!.id);
    await prov.getCatAndSubcategoriesForAccount(selectedAccount!.id);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          // Filtra subcategorías según signo de enteredAmount
          final filteredSubs = enteredAmount > 0
              ? prov.subCategories
                  .where((s) => s.categoryType == 'Ingreso')
                  .toList()
              : prov.subCategories
                  .where((s) => s.categoryType == 'Despesa')
                  .toList();
          return AlertDialog(
            title: const Text('Nuevo Registro'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Origen
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Origen'),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Ingrese un origen'
                          : null,
                      onSaved: (v) => origin = v!.trim(),
                    ),
                    const SizedBox(height: 16),
                    // Importe
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Importe'),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      onChanged: (v) => setState(() =>
                          enteredAmount = double.tryParse(v) ?? 0.0),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese un importe';
                        if (double.tryParse(v) == null) return 'Importe inválido';
                        return null;
                      },
                      onSaved: (v) => amount = double.parse(v!),
                    ),
                    const SizedBox(height: 24),
                    // Selector de subcategoría
                    if (enteredAmount != 0) ...[
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                            labelText: 'Subcategoría'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: [
                          const DropdownMenuItem<int>(
                              value: null, child: Text('— Ninguna —')),
                          ...filteredSubs.map(
                            (sub) => DropdownMenuItem<int>(
                              value: sub.id,
                              child: Text(sub.name),
                            ),
                          ),
                        ],
                        value: selectedSubcategoryId,
                        onChanged: (id) => setState(() {
                          selectedSubcategoryId = id;
                        }),
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Selector de objetivo e importe para objetivo
                    if (enteredAmount > 0) ...[
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                            labelText: 'Asociar a objetivo'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: [
                          const DropdownMenuItem<int>(
                              value: null, child: Text('— Ninguno —')),
                          ...objectives.map(
                            (obj) => DropdownMenuItem<int>(
                              value: obj.id,
                              child: Text(obj.title ?? 'Sin título'),
                            ),
                          ),
                        ],
                        value: selectedObjectiveId,
                        onChanged: (id) => setState(() {
                          selectedObjectiveId = id;
                        }),
                        validator: (_) => null,
                      ),
                      if (selectedObjectiveId != null) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Importe para objetivo'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Ingrese un importe para el objetivo';
                            }
                            final parsed = double.tryParse(v);
                            if (parsed == null) return 'Importe inválido';
                            if (parsed > enteredAmount) {
                              return 'No puede exceder el importe total';
                            }
                            return null;
                          },
                          onSaved: (v) => objectiveAmount = double.parse(v!),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  formKey.currentState!.save();
                  await prov.createRegister(
                    context: context,
                    accountId: selectedAccount!.id,
                    amount: amount,
                    origin: origin,
                    objectiveId: selectedObjectiveId,
                    objectiveAmount: selectedObjectiveId != null
                        ? objectiveAmount
                        : null,
                    subcategoryId: selectedSubcategoryId,
                    periodicId: null,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Crear'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Diálogo para añadir o unirse a cuenta
  void _showAddAccountOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir Cuenta'),
          content: const Text('Seleccione una opción:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showJoinAccountDialog(context);
              },
              child: const Text('Unirse a una cuenta'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCreateAccountDialog(context);
              },
              child: const Text('Crear una cuenta'),
            ),
          ],
        );
      },
    );
  }

  void _showJoinAccountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unirse a una Cuenta'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'ID de la Cuenta'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final idText = controller.text.trim();
                final accountId = int.tryParse(idText);
                if (accountId != null) {
                  Provider.of<TransactionRegisterProvider>(context, listen: false)
                      .joinAccount(context, accountId);
                  Navigator.of(context).pop();
                  AppUtils.toast(context,
                      title: 'Solicitud enviada', type: 'success');
                } else {
                  AppUtils.toast(context,
                      title: 'ID inválido', type: 'error');
                }
              },
              child: const Text('Unirse'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateAccountDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final balCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Cuenta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: balCtrl,
                decoration: const InputDecoration(
                    labelText: 'Balance Inicial (€)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final bal = double.tryParse(balCtrl.text.trim());
                if (title.isNotEmpty && bal != null) {
                  Provider.of<TransactionRegisterProvider>(context,
                          listen: false)
                      .createAccount(context, title, bal);
                  Navigator.of(context).pop();
                  AppUtils.toast(context,
                      title: 'Cuenta creada', type: 'success');
                } else {
                  AppUtils.toast(context,
                      title: 'Datos inválidos', type: 'error');
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String balanceText = selectedAccount?.balance != null
        ? '${selectedAccount!.balance.toStringAsFixed(2)}€'
        : '';

    return Scaffold(
      backgroundColor: AppColors.backgroundInApp,
      appBar: AppBar(title: const Text('Registrar Movimiento')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: FutureBuilder<List<Account>>(
              future: Provider.of<TransactionRegisterProvider>(context, listen: false)
                  .getAccountsForUser(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text('Error al cargar las cuentas');
                }
                final accounts = snapshot.data ?? [];
                if (accounts.isEmpty) {
                  return Row(
                    children: [
                      const Text('No hay cuentas disponibles'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            size: 30, color: Colors.blue),
                        onPressed: () => _showCreateRegisterDialog(context),
                      ),
                    ],
                  );
                }
                if (selectedAccount == null) {
                  selectedAccount = accounts.first;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Provider.of<TransactionRegisterProvider>(context, listen: false)
                        .getTransactionsForAccount(selectedAccount!.id);
                  });
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...accounts.map(_accountContainer),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            size: 30, color: Colors.blue),
                        onPressed: () => _showCreateRegisterDialog(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // 1️⃣ Row principal: título+saldo a la izquierda, nombres pegados con 8px
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título + saldo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedAccount?.title ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              balanceText,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Solo 8px de separación
                      const SizedBox(width: 8),

                      // Nombres de usuarios, sin expandirse demasiado
                      FutureBuilder<List<User>>(
                        future: Provider.of<TransactionRegisterProvider>(context, listen: false)
                            .getUsersForAccount(selectedAccount!.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              'Error',
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            );
                          }
                          final users = snapshot.data ?? [];
                          if (users.isEmpty) {
                            return const Text(
                              '—',
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: users.map((u) {
                              return Text(
                                u.name,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),

                  // 2️⃣ Icono de info mínimo en la esquina superior derecha
                  Positioned(
                    top: 26,
                    right: 220,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 16,
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID de la cuenta: ${selectedAccount?.id}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          Expanded(
            child: Consumer<TransactionRegisterProvider>(
              builder: (context, prov, child) {
                if (prov.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (prov.transactions.isEmpty) {
                  return const Center(
                    child: Text('No hay transacciones registradas.'),
                  );
                }
                return ListView.builder(
                  itemCount: prov.transactions.length,
                  itemBuilder: (context, i) =>
                      _transactionItem(prov.transactions[i], i),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRegisterDialog(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  // Widget para cada cuenta
  Widget _accountContainer(Account account) {
    return GestureDetector(
      onTap: () => _selectAccount(account),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedAccount?.id == account.id
              ? AppColors.normalBlue
              : AppColors.softBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(account.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 5),
            Text('${account.balance.toStringAsFixed(2)}€',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Widget para cada transacción
  Widget _transactionItem(Transaction transaction, int index) {
    final dateStr = DateFormat('HH:mm dd/MM/yyyy')
        .format(transaction.createdAt);
    return Card(
      margin:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(
          transaction.amount >= 0
              ? Icons.arrow_circle_up
              : Icons.arrow_circle_down,
          color: transaction.amount >= 0
              ? AppColors.green
              : AppColors.red,
          size: 24,
        ),
        title: Text(
          transaction.origin,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.subcategoryName ??
                  'No hay categoría asignada',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.grey),
            ),
            const SizedBox(height: 4),
            Text(dateStr,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '€${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount >= 0
                      ? AppColors.green
                      : AppColors.red),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {},
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'edit', child: Text('Editar')),
                PopupMenuItem(
                    value: 'category',
                    child: Text('Asignar categoría')),
                PopupMenuItem(
                    value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}