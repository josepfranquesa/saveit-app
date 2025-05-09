import 'package:flutter/material.dart';
import 'package:SaveIt/domain/category.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/providers/coins_provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/account_list_provider.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:provider/provider.dart';

class CoinsScreen extends StatefulWidget {
  static String id = 'coins_screen';

  const CoinsScreen({Key? key}) : super(key: key);

  @override
  _CoinsScreenState createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial de cuentas via AccountListProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProv = context.read<AuthProvider>();
      context
          .read<AccountListProvider>()
          .fetchAccounts(authProv.user!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountProv = context.watch<AccountListProvider>();
    final coinsProv   = context.watch<CoinsProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundInApp,
      appBar: AppBar(title: const Text('Categorías')),
      body: Stack(
        children: [
          // 1) Toda la UI “de fondo” (sin el botón)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fila de cuentas
              Padding(
                padding: const EdgeInsets.all(10),
                child: _buildAccountsRow(
                  accountProv.accounts,
                  coinsProv,
                  accountProv.isLoading,
                ),
              ),

              // Botones crear categoría / subcategoría
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
                        onPressed: () => _showCreateCategoryDialog(coinsProv),
                        child: const Text("+ categoría"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.principal,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: () => _showCreateSubCategoryDialog(coinsProv),
                        child: const Text("+ subcategoría"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Lista de categorías (hace scroll en su espacio)
              Expanded(
                child: _buildCategoriesAndSubcategories(coinsProv, context),
              ),

              // Totales al fondo de la columna
              _buildNoCategory(coinsProv, context),

              const SizedBox(height: 16),
            ],
          ),

          // 2) El botón, “flotando” por encima de todo
          Positioned(
            // Ajusta este valor para subir/bajar el botón
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                heroTag: 'fab-eliminar-registro',
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                child: const Icon(Icons.delete),
                onPressed: () => _showDeleteOptions(coinsProv),
              ),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildAccountsRow(List<Account> accounts, CoinsProvider coinsProv, bool isLoading) {
    if (isLoading) {
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
            .map((acc) => _accountContainer(acc, coinsProv))
            .toList(),
      ),
    );
  }

  Widget _accountContainer(Account account, CoinsProvider coinsProv) {
    final isSelected = coinsProv.selectedAccount?.id == account.id;
    return GestureDetector(
      onTap: () {
        // notificamos a CoinsProvider que cambió la cuenta
        coinsProv.selectAccount(account);
      },
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

  Widget _buildNoCategory(CoinsProvider coinsProv, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Despesa sin subcategoría
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.softRed,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey, width: 1),  // ← borde negro
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    "Sin categorías asociadas",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${coinsProv.despesaNoCat.toStringAsFixed(2)}€",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Ingreso sin subcategoría
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey, width: 1),  // ← borde negro
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    "Sin categorías asociadas",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${coinsProv.ingresoNoCat.toStringAsFixed(2)}€",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildCategoriesAndSubcategories(CoinsProvider coinsProv, BuildContext context) {
    final despesas = coinsProv.categories
        .where((c) => c.type.toLowerCase() == 'despesa')
        .toList();
    final ingresos = coinsProv.categories
        .where((c) => c.type.toLowerCase() == 'ingreso')
        .toList();

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Despesa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Despesa",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ...despesas
                    .map((cat) => _categoryTile(cat, coinsProv))
                    .toList(),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Ingreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Ingreso",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ...ingresos
                    .map((cat) => _categoryTile(cat, coinsProv))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(Category category, CoinsProvider coinsProv) {
    final subs    = coinsProv.subcategoriesMap[category.id] ?? [];
    final loading = coinsProv.isLoadingSubcat(category.id);
    final isIngreso   = category.type.toLowerCase() == 'ingreso';
    final tileColor   = isIngreso ? AppColors.softGreen : AppColors.softRed;
    final titleColor  = isIngreso ? AppColors.green     : AppColors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tileColor,
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        trailing: Transform.scale(
          scale: 0.7,
          child: Icon(Icons.expand_more, color: titleColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.amountMonth.toStringAsFixed(2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ],
        ),
        onExpansionChanged: (expanded) {
          if (expanded && subs.isEmpty && coinsProv.selectedAccount != null) {
            coinsProv.getSubcategoriesForCategory(
              category.id,
              coinsProv.selectedAccount!.id,
            );
          }
        },
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (subs.isNotEmpty) ...subs.map((s) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.amountMonth.toStringAsFixed(2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ))
          else
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "No hay subcategorías para esta categoría.",
                style: TextStyle(fontSize: 13, color: AppColors.black),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateCategoryDialog(CoinsProvider coinsProv) async {
    final key = GlobalKey<FormState>();
    String name = "", type = "Ingreso";
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Categoría"),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingrese un nombre" : null,
                onSaved: (v) => name = v!.trim(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Tipo"),
                value: type,
                items: ["Ingreso", "Despesa"]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => type = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (key.currentState!.validate()) {
                key.currentState!.save();
                await coinsProv.createCategory(name, type);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateSubCategoryDialog(CoinsProvider coinsProv) async {
    final key = GlobalKey<FormState>();
    String name = "";
    var cats = coinsProv.categories;
    Category? selectedCat = cats.isNotEmpty ? cats.first : null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Subcategoría"),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Category>(
                decoration: const InputDecoration(labelText: "Categoría"),
                value: selectedCat,
                items: cats
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => selectedCat = v,
                validator: (v) =>
                    v == null ? "Seleccione una categoría" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: "Nombre subcategoría"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingrese un nombre" : null,
                onSaved: (v) => name = v!.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (key.currentState!.validate() && selectedCat != null) {
                key.currentState!.save();
                await coinsProv.createSubCategory(
                    categoryId: selectedCat!.id, name: name);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  void _showDeleteOptions(CoinsProvider coinsProv) {
    if (coinsProv.selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona primero una cuenta')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: _buildDeleteOptionsList(coinsProv),
      ),
    );
  }

  Widget _buildDeleteOptionsList(CoinsProvider coinsProv) {
    final cats = coinsProv.categories;
    final despesaCats =
        cats.where((c) => c.type.toLowerCase() == 'despesa').toList();
    final ingresoCats =
        cats.where((c) => c.type.toLowerCase() == 'ingreso').toList();
    final subsMap = coinsProv.subcategoriesMap;

    Widget buildColumn(
        List<Category> list, Color tileColor, Color titleColor) {
      return Expanded(
        child: ListView(
          children: [
            for (var cat in list) ...[
              Container(
                color: tileColor,
                child: ExpansionTile(
                  title: Text(
                    cat.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  onExpansionChanged: (expanded) {
                    if (expanded && (subsMap[cat.id]?.isEmpty ?? true)) {
                      final acc = coinsProv.selectedAccount;
                      if (acc != null) {
                        coinsProv.getSubcategoriesForCategory(cat.id, acc.id);
                      }
                    }
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: titleColor),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confirmDelete(
                        title:
                            '¿Seguro que quieres eliminar la categoría "${cat.name}"?',
                        onConfirm: () =>
                            coinsProv.deleteCatSubcatAccount(id_category: cat.id, accountId: coinsProv.selectedAccount!.id),
                      );
                    },
                  ),
                  children: [
                    if (coinsProv.isLoadingSubcategories &&
                        (subsMap[cat.id]?.isEmpty ?? true))
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    for (var sub in subsMap[cat.id] ?? []) 
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0, right: 16.0, top: 4.0, bottom: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                sub.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: titleColor),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _confirmDelete(
                                  title:
                                      '¿Seguro que quieres eliminar la subcategoría "${sub.name}"?',
                                  onConfirm: () => coinsProv.deleteCatSubcatAccount(id_subcat: sub.id, accountId: coinsProv.selectedAccount!.id),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    const Divider(indent: 32),
                  ],
                ),
              ),
              const Divider(),
            ],
          ],
        ),
      );
    }

    return Row(
      children: [
        buildColumn(despesaCats, AppColors.softRed, AppColors.red),
        const VerticalDivider(width: 1, thickness: 1),
        buildColumn(ingresoCats, AppColors.softGreen, AppColors.green),
      ],
    );
  }



  void _confirmDelete({
    required String title,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm(); 
            },
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
  }
}
