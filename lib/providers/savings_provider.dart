// lib/providers/savings_provider.dart

import 'package:SaveIt/domain/subcategory.dart';
import 'package:flutter/material.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/objective.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class SavingsProvider extends ChangeNotifier {
  // Flags de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool v) { _isLoading = v; notifyListeners(); }

  bool _isLoadingObjectives = false;
  bool get isLoadingObjectives => _isLoadingObjectives;
  set isLoadingObjectives(bool v) { _isLoadingObjectives = v; notifyListeners(); }

  // API + auth (inicialización singleton)
  late ApiProvider _api;
  late AuthProvider _auth;
  bool _initialized = false;
  static SavingsProvider _instance = SavingsProvider._internal();
  SavingsProvider._internal();
  factory SavingsProvider({ required ApiProvider api, required AuthProvider auth }) {
    if (!_instance._initialized) {
      _instance = SavingsProvider._internal();
      _instance._api = api;
      _instance._auth = auth;
      _instance._initialized = true;
    }
    return _instance;
  }

  // Datos
  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;

  Account? _selectedAccount;
  Account? get selectedAccount => _selectedAccount;

  List<Objective> goals = [];
  List<Objective> limits = [];

  List<SubCategory> subCategories = [];


  /// 1) Obtiene cuentas y, si hay, selecciona la primera y carga objetivos/límites
  Future<List<Account>> getAccountsForUser(BuildContext context) async {
    try {
      isLoading = true;
      final userId = _auth.user?.id;
      final response = await _api.getAccountsByUserId(userId!);
      final data = response.data;
      List<dynamic> arr = [];
      if (data is Map<String, dynamic> && data.containsKey('accounts')) {
        arr = data['accounts'];
      } else if (data is List) {
        arr = data;
      }
      _accounts = arr.map((j) => Account.fromJson(j)).toList();

      if (_accounts.isNotEmpty) {
        _selectedAccount = _accounts.first;
        await loadObjectivesAndLimits(_selectedAccount!.id);
      }
      return _accounts;
    } on DioException catch (e) {
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('DioError fetching savings accounts: $e');
      return [];
    } catch (e) {
      Clipboard.setData(ClipboardData(text: e.toString()));
      debugPrint('Error fetching savings accounts: $e');
      return [];
    } finally {
      isLoading = false;
    }
  }

  /// 2) Selecciona otra cuenta y recarga objetivos/límites
  Future<void> selectAccount(Account account) async {
    _selectedAccount = account;
    subCategories.clear();
    goals.clear();
    limits.clear();
    await _loadSubCategories(account.id);
    await loadObjectivesAndLimits(account.id);
    notifyListeners();
  }

  Future<void> _loadSubCategories(int accountId) async {
    isLoadingObjectives = true;
    notifyListeners();
    try {
      final allSubs = await _api.fetchSubCategories(accountId);
      subCategories = allSubs
          .where((s) => s.categoryType?.toLowerCase() == 'despesa')
          .toList();
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      subCategories = [];
    } finally {
      isLoadingObjectives = false;
      notifyListeners();
    }
  }

  Future<void> loadObjectivesAndLimits(int accountId) async {
    isLoadingObjectives = true;
    notifyListeners();

    try {
      goals = await _api.fetchGoals(accountId);
    } catch (e) {
      debugPrint('Error fetching goals: $e');
      goals = [];
    }

    try {
      limits = await _api.fetchLimits(accountId);
    } catch (e) {
      debugPrint('Error fetching limits: $e');
      limits = [];
    } finally {
      isLoadingObjectives = false;
      notifyListeners();
    }
  }

  Future<void> createGoal({ required String title, required double amount }) async {
    if (_selectedAccount == null) return;
    isLoadingObjectives = true;
    notifyListeners();
    try {
      await _api.createGoal(
        creatorId: _auth.user!.id,
        accountId: _selectedAccount!.id,
        title: title,
        total: amount,
      );
      await loadObjectivesAndLimits(_selectedAccount!.id);
    } catch (e) {
      debugPrint('Error creating goal: $e');
    } finally {
      isLoadingObjectives = false;
      notifyListeners();
    }
  }

  /// 4) Crear un nuevo límite
  Future<void> createLimit({ required int subcategoryId, required double amount }) async {
    if (_selectedAccount == null) return;
    isLoadingObjectives = true;
    notifyListeners();
    try {
      await _api.createLimit(
        creatorId: _auth.user!.id,
        accountId: _selectedAccount!.id,
        total: amount,
        subcategoryId: subcategoryId,
      );
      await loadObjectivesAndLimits(_selectedAccount!.id);
    } catch (e) {
      debugPrint('Error creating limit: $e');
    } finally {
      isLoadingObjectives = false;
      notifyListeners();
    }
  }

  Future<void> deleteObjective(int objectiveId) async {
    isLoadingObjectives = true;
    notifyListeners();

    try {
      await _api.deleteObjective(objectiveId);
      await loadObjectivesAndLimits(_selectedAccount!.id);
    } catch (e) {
      debugPrint('Error al eliminar objetivo: $e');
      rethrow;
    } finally {
      isLoadingObjectives = false;
      notifyListeners();
    }
  }

  Future<void> deleteLimit(int limitId) async {
    isLoadingObjectives = true;
    notifyListeners();

    try {
      await _api.deleteLimit(limitId);
      await loadObjectivesAndLimits(_selectedAccount!.id);
    } catch (e) {
      debugPrint('Error al eliminar objetivo: $e');
      rethrow;
    } finally {
      isLoadingObjectives = false;
      notifyListeners();
    }
  }

}
