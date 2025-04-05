import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/transaction_register.dart';
import 'package:SaveIt/services/api.provider.dart';
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
  late AuthProvider _auth;
  bool initialized = false;

  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  // Constructor + SINGLETON
  static TransactionRegisterProvider _instancia = TransactionRegisterProvider._internal();
  TransactionRegisterProvider._internal();
  factory TransactionRegisterProvider({required ApiProvider api, required AuthProvider auth}) {
    if (!_instancia.initialized) {
      _instancia = TransactionRegisterProvider._internal();
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

}
