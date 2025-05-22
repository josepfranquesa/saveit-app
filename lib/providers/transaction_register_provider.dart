import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/objective.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/domain/transaction_register.dart';
import 'package:SaveIt/domain/user.dart';
import 'package:SaveIt/providers/account_list_provider.dart';
import 'package:SaveIt/providers/coins_provider.dart';
import 'package:SaveIt/providers/savings_provider.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:SaveIt/utils/helpers/utils_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class TransactionRegisterProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late ApiProvider _api;
  bool initialized = false;

  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;
  List<SubCategory> subCategories = [];


  // Constructor + SINGLETON
  static TransactionRegisterProvider _instancia = TransactionRegisterProvider._internal();
  TransactionRegisterProvider._internal();
  factory TransactionRegisterProvider({required ApiProvider api, required AuthProvider auth}) {
    if (!_instancia.initialized) {
      _instancia = TransactionRegisterProvider._internal();
      _instancia._api = api;
      _instancia.initialized = true;
    }
    return _instancia;
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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

  Future<List<User>> getUsersForAccount(int accountId) {
    return _api.getUsersForAccount(accountId);
  }

  Future<void> getTransactionsForAccount(int accountId) async {
    try {
      isLoading = true;
      final response = await _api.get_transactions(accountId);
      _transactions = (response.data as List)
          .map((json) => Transaction.fromJson(json))
          .toList();

      isLoading = false;
    } on DioException catch (e) {
      isLoading = false;
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('DioError fetching transactions: $e');
    } catch (e) {
      isLoading = false;
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('Error fetching transactions: $e');
    }
  }

  Future<void> createAccount(BuildContext ctx, String title, double balance) async {
  try {
    isLoading = true;
    final auth = ctx.read<AuthProvider>();
    final userId = auth.user!.id;
    final resp = await _api.createAccount(userId, title, balance);
    final data = resp.data;
    if (data is Map<String, dynamic> && data.containsKey('account')) {
      final newAcc = Account.fromJson(data['account']);
      // 1) lo guardamos localmente
      _accounts.add(newAcc);
      // 2) y también en el AccountListProvider
      ctx.read<AccountListProvider>().addAccount(newAcc);
    }
  } catch (e) {
    debugPrint('Error creando cuenta: $e');
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  
  Future<void> joinAccount(BuildContext context, int id) async {
    try {
      isLoading = true;
      final accountListProv = context.read<AccountListProvider>();
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user!.id;
      final response = await _api.joinAccount(userId, id);
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('account')) {
        _accounts.add(Account.fromJson(data['account']));
      }
      isLoading = false;
      getAccountsForUser(context);
    } on DioException catch (e) {
      isLoading = false;
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('DioError creating account: $e');
    } catch (e) {
      isLoading = false;
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('Error creating account: $e');
    }
  }
  
 Future<void> createRegister({
    required BuildContext context,
    required int accountId,
    required double amount,
    required String origin,
    int? objectiveId,
    double? objectiveAmount,
    int? subcategoryId,
    Map<String, dynamic>? periodicSettings,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final userId = Provider.of<AuthProvider>(context, listen: false).user!.id;

      final response = await _api.createRegister(
        userId: userId,
        accountId: accountId,
        amount: amount,
        origin: origin,
        objectiveId: objectiveId,
        objectiveAmount: objectiveAmount,
        subcategoryId: subcategoryId,
        periodicInterval: periodicSettings?['interval'] as int?,
        periodicUnit: periodicSettings?['unit'] as String?,
      );

      if (response.data != null && response.data!.containsKey('register')) {
        final message = response.data!['message'] as String?;
        if (message != null && message.isNotEmpty) {
          AppUtils.toast(context, title: message, type: 'info');
        }
        context.read<SavingsProvider>().loadObjectivesAndLimits(accountId);
        context.read<CoinsProvider>().reloadCategoriesAndSubcategoriesForAccount(accountId);
        context.read<AccountListProvider>().adjustAccountBalance(accountId, amount);
        getTransactionsForAccount(accountId);
      }
    } on DioException catch (e) {
      debugPrint('DioError creating register: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error creating register: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Objective>> getObjectivesForAccount(int accountId) async {
    try {
      isLoading = true;
      notifyListeners();
      final List<Objective> goals = await _api.fetchGoals(accountId);
      return goals;
    } on DioException catch (e) {
      debugPrint('DioError fetching objectives: $e');
      return [];
    } catch (e) {
      debugPrint('Error fetching objectives: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCatAndSubcategoriesForAccount(int accountId) async {
    isLoading = true;
    notifyListeners();
    try {
      subCategories = await _api.fetchSubCategories(accountId);
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      subCategories = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategoryForRegister({
    required int registerId,
    required int accountId,
    int? categoryId,
    required BuildContext context,
  }) async {
    try {
      final resp = await _api.updateCatRegister(registerId, categoryId!);

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría actualizada')),
        );
        await getTransactionsForAccount(accountId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    }
  }

  Future<void> deleteRegister(BuildContext context, Transaction register, int accountId) async {
    try {
      final response = await _api.deleteRegister(register.id);

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro eliminado correctamente')),
        );
          await getTransactionsForAccount(accountId);
          context.read<SavingsProvider>().loadObjectivesAndLimits(accountId);
          context.read<CoinsProvider>().reloadCategoriesAndSubcategoriesForAccount(accountId);
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final userId = auth.user?.id;
          context.read<AccountListProvider>().fetchAccounts(userId!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el registro')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    }
  }
}
