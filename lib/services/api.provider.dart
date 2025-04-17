// services/api.provider.dart

import 'dart:convert'; 
import 'package:SaveIt/domain/category.dart';
import 'package:SaveIt/domain/login_response.dart';
import 'package:SaveIt/domain/subcategory.dart';
import 'package:SaveIt/domain/objective.dart';
import 'package:SaveIt/domain/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
      if (url != null) {
        _instancia.dio.options.baseUrl = url;
        _instancia.url = url;
      }
      if (_instancia.dio.options.baseUrl == null) {
        throw Exception("Please provide a base url for the api provider");
      }
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
  
  /* **********************************************
   *              ELIMINAR USUARIO
   *********************************************** */
  Future<Response<dynamic>> deleteUser(int userId) async {
    return await dio.delete("/users/$userId");
  }

  Future<List<Category>> getCategoriesForAccount(int accountId) async {
    final response = await dio.get('/category/account/$accountId');
    if (response.statusCode == 200) {
      // Dio ya decodifica la respuesta JSON automáticamente,
      // por lo tanto, usamos response.data en lugar de response.body.
      final data = response.data;
      return (data as List).map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener categorías');
    }
  }

 Future<List<SubCategory>> getSubcategoriesForCategory(int categoryId, int accountId) async {
    final response = await dio.get('/subcategory/category/$categoryId/$accountId');
    
    // Se espera que response.data sea una lista de mapas
    final List<dynamic> data = response.data;
    
    // Convertir cada objeto JSON en una instancia de SubCategory
    return data.map((json) => SubCategory.fromJson(json as Map<String, dynamic>)).toList();
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

}
