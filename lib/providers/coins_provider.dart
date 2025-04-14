import 'package:flutter/material.dart';
import 'package:SaveIt/domain/category.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CoinsProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late ApiProvider _api;
  late AuthProvider _auth;
  bool initialized = false;

  // Cuentas del usuario
  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;
  
  // Crea el campo para la cuenta seleccionada
  Account? _selectedAccount;
  Account? get selectedAccount => _selectedAccount;

  List<Category> categories = [];
  Map<int, List<SubCategory>> subcategoriesMap = {};

  bool isLoadingCategories = false;
  bool isLoadingSubcategories = false;

  // Constructor + SINGLETON
  static CoinsProvider _instancia = CoinsProvider._internal();
  CoinsProvider._internal();
  factory CoinsProvider({required ApiProvider api, required AuthProvider auth}) {
    if (!_instancia.initialized) {
      _instancia = CoinsProvider._internal();
      _instancia._api = api;
      _instancia._auth = auth;
      _instancia.initialized = true;
    }
    return _instancia;
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Obtiene las cuentas del usuario
  Future<List<Account>> getAccountsForUser(BuildContext context) async {
    try {
      isLoading = true;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;
      final response = await _api.getAccountsByUserId(userId!);
      final data = response.data;
      List<dynamic> accountsJson = [];
      if (data is Map<String, dynamic> && data.containsKey('accounts')) {
        accountsJson = data['accounts'] as List<dynamic>;
      } else if (data is List) {
        accountsJson = data;
      }
      
      _accounts = accountsJson.map((json) => Account.fromJson(json)).toList();
      
      isLoading = false;
      return _accounts;
    } on DioException catch (e) {
      isLoading = false;
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('DioError fetching accounts: $e');
      return [];
    } catch (e) {
      isLoading = false;
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('General error fetching accounts: $e');
      return [];
    }
  }

  /// Cambia la cuenta seleccionada y actualiza categorías
  Future<void> selectAccount(Account account) async {
    _selectedAccount = account;  // Asignamos a la variable correctamente
    categories.clear();
    subcategoriesMap.clear();
    await getCategoriesForAccount(account.id);
    notifyListeners();
  }

  /// Obtiene categorías para la cuenta seleccionada
  Future<void> getCategoriesForAccount(int accountId) async {
    isLoadingCategories = true;
    notifyListeners();
    try {
      categories = await _api.getCategoriesForAccount(accountId);
    } catch (e) {
      debugPrint("Error al obtener categorías: $e");
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Obtiene subcategorías para una categoría dada y la cuenta seleccionada
  Future<void> getSubcategoriesForCategory(int categoryId, int accountId) async {
    isLoadingSubcategories = true;
    notifyListeners();
    try {
      final subCats = await _api.getSubcategoriesForCategory(categoryId, accountId);
      subcategoriesMap[categoryId] = subCats;
    } catch (e) {
      debugPrint("Error al obtener subcategorías: $e");
    } finally {
      isLoadingSubcategories = false;
      notifyListeners();
    }
  }

  /// Crea una nueva categoría para la cuenta seleccionada
  Future<void> createCategory(String name, String type) async {
    if (selectedAccount == null) return;
    try {
      // Llamada al endpoint de crear categoría
      await _api.createCategory(
        accountId: selectedAccount!.id,
        name: name,
        type: type,
      );
      // Luego refrescamos la lista
      await getCategoriesForAccount(selectedAccount!.id);
    } catch (e) {
      debugPrint("Error al crear categoría: $e");
    }
  }

  /// Crea una nueva subcategoría dentro de una categoría
  Future<void> createSubCategory({
    required int categoryId,
    required String name,
    required String type,
  }) async {
    if (selectedAccount == null) return;
    try {
      // Llamada al endpoint de crear subcategoría
      await _api.createSubCategory(
        categoryId: categoryId,
        accountId: selectedAccount!.id,
        name: name,
        type: type,
      );
      // Luego refrescamos la lista de subcategorías para esa categoría
      await getSubcategoriesForCategory(categoryId, selectedAccount!.id);
    } catch (e) {
      debugPrint("Error al crear subcategoría: $e");
    }
  }
}
