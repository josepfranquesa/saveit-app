// ignore_for_file: unnecessary_null_comparison, unused_element

import 'dart:convert';
import 'dart:io';


import 'package:SaveIt/domain/login_response.dart';
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

  /* ***************************************************
  ** ****************** INTERCEPTOR ********************
  ** ***************************************************/
  setToken(String token) {
    _token = token;
  }

  bool _esUrlTractableSnackbar(Uri uri) {
    return (uri.toString().contains("api") && !uri.toString().contains("auth"));
  }

  bool _esUrlTractableToken(Uri uri) {
    return uri.toString().contains("api");
  }

  _tokenInterceptor() {
    return InterceptorsWrapper(onRequest: (options, handler) async {
      if (_esUrlTractableToken(options.uri) && (_token != "")) {
        options.headers["Authorization"] = 'Bearer $_token';

      }

      return handler.next(options);
    });
  }

  /*
   * AUTHENTICATION
   */
  Future<LoginResponse> login(String email, String password) async {
    var resp = await dio.post("/login", data: {"email": email, "password": password});
    return LoginResponse.fromJson(resp.data);
  }

  Future<LoginResponse> refreshToken() async {
    var resp = await dio.post("/refresh", data: {"is_app": true});
    return LoginResponse.fromJson(resp.data);
  }

  Future<LoginResponse> register(String name, String phone, String email, String password) async {
    var resp = await dio.post("/register", data: {"name": name, "phone": phone, "email": email, "password": password}); 
    return LoginResponse.fromMap(resp.data);
  }

  /*
   * SETTINGS
   */
  Future<dynamic> getConfigValue(String key) async {
    var resp = await dio.get("/settings/$key");
    return resp.data['value'];
  }

  /*
   * USER
   */
  Future<User?> getUser(int userId) async {
    var resp = await dio.get("/users/$userId");
    return User.fromMap(resp.data);
  }


  Future<User?> updateUser(User user) async {
    var resp = await dio.put("/users/${user.id}", data: user.toJson());
    return User.fromMap(resp.data);
  }

  /*
   * TRANSACTIONS
   */
  Future<Response<dynamic>> getAccountsByUserId(int userId) async {
    return await dio.get("/user_accounts/$userId");
  }

  Future<Response<dynamic>> get_transactions(int accountId) async {
    return await dio.get("/transactions/$accountId");
  }

  /*Future<Response<dynamic>> create_account(Map<String, dynamic> data) async {
    return await dio.post("/accounts", data: data);
  }

  Future<Response<dynamic>> create_transaction(Map<String, dynamic> data) async {
    return await dio.post("/transactions", data: data);
  }

  Future<Response<dynamic>> delete_account(int accountId) async {
    return await dio.delete("/accounts/$accountId");
  }

  Future<Response<dynamic>> delete_transaction(int transactionId) async {
    return await dio.delete("/transactions/$transactionId");
  }

  Future<Response<dynamic>> update_transaction(int transactionId, Map<String, dynamic> data) async {
    return await dio.put("/transactions/$transactionId", data: data);
  }*/



}