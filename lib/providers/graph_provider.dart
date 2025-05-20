import 'package:SaveIt/domain/graphic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/domain/account.dart';
import 'package:SaveIt/domain/category.dart';
import 'package:SaveIt/domain/subcategory.dart';

enum PeriodType { day, week, month, quarter, year, custom }

class GraphProvider extends ChangeNotifier {
  late final ApiProvider _api;
  late final AuthProvider _auth;
  static GraphProvider? _instance;
  bool _localeInitialized = false;

  GraphProvider._internal(this._api, this._auth) {
    Intl.defaultLocale = 'es_ES';
    initializeDateFormatting('es_ES', null).then((_) => _localeInitialized = true);
  }
  factory GraphProvider({ required ApiProvider api, required AuthProvider auth }) {
    _instance ??= GraphProvider._internal(api, auth);
    return _instance!;
  }

  PeriodType _periodType = PeriodType.day;
  String? _selectedOption;
  DateTimeRange? _customRange;
  Account? _selectedAccount;
  final Set<SubCategory> _selectedSubs = {};
  Map<String, dynamic>? graphData;

  PeriodType get periodType => _periodType;
  String? get selectedOption => _selectedOption;
  DateTimeRange? get customRange => _customRange;
  Account? get selectedAccount => _selectedAccount;
  Set<SubCategory> get selectedSubs => _selectedSubs;

  List<Category> categories = [];
  Map<int, List<SubCategory>> subcategoriesMap = {};
  bool isLoadingCategories = false;
  final Map<int, bool> _loadingSubcats = {};
  bool isLoadingSubcat(int id) => _loadingSubcats[id] ?? false;

  List<Graphic>? _graphics;
  List<Graphic>? get graphics => _graphics;

  List<String> get options {
    if (!_localeInitialized) return [];
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

  set periodType(PeriodType t) {
    _periodType = t;
    _selectedOption = options.isNotEmpty ? options.first : null;
    _customRange = null;
    notifyListeners();
  }
  set selectedOption(String? val) { 
    _selectedOption = val; notifyListeners(); 
  }
  set customRange(DateTimeRange? r) { 
    _customRange = r; notifyListeners(); 
  }
  set selectedAccount(Account? a) {
    _selectedAccount = a;
    _selectedSubs.clear();
    categories.clear();
    subcategoriesMap.clear();
    notifyListeners();
    if (a != null) getGraphData(a.id);
  }
  void toggleSubCategory(SubCategory s) { if (_selectedSubs.contains(s)) _selectedSubs.remove(s); else _selectedSubs.add(s); notifyListeners(); }

  List<String> _generateDayOptions(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) { final d = now.subtract(Duration(days: i)); return DateFormat("EEEE d 'de' MMMM 'de' yyyy").format(d); });
  }
  List<String> _generateWeekOptions(int weeks) {
    final now = DateTime.now();
    return List.generate(weeks, (i) { final start = now.subtract(Duration(days: now.weekday - 1 + 7 * i)); final end = start.add(Duration(days: 6)); return '${DateFormat('dd/MM').format(start)} - ${DateFormat('dd/MM').format(end)}'; });
  }
  List<String> _generateMonthOptions(int months) {
    final now = DateTime.now();
    return List.generate(months, (i) { final d = DateTime(now.year, now.month - i); return DateFormat('MMMM yyyy').format(d); });
  }
  List<String> _generateQuarterOptions(int quarters) {
    final now = DateTime.now();
    final currentQ = ((now.month - 1) ~/ 3) + 1;
    return List.generate(quarters, (i) { final q = ((currentQ - i - 1) % 4 + 4) % 4 + 1; final y = now.year - ((currentQ - i - 1) < 0 ? 1 : 0); return 'Q$q $y'; });
  }
  List<String> _generateYearOptions(int years) {
    final now = DateTime.now();
    return List.generate(years, (i) => '${now.year - i}');
  }

  Future<void> getCategoriesForAccount(int id) async { isLoadingCategories = true; notifyListeners(); try { categories = await _api.getCategoriesForAccount(id); } finally { isLoadingCategories = false; notifyListeners(); }}
  Future<void> getSubcategoriesForCategory(int cid) async { final aid = _selectedAccount?.id; if (aid == null) return; _loadingSubcats[cid] = true; notifyListeners(); try { final subs = await _api.getSubcategoriesForCategory(cid, aid); subcategoriesMap[cid] = subs; } finally { _loadingSubcats[cid] = false; notifyListeners(); }}

  Future<void> createGraph() async {
    if (_selectedAccount == null) throw 'Cuenta no seleccionada';
    DateTime start;
    DateTime end;
    final now = DateTime.now();
    switch (_periodType) {
      case PeriodType.day:
        start = DateFormat("EEEE d 'de' MMMM 'de' yyyy").parse(_selectedOption!);
        end = start;
        break;
      case PeriodType.week:
        final parts = _selectedOption!.split(' - ');
        final fmt = DateFormat('dd/MM/yyyy');
        start = fmt.parse('${parts[0]}/${now.year}');
        end = fmt.parse('${parts[1]}/${now.year}');
        break;
      case PeriodType.month:
        start = DateFormat('MMMM yyyy').parse(_selectedOption!);
        end = DateTime(start.year, start.month + 1, 0);
        break;
      case PeriodType.quarter:
        final parts = _selectedOption!.split(' ');
        final q = int.parse(parts[0].substring(1));
        final y = int.parse(parts[1]);
        start = DateTime(y, (q - 1) * 3 + 1, 1);
        end = DateTime(y, q * 3 + 1, 0);
        break;
      case PeriodType.year:
        final y = int.parse(_selectedOption!);
        start = DateTime(y, 1, 1);
        end = DateTime(y, 12, 31);
        break;
      case PeriodType.custom:
        start = _customRange!.start;
        end = _customRange!.end;
        break;
    }
    final accountId = _selectedAccount!.id;
    final categoryIds = _selectedSubs.map((s) => s.id).toList();
    graphData = await _api.createGraphData(
      period: _periodType.toString(),
      accountId: accountId,
      startDate: start.toIso8601String(),
      endDate: end.toIso8601String(),
      categoryIds: categoryIds,
    );
    _graphics = await _api.getGraphics(accountId);
    notifyListeners();
  }

   Future<void> getGraphData(int accountId) async {
    _graphics = await _api.getGraphics(accountId);
    notifyListeners();
  }

  Future<void> deleteGraph(int id) async {
    await _api.deleteGraph(id);
    _graphics = await _api.getGraphics(_selectedAccount!.id);
    notifyListeners();
  }
}
