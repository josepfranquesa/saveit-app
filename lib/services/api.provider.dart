// services/api.provider.dart

import 'dart:async';
import 'package:SaveIt/domain/category.dart';
import 'package:SaveIt/domain/graphic.dart';
import 'package:SaveIt/domain/login_response.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/domain/objective.dart';
import 'package:SaveIt/domain/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ApiProvider extends ChangeNotifier {
  String _token = "";
  String get token => _token;

  Dio dio = Dio();
  late String url;

  bool initialized = false;

  static BaseOptions options = BaseOptions(
    connectTimeout: const Duration(milliseconds: 50000),
    receiveTimeout: const Duration(milliseconds: 50000),
  );

  static ApiProvider _instancia = ApiProvider._();
  ApiProvider._internal();
  factory ApiProvider({required String url}) {
    if (!_instancia.initialized) {
      _instancia = ApiProvider._internal();
      _instancia.dio = Dio(options);
      _instancia.dio.options.baseUrl = url;
      _instancia.url = url;
      _instancia.initialized = true;
    }
    return _instancia;
  }

  ApiProvider._();

  // Interceptor para agregar el token a las peticiones si es necesario
  _tokenInterceptor() {
    return InterceptorsWrapper(onRequest: (options, handler) async {
      if (options.uri.toString().contains("api") && _token != "") {
        options.headers["Authorization"] = 'Bearer $_token';
      }
      return handler.next(options);
    });
  }

  void setToken(String token) {
    _token = token;
  }

  /* **********************************************
   *               AUTENTICACIÓN
   *********************************************** */
  Future<LoginResponse> login(String email, String password) async {
    var resp = await dio.post("/login", data: {"email": email, "password": password});
    return LoginResponse.fromJson(resp.data);
  }

  Future<LoginResponse> refreshToken() async {
    var resp = await dio.post("/refresh", data: {"is_app": true});
    return LoginResponse.fromJson(resp.data);
  }

  Future<LoginResponse> register(String name, String phone, String email, String password) async {
    var resp = await dio.post("/users", data: {
      "name": name,
      "phone": phone,
      "email": email,
      "password": password
    });
    return LoginResponse.fromMap(resp.data);
  }

  /* **********************************************
   *                 SETTINGS
   *********************************************** */
  Future<dynamic> getConfigValue(String key) async {
    var resp = await dio.get("/settings/$key");
    return resp.data['value'];
  }

  /* **********************************************
   *                  USUARIO
   *********************************************** */
  Future<User?> getUser(int userId) async {
    var resp = await dio.get("/users/$userId");
    return User.fromMap(resp.data);
  }

  Future<User?> updateUser(User user) async {
    var resp = await dio.put("/users/${user.id}", data: user.toJson());
    return User.fromMap(resp.data);
  }

  /* **********************************************
   *                CUENTAS DEL USUARIO
   *********************************************** */
  Future<Response<dynamic>> getAccountsByUserId(int userId) async {
    return await dio.get("/accounts/user/$userId");
  }

  Future<Response<dynamic>> deleteUserAccount(int accountId, int userId) async {
    // Se asume que el endpoint espera el user_id en el cuerpo de la petición.
    return await dio.delete("/account/user/$accountId/$userId");
  }

  Future<Response<dynamic>> createAccount(int userId, String title, double balance) async {
    return await dio.post("/accounts", data: {"user_id": userId, "title": title, "balance": balance});
  }

  Future<Response<dynamic>> joinAccount(int userId, int id) async {
    return await dio.post("/accounts/join", data: {"user_id": userId, "id": id });
  }

  /* **********************************************
   *                REGISTROS DEL USUARIO
   *********************************************** */
  Future<Response<dynamic>> get_transactions(int accountId) async {
    return await dio.get("/register/account/$accountId");
  }

  Future<Response<Map<String, dynamic>>> createRegister({
    required int userId,
    required int accountId,
    required double amount,
    required String origin,
    int? objectiveId,
    double? objectiveAmount,
    int? subcategoryId,
    int? periodicInterval,
    String? periodicUnit,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'account_id': accountId,
      'amount': amount,
      'origin': origin,
      if (objectiveId != null) 'objective_id': objectiveId,
      if (objectiveAmount != null) 'objective_amount': objectiveAmount,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (periodicInterval != null) 'periodic_interval': periodicInterval,
      if (periodicUnit != null) 'periodic_unit': periodicUnit,
    };

    try {
      return await dio.post<Map<String, dynamic>>(
        '/register/account',
        data: body,
      );
    } on DioException {
      rethrow;
    }
  }


  Future<Response<dynamic>> updateCatRegister(int registerId, int idCategory) async {
    return await dio.put("/register/account/$registerId/update_category/$idCategory");
  }

  Future<Response<dynamic>> deleteRegister(int registerId) async {
    return await dio.delete("/register/account/$registerId");
  }

  
  /* **********************************************
   *              ELIMINAR USUARIO
   *********************************************** */
  Future<Response<dynamic>> deleteUser(int userId) async {
    return await dio.delete("/users/$userId");
  }

  Future<List<Category>> getCategoriesForAccount(int accountId) async {
    final response = await dio.get('/category/account/$accountId');
    if (response.statusCode == 200) {
      final rawList = response.data as List<dynamic>;
      return rawList
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
    } else {
      throw Exception('Error al obtener categorías');
    }
  }

  Future<List<SubCategory>> getSubcategoriesForCategory(int categoryId, int accountId) async {
    final response = await dio.get('/subcategory/category/$categoryId/$accountId');

    if (response.statusCode == 200) {
      final rawList = response.data as List<dynamic>;
      return rawList
          .map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al obtener subcategorías');
    }
  }

  Future<void> createCategory({required int accountId,required String name,required String type,}) async {
    final response = await dio.post('/category',
      data: {
        'account_id': accountId.toString(),
        'name_category': name,
        'type_category': type,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear categoría');
    }
  }

  Future<void> createSubCategory({required int categoryId, required int accountId, required String name,}) async {
    final response = await dio.post('/subcategory',
      data: { 
        'id_category': categoryId.toString(),
        'account_id': accountId.toString(),
        'name_subcat': name,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear subcategoría');
    }
  }

  Future<Response> fetchNoCategoryTotals(int accountId) async {
    return await dio.get('/register/total/no_category/$accountId');
  }

  Future<void> deleteCategoryAccount(int id, int accountId) async {
      final response = await dio.delete('/category/account/$id/$accountId');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al eliminar categoría');
      }
  }

  Future<void> deleteSubcategoryAccount(int id, int accountId) async {
      final response = await dio.delete('/subcategory/account/$id/$accountId');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al eliminar subcategoría');
      }
  }

  /* **********************************************
   *              OBJETIVOS Y LÍMITES
   *********************************************** */

  Future<List<Objective>> fetchGoals(int accountId) async {
    final resp = await dio.get('/objective/$accountId');
    final data = resp.data;
    if (data is Map<String, dynamic> && data.containsKey('objectives')) {
      final list = data['objectives'] as List<dynamic>;
      return list
          .map((json) => Objective.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> deleteObjective(int id) async {
    final resp = await dio.delete('/objective/$id');
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    }
    throw Exception('Error al eliminar objetivo');
  }

  Future<void> deleteLimit(int id) async {
    final resp = await dio.delete('/limit/$id');
    if (resp.statusCode == 200 || resp.statusCode == 204) {
      return;
    }
    throw Exception('Error al eliminar objetivo');
  }


  Future<List<Objective>> fetchLimits(int accountId) async {
    final resp = await dio.get('/limit/$accountId');
    final data = resp.data;
    if (data is Map<String, dynamic> && data.containsKey('objectives')) {
      final list = data['objectives'] as List<dynamic>;
      return list
          .map((json) => Objective.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<SubCategory>> fetchSubCategories(int accountId) async {
    final resp = await dio.get('/subcategory/account/$accountId');
    debugPrint('RAW subcategories response: ${resp.data}');
    final List<dynamic> data = resp.data;
    return data
      .map((json) => SubCategory.fromJson(json as Map<String, dynamic>))
      .toList();
  }

  Future<Objective> createGoal({
    required int creatorId,
    required int accountId,
    String? title,
    double? total,
  }) async {
    final resp = await dio.post(
      '/objective',
      data: {
        'creator_id': creatorId,
        'account_id': accountId,
        'total'      : total,
        'title'      : title,
      },
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return Objective.fromJson(resp.data['objective']);
    }
    throw Exception('Error al crear objetivo');
  }

  Future<Objective> createLimit({
    required int creatorId,
    required int accountId,
    required int subcategoryId,
    required double total,
  }) async {
    final resp = await dio.post(
      '/limit',
      data: {
        'creator_id'     : creatorId,
        'account_id'     : accountId,
        'subcategory_id' : subcategoryId,
        'total'          : total,
      },
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return Objective.fromJson(resp.data['objective']);
    }
    throw Exception('Error al crear límite');
  }

  Future<List<User>> getUsersForAccount(int accountId) async {
    try {
      final response = await dio.get('/users/account/$accountId');
      
      final List<dynamic> raw = response.data as List<dynamic>? ?? [];

      return raw
          .map((e) => User.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      debugPrint('Error fetching users for account $accountId: $e\n$st');
      return [];
    }
  }

  Future<Map<String, dynamic>> createGraphData({
    required String period,
    required int accountId,
    required String startDate,
    required String endDate,
    required List<int> categoryIds,
  }) async {
    final resp = await dio.post('/graph', data: {
      'periodo': period,
      'account_id': accountId,
      'start_date': startDate,
      'end_date': endDate,
      'category_ids': categoryIds,
    });

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      // Aquí devolvemos directamente el JSON decodificado
      return Map<String, dynamic>.from(resp.data);
    }
    throw Exception('Error al crear gráfico: código ${resp.statusCode}');
  }

  Future<List<Graphic>> getGraphics(int accountId) async {
    final res = await dio.get<List<dynamic>>(
      '/graph/$accountId',
      options: Options(responseType: ResponseType.json),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final list = res.data!;
      return list
          .map((e) => Graphic.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error obteniendo gráficos: ${res.statusCode}');
  }

  Future<void> deleteGraph(int id) async {
    final res = await dio.delete('/graph/$id');
    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    }
    throw Exception('Error al eliminar gráfico: ${res.statusCode}');
  }

}
