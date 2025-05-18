import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:flutter/material.dart';

class AccountListProvider extends ChangeNotifier {
  final ApiProvider _api;
  AccountListProvider(this._api);

  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Carga desde el backend las cuentas del usuario
  Future<void> fetchAccounts(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.getAccountsByUserId(userId);
      final data = response.data;
      List<dynamic> accountsJson = [];
      if (data is Map<String, dynamic> && data.containsKey('accounts')) {
        accountsJson = data['accounts'] as List<dynamic>;
      } else if (data is List) {
        accountsJson = data;
      }
      _accounts = accountsJson
          .map((json) => Account.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Añade localmente sin tocar el backend
  void addAccount(Account acc) {
    _accounts.add(acc);
    notifyListeners();
  }

  /// Limpia la lista de cuentas
  void clear() {
    _accounts = [];
    notifyListeners();
  }

  void adjustAccountBalance(int accountId, double delta) {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx != -1) {
      final old = _accounts[idx];
      _accounts[idx] = old.copyWith(
        balance: old.balance + delta,
      );
      notifyListeners();
    }
  }
}