import 'package:SaveIt/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:provider/provider.dart';

/// Tipos de periodo para los gráficos.
enum PeriodType { day, week, month, quarter, year, custom }

/// Provider para gestionar filtros y estado de gráfico.
class GraphProvider extends ChangeNotifier {
  // --- API + Auth (singleton) ---
  late final ApiProvider _api;
  late final AuthProvider _auth;
  bool _initialized = false;
  static GraphProvider? _instance;
  GraphProvider._internal(this._api, this._auth);

  factory GraphProvider({ required ApiProvider api, required AuthProvider auth }) {
    _instance ??= GraphProvider._internal(api, auth);
    return _instance!;
  }

  // --- Estado de filtrado ---
  PeriodType _periodType = PeriodType.day;
  String? _selectedOption;
  DateTimeRange? _customRange;
  Account? _selectedAccount;
  final Set<SubCategory> _selectedSubs = {};

  // Public getters
  PeriodType get periodType => _periodType;
  String? get selectedOption => _selectedOption;
  DateTimeRange? get customRange => _customRange;
  Account? get selectedAccount => _selectedAccount;
  Set<SubCategory> get selectedSubs => _selectedSubs;

  // Categories and subcategories per account
  List<Category> categories = [];
  Map<int, List<SubCategory>> subcategoriesMap = {};
  bool isLoadingCategories = false;
  final Map<int, bool> _loadingSubcats = {};
  bool isLoadingSubcat(int catId) => _loadingSubcats[catId] ?? false;

  // --- Opciones de período ---
  List<String> get options {
    switch (_periodType) {
      case PeriodType.day:
        return _generateDayOptions(30);
      case PeriodType.week:
        return _generateWeekOptions(8);
      case PeriodType.month:
        return _generateMonthOptions(6);
      case PeriodType.quarter:
        return _generateQuarterOptions(8);
      case PeriodType.year:
        return _generateYearOptions(3);
      case PeriodType.custom:
        return [];
    }
  }

  // --- Setters con notifyListeners ---
  set periodType(PeriodType t) {
    _periodType = t;
    _selectedOption = options.isNotEmpty ? options.first : null;
    _customRange = null;
    notifyListeners();
  }

  set selectedOption(String? val) {
    _selectedOption = val;
    notifyListeners();
  }

  set customRange(DateTimeRange? range) {
    _customRange = range;
    notifyListeners();
  }

  set selectedAccount(Account? acct) {
    _selectedAccount = acct;
    _selectedSubs.clear();
    categories.clear();
    subcategoriesMap.clear();
    notifyListeners();
  }

  void toggleSubCategory(SubCategory sub) {
    if (_selectedSubs.contains(sub)) _selectedSubs.remove(sub);
    else _selectedSubs.add(sub);
    notifyListeners();
  }

  // --- Generadores de opciones ---
  List<String> _generateDayOptions(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final d = now.subtract(Duration(days: i));
      return DateFormat('dd/MM/yyyy').format(d);
    });
  }

  List<String> _generateWeekOptions(int weeks) {
    final now = DateTime.now();
    return List.generate(weeks, (i) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + 7 * i));
      final weekEnd = weekStart.add(Duration(days: 6));
      return '${DateFormat('dd/MM').format(weekStart)} - ${DateFormat('dd/MM').format(weekEnd)}';
    });
  }

  List<String> _generateMonthOptions(int months) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final d = DateTime(now.year, now.month - i);
      return DateFormat('MMMM yyyy').format(d);
    });
  }

  List<String> _generateQuarterOptions(int quarters) {
    final now = DateTime.now();
    final currentQ = ((now.month - 1) ~/ 3) + 1;
    return List.generate(quarters, (i) {
      final q = ((currentQ - i - 1) % 4 + 4) % 4 + 1;
      final year = now.year - ((currentQ - i - 1) < 0 ? 1 : 0);
      return 'Q$q $year';
    });
  }

  List<String> _generateYearOptions(int years) {
    final now = DateTime.now();
    return List.generate(years, (i) => '${now.year - i}');
  }

  // --- Carga de categorías y subcategorías ---
  Future<void> getCategoriesForAccount(int accountId) async {
    isLoadingCategories = true;
    notifyListeners();
    try {
      categories = await _api.getCategoriesForAccount(accountId);
    } catch (e) {
      debugPrint('Error al obtener categorías: \$e');
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> getSubcategoriesForCategory(int categoryId) async {
    final acctId = _selectedAccount?.id;
    if (acctId == null) return;
    _loadingSubcats[categoryId] = true;
    notifyListeners();
    try {
      final subCats = await _api.getSubcategoriesForCategory(categoryId, acctId);
      subcategoriesMap[categoryId] = subCats;
    } catch (_) {}
    finally {
      _loadingSubcats[categoryId] = false;
      notifyListeners();
    }
  }
}
