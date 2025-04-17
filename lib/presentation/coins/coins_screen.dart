import 'package:SaveIt/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/providers/coins_provider.dart';
import '../../utils/ui/app_colors.dart';

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
    // Al montar la pantalla, se cargan las cuentas del usuario.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoinsProvider>(context, listen: false)
          .getAccountsForUser(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final coinsProvider = Provider.of<CoinsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundInApp,
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: Column(
        children: [
          // Fila horizontal de cuentas
          Padding(
            padding: const EdgeInsets.all(10),
            child: _buildAccountsRow(coinsProvider),
          ),

          // Botones para crear Categoría y Subcategoría
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
                      _showCreateCategoryDialog(coinsProvider);
                    },
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
                    onPressed: () {
                      _showCreateSubCategoryDialog(coinsProvider);
                    },
                    child: const Text("+ subcategoría"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Lista de Categorías y Subcategorías
          Expanded(
            child: _buildCategoriesAndSubcategories(coinsProvider, context),
          ),
        ],
      ),
    );
  }

  // Selecciona la cuenta actual en el provider
  void _selectAccount(Account account, CoinsProvider coinsProvider) {
    coinsProvider.selectAccount(account);
  }

  /// Construye la fila de cuentas
  Widget _buildAccountsRow(CoinsProvider coinsProvider) {
    if (coinsProvider.accounts.isEmpty) {
      return const Row(
        children: [
          Text("No hay cuentas disponibles"),
        ],
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: coinsProvider.accounts
              .map((account) => _accountContainer(account, coinsProvider))
              .toList(),
        ),
      );
    }
  }

  /// Contenedor para cada cuenta
  Widget _accountContainer(Account account, CoinsProvider coinsProvider) {
    final isSelected = coinsProvider.selectedAccount?.id == account.id;
    return GestureDetector(
      onTap: () => _selectAccount(account, coinsProvider),
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

  /// Construye la sección de categorías y subcategorías
  Widget _buildCategoriesAndSubcategories(
      CoinsProvider coinsProvider, BuildContext context) {
    // Separamos las categorías según su tipo
    final despesas = coinsProvider.categories
        .where((cat) => cat.type.toLowerCase() == 'despesa')
        .toList();
    final ingresos = coinsProvider.categories
        .where((cat) => cat.type.toLowerCase() == 'ingreso')
        .toList();

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna para "Despesa"
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Despesa",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  ...despesas
                      .map((category) =>
                          _buildCategoryTile(category, coinsProvider))
                      .toList(),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Columna para "Ingreso"
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Ingreso",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  ...ingresos
                      .map((category) =>
                          _buildCategoryTile(category, coinsProvider))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye cada contenedor para la categoría y sus subcategorías
  Widget _buildCategoryTile(Category category, CoinsProvider coinsProvider) {
    // Se obtienen las subcategorías cargadas para la categoría actual
    final subcategories = coinsProvider.subcategoriesMap[category.id] ?? [];

    // Se define un color de fondo e incluso el color del título según el tipo
    final bool isIngreso =
        category.type.toLowerCase() == 'ingreso' ? true : false;
    final Color tileColor = isIngreso ? AppColors.softGreen : AppColors.softRed;
    final Color titleColor = isIngreso ? AppColors.green : AppColors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tileColor,
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        collapsedBackgroundColor: tileColor,
        backgroundColor: tileColor.withOpacity(0.7),
        title: Text(
          category.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          // Si se expande y aún no se han cargado las subcategorías y existe una cuenta seleccionada, se cargan
          if (expanded &&
              subcategories.isEmpty &&
              coinsProvider.selectedAccount != null) {
            coinsProvider.getSubcategoriesForCategory(
                category.id, coinsProvider.selectedAccount!.id);
          }
        },
        children: [
          if (coinsProvider.isLoadingSubcategories && subcategories.isEmpty)
            const Center(child: CircularProgressIndicator()),
          if (subcategories.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategories.map((subCat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Text(
                      subCat.name,
                      style: const TextStyle(fontSize: 14, color: AppColors.white),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (!coinsProvider.isLoadingSubcategories && subcategories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("No hay subcategorías para esta categoría."),
            ),
        ],
      ),
    );
  }

  /// Diálogo para crear categoría
  Future<void> _showCreateCategoryDialog(CoinsProvider coinsProvider) async {
    final _formKey = GlobalKey<FormState>();
    String newCategoryName = "";
    String newCategoryType = "Ingreso"; // Valor inicial

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Categoría"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Nombre de la categoría",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese un nombre";
                    }
                    return null;
                  },
                  onSaved: (value) => newCategoryName = value ?? "",
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Tipo de categoría",
                  ),
                  value: newCategoryType,
                  items: <String>["Ingreso", "Despesa"]
                      .map((String type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.black),
                            ),
                          ))
                      .toList(),
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.black),
                  onChanged: (value) {
                    newCategoryType = value ?? "";
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Seleccione un tipo";
                    }
                    return null;
                  },
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
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await coinsProvider.createCategory(newCategoryName, newCategoryType);
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateSubCategoryDialog(CoinsProvider coinsProvider) async {
    final _formKey = GlobalKey<FormState>();
    String newSubCatName = "";
    var categories = coinsProvider.categories;
    Category? selectedCategory = categories.isNotEmpty ? categories.first : null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Subcategoría"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de categoría
                DropdownButtonFormField<Category>(
                  decoration: const InputDecoration(
                    labelText: "Categoría",
                  ),
                  value: selectedCategory,
                  items: categories.map((cat) {
                    return DropdownMenuItem<Category>(
                      value: cat,
                      child: Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (cat) {
                    selectedCategory = cat;
                  },
                  validator: (value) =>
                      value == null ? "Seleccione una categoría" : null,
                ),
                const SizedBox(height: 16),
                // Nombre de la subcategoría
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Nombre de la subcategoría",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese un nombre";
                    }
                    return null;
                  },
                  onSaved: (value) => newSubCatName = value!.trim(),
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
              if (_formKey.currentState!.validate() && selectedCategory != null) {
                _formKey.currentState!.save();
                await coinsProvider.createSubCategory(
                  categoryId: selectedCategory!.id,
                  name: newSubCatName,
                );
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

}
