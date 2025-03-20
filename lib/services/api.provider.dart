
import 'dart:convert';
import 'dart:io';

import 'package:SaveIt/domain/login_response.dart';
import 'package:SaveIt/domain/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../domain/login_response.dart';
import '../domain/user.dart';

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
      _instancia.dio = Dio(options)
        ..interceptors.add(_instancia._tokenInterceptor());

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
    var resp = await dio.post("/auth/login", data: {"email": email, "password": password, "is_app": true});
    return LoginResponse.fromJson(resp.data);
  }

  Future<LoginResponse> refreshToken() async {
    var resp = await dio.post("/auth/refresh", data: {"is_app": true});
    return LoginResponse.fromJson(resp.data);
  }

  Future<LoginResponse> register(String name, String email, String password, String phone_number, String phone_prefix) async {
    var resp = await dio.post("/auth/register", data: {"name": name, "email": email, "password": password, "role": "customer", "phone_number": phone_number, "phone_prefix": phone_prefix, "allow_notifications": true, "is_app": true});
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
  Future<User?> getUser(int user_id) async {
    var resp = await dio.get("/users/$user_id");
    return User.fromMap(resp.data);
  }

  Future<User?> updateUser(User user) async {
    var resp = await dio.put("/users/${user.id}", data: user.toJson());
    return User.fromMap(resp.data);
  }




}