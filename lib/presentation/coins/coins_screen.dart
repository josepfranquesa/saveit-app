import 'package:SaveIt/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/providers/coins_provider.dart';
import '../../utils/ui/app_colors.dart';

class CoinsScreen extends StatefulWidget {
  static String id = 'coins_screen';

  const CoinsScreen({super.key});

  @override
  _CoinsScreenState createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {
  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de las cuentas al montar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoinsProvider>(context, listen: false).getAccountsForUser(context);
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: _buildAccountsRow(coinsProvider),
          ),

          // 2) Botones para crear Categoría y Subcategoría
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple, // Color lila del botón
                      foregroundColor: Colors.white, // Texto blanco
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
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
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

          // 3) Lista de Categorías y Subcategorías
          Expanded(
            child: _buildCategoriesAndSubcategories(coinsProvider, context),
          ),
        ],
      ),
    );
  }

  // Utilizamos el método del provider para seleccionar la cuenta
  void _selectAccount(Account account, CoinsProvider coinsProvider) {
    coinsProvider.selectAccount(account);
  }

  /// Construye la fila horizontal de cuentas
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
          children: coinsProvider.accounts.map((account) {
            return _accountContainer(account, coinsProvider);
          }).toList(),
        ),
      );
    }
  }


  /// Card / Container para cada cuenta
  Widget _accountContainer(Account account, CoinsProvider coinsProvider) {
    final isSelected = coinsProvider.selectedAccount?.id == account.id;
    return GestureDetector(
      onTap: () => _selectAccount(account, coinsProvider),
      child: Container(
        width: 150, // ancho fijo
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade300 : Colors.blue.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(account.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 5),
            Text("${account.balance.toStringAsFixed(2)}€",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Este es el método que construye la sección de categorías y subcategorías
Widget _buildCategoriesAndSubcategories(CoinsProvider coinsProvider, BuildContext context) {
  // Separamos las categorías según su tipo (convertimos a minúsculas para evitar problemas con mayúsculas)
  final despesas = coinsProvider.categories
      .where((cat) => cat.type.toLowerCase() == 'despesa')
      .toList();
  final ingresos = coinsProvider.categories
      .where((cat) => cat.type.toLowerCase() == 'ingreso')
      .toList();

  return SingleChildScrollView(
    child: SizedBox(
      width: MediaQuery.of(context).size.width, // Asegura que el row ocupe el ancho de la pantalla
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: Despesa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Despesa",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                // Se mapea cada categoría de despesa a un contenedor
                ...despesas.map((category) => _buildCategoryTile(category, coinsProvider)).toList(),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Columna derecha: Ingreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Ingreso",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                // Se mapea cada categoría de ingreso a un contenedor
                ...ingresos.map((category) => _buildCategoryTile(category, coinsProvider)).toList(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // Función que construye cada "tarjeta" o contenedor para una categoría
  Widget _buildCategoryTile(Category category, CoinsProvider coinsProvider) {
    // Obtiene las subcategorías para la categoría actual (si ya se han cargado)
    final subcategories = coinsProvider.subcategoriesMap[category.id] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(category.name),
        // subtitle: Text("Tipo: ${category.type}"),
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          // Si se expande y aún no se han cargado las subcategorías y hay una cuenta seleccionada, se realiza la carga
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
            ...subcategories.map((subCat) {
              return ListTile(
                title: Text(subCat.name),
                subtitle: Text("Tipo: ${subCat.type}"),
              );
            }).toList(),
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
    String newCategoryType = "";

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
                  decoration:
                      const InputDecoration(labelText: "Nombre de la categoría"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese un nombre";
                    }
                    return null;
                  },
                  onSaved: (value) => newCategoryName = value ?? "",
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: "Tipo de categoría"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingrese un tipo";
                    }
                    return null;
                  },
                  onSaved: (value) => newCategoryType = value ?? "",
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

  /// Diálogo para crear subcategoría
  Future<void> _showCreateSubCategoryDialog(CoinsProvider coinsProvider) async {
    final _formKey = GlobalKey<FormState>();
    final _categoryIdController = TextEditingController();
    String newSubCatName = "";
    String newSubCatType = "";
    int newSubCatCategoryId = 0;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Crear Subcategoría"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _categoryIdController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "ID de la categoría"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingrese un ID de categoría";
                      }
                      if (int.tryParse(value) == null) {
                        return "El ID debe ser un número";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Nombre de la subcategoría"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingrese un nombre";
                      }
                      return null;
                    },
                    onSaved: (value) => newSubCatName = value ?? "",
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Tipo de la subcategoría"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ingrese un tipo";
                      }
                      return null;
                    },
                    onSaved: (value) => newSubCatType = value ?? "",
                  ),
                ],
              ),
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
                newSubCatCategoryId = int.parse(_categoryIdController.text);
                await coinsProvider.createSubCategory(
                  categoryId: newSubCatCategoryId,
                  name: newSubCatName,
                  type: newSubCatType,
                );
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
}
