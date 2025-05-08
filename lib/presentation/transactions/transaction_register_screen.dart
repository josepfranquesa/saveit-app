import 'package:SaveIt/domain/objective.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/domain/user.dart';
import 'package:SaveIt/providers/account_list_provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/coins_provider.dart';
import 'package:SaveIt/providers/savings_provider.dart';
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
  _TransactionRegisterScreenState createState() =>
      _TransactionRegisterScreenState();
}

class _TransactionRegisterScreenState
    extends State<TransactionRegisterScreen> {
  Account? selectedAccount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProv = context.read<AuthProvider>();
      final accountProv = context.read<AccountListProvider>();
      final txProv = context.read<TransactionRegisterProvider>();

      // 1) Carga inicial de cuentas existentes
      await accountProv.fetchAccounts(authProv.user!.id);

      // 2) Si hay cuentas, selecciona la primera y carga sus transacciones
      if (accountProv.accounts.isNotEmpty) {
        setState(() => selectedAccount = accountProv.accounts.first);
        await txProv.getTransactionsForAccount(selectedAccount!.id);
      }
    });
  }

  /// Selecciona una cuenta y recarga sus transacciones
  void _selectAccount(Account account) {
    setState(() {
      selectedAccount = account;
    });
    context
        .read<TransactionRegisterProvider>()
        .getTransactionsForAccount(account.id);
  }

  Future<void> _showEditRegisterDialog(BuildContext context, Transaction t) async {
    // ¡Copia y adapta íntegro el contenido del _showCreateRegisterDialog!,
    // inicializando controllers con t.origin y t.amount,
    // y llamando a prov.updateRegister(...) en lugar de create.
  }

  // Diálogo de asignar categoría
  Future<void> _showAssignCategoryDialog(BuildContext context, Transaction t) async {
    final prov = Provider.of<TransactionRegisterProvider>(context, listen: false);
    await prov.getCatAndSubcategoriesForAccount(selectedAccount!.id);

    int? selectedCatId = t.subcategoryId;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Asignar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Actual: ${t.nameCategory ?? 'Ninguna'}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              decoration: const InputDecoration(labelText: 'Nueva categoría'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Ninguna')),
                ...prov.subCategories
                    .where((s) => s.categoryType == (t.amount >= 0 ? 'Ingreso' : 'Despesa'))
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
              ],
              value: selectedCatId,
              onChanged: (v) => selectedCatId = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await prov.updateCategoryForRegister(
                registerId: t.id,
                accountId: selectedAccount!.id,
                categoryId: selectedCatId,
                context: context,
              );
              Navigator.pop(context);
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  // Diálogo de borrado
  Future<void> _showDeleteConfirmationDialog(BuildContext context, Transaction t) async {
    final prov = Provider.of<TransactionRegisterProvider>(context, listen: false);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: const Text('¿Seguro que deseas eliminar este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () async {
              await prov.deleteRegister(context, t.id, selectedAccount!.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
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

    final prov =
        Provider.of<TransactionRegisterProvider>(context, listen: false);
    if (selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una cuenta primero')),
      );
      return;
    }

    // Carga objetivos y subcategorías antes de mostrar diálogo
    final objectives =
        await prov.getObjectivesForAccount(selectedAccount!.id);
    await prov.getCatAndSubcategoriesForAccount(selectedAccount!.id);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
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
                      decoration:
                          const InputDecoration(labelText: 'Importe'),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      onChanged: (v) =>
                          setState(() => enteredAmount = double.tryParse(v) ?? 0.0),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese un importe';
                        if (double.tryParse(v) == null)
                          return 'Importe inválido';
                        return null;
                      },
                      onSaved: (v) => amount = double.parse(v!),
                    ),
                    const SizedBox(height: 24),
                    // Subcategoría
                    if (enteredAmount != 0) ...[
                      DropdownButtonFormField<int>(
                        decoration:
                            const InputDecoration(labelText: 'Subcategoría'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: [
                          const DropdownMenuItem<int>(
                              value: null, child: Text('Ninguna')),
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
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Objetivo
                    if (enteredAmount > 0) ...[
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                            labelText: 'Asociar a objetivo'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: [
                          const DropdownMenuItem<int>(
                              value: null, child: Text('Ninguno')),
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
                      ),
                      if (selectedObjectiveId != null) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Importe para objetivo'),
                          keyboardType:
                              const TextInputType.numberWithOptions(
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
                          onSaved: (v) =>
                              objectiveAmount = double.parse(v!),
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
                  Provider.of<TransactionRegisterProvider>(context,
                          listen: false)
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
                decoration:
                    const InputDecoration(labelText: 'Balance Inicial (€)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final bal = double.tryParse(balCtrl.text.trim());
                if (title.isNotEmpty && bal != null) {
                  context
                      .read<TransactionRegisterProvider>()
                      .createAccount(context, title, bal);
                  Navigator.of(context).pop();
                  AppUtils.toast(
                      context, title: 'Cuenta creada', type: 'success');
                } else {
                  AppUtils.toast(
                      context, title: 'Datos inválidos', type: 'error');
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
    final accountProv = context.watch<AccountListProvider>();
    final txProv      = context.watch<TransactionRegisterProvider>();

    final balanceText = selectedAccount != null
        ? '${selectedAccount!.balance.toStringAsFixed(2)}€'
        : '';

    return Scaffold(
      backgroundColor: AppColors.backgroundInApp,
      appBar: AppBar(title: const Text('Registrar Movimiento')),

      body: Column(
        children: [
          // 1) Selección de cuenta
          Padding(
            padding: const EdgeInsets.all(10),
            child: accountProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : accountProv.accounts.isEmpty
                    ? Row(
                        children: [
                          const Text('No hay cuentas disponibles'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                size: 30, color: Colors.blue),
                            onPressed: () => _showAddAccountOptions(context),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...accountProv.accounts.map(_accountContainer),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  size: 30, color: Colors.blue),
                              onPressed: () => _showAddAccountOptions(context),
                            ),
                          ],
                        ),
                      ),
          ),

          // 2) Información de la cuenta seleccionada
          if (selectedAccount != null)
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedAccount!.title,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                balanceText,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FutureBuilder<List<User>>(
                          future: context
                              .read<TransactionRegisterProvider>()
                              .getUsersForAccount(selectedAccount!.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2));
                            } else if (snapshot.hasError) {
                              return const Text('Error',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.red));
                            }
                            final users = snapshot.data ?? [];
                            if (users.isEmpty) {
                              return const Text('—',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic));
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: users
                                  .map((u) => Text(u.name,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
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
                              content: Text(
                                  'ID de la cuenta: ${selectedAccount!.id}'),
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

          // 3) Listado de transacciones
          Expanded(
            child: txProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : txProv.transactions.isEmpty
                    ? const Center(
                        child: Text('No hay transacciones registradas.'),
                      )
                    : ListView.builder(
                        itemCount: txProv.transactions.length,
                        itemBuilder: (context, i) =>
                            _transactionItem(txProv.transactions[i], i),
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-registro-movimiento',  // ← tag único
        onPressed: () => _showCreateRegisterDialog(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _accountContainer(Account account) {
    final isSelected = selectedAccount?.id == account.id;
    return GestureDetector(
      onTap: () => _selectAccount(account),
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
            Text('${account.balance.toStringAsFixed(2)}€',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(Transaction transaction, int index) {
    final dateStr =
        DateFormat('HH:mm dd/MM/yyyy').format(transaction.createdAt);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(
          transaction.amount >= 0
              ? Icons.arrow_circle_up
              : Icons.arrow_circle_down,
          color:
              transaction.amount >= 0 ? AppColors.green : AppColors.red,
          size: 24,
        ),
        title: Text(transaction.origin,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.nameCategory ??
                'No hay categoría asignada'),
            const SizedBox(height: 4),
            Text(dateStr,
                style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('€${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: transaction.amount >= 0
                        ? AppColors.green
                        : AppColors.red)),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'category':
                    _showAssignCategoryDialog(context, transaction);
                    break;
                  case 'delete':
                    _showDeleteConfirmationDialog(context, transaction);
                    break;
                }
              },
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'category', child: Text('Asignar categoría')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}