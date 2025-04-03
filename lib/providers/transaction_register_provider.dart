import 'dart:convert';

import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../domain/transaction_register.dart';
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

  // Constructor + SINGLETON
  static TransactionRegisterProvider _instancia = TransactionRegisterProvider._internal();
  TransactionRegisterProvider._internal();
  factory TransactionRegisterProvider({required ApiProvider api}) {
    if (!_instancia.initialized) {
      _instancia = TransactionRegisterProvider._internal();
      _instancia._api = api;

      // init streams o datos aquí si necesitas
      _instancia.initialized = true;
    }

    return _instancia;
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getAccountsForUser(BuildContext context) async {
    try {
      isLoading = true;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;

      final response = await _api.getAccountsByUserId(userId!);

      _accounts = (response.data as List)
          .map((json) => Account.fromJson(json))
          .toList();

      isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      isLoading = false;
      notifyListeners();
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('DioError fetching accounts: $e');
    } catch (e) {
      isLoading = false;
      notifyListeners();
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('General error fetching accounts: $e');
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
      notifyListeners();
    } on DioException catch (e) {
      isLoading = false;
      notifyListeners();
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('DioError fetching transactions: $e');
    } catch (e) {
      isLoading = false;
      notifyListeners();
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('Error fetching transactions: $e');
    }
  }


}
