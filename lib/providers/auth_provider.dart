// ignore_for_file: constant_identifier_names

import 'package:SaveIt/domain/login_response.dart';
import 'package:SaveIt/domain/token.dart';
import 'package:SaveIt/domain/user.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  static const _TOKEN_KEY = "beltimel_token";
  static const _TOKEN_PROTECTED = "beltimel_token_protected";
  static const _USER_KEY = "beltimel_user";
  static const _USER_PROTECTED = "beltimel_user_protected";


  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late ApiProvider _api;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  User? _user;
  User? get user => _user;

  bool initialized = false;

  //Constructor + SINGLETON
  static AuthProvider _instancia = AuthProvider._internal();
  AuthProvider._internal();
  factory AuthProvider({required ApiProvider api}) {
    if(!_instancia.initialized) {
      _instancia = AuthProvider._internal();
      _instancia._api = api;
      _instancia.getUserFromStorage();

      //init streams
      _instancia.initialized = true;
    }

    return _instancia;
  }

  Future<bool> isUserLogged() async {
    return await _initTokenListener();
  }

  _initTokenListener() async {
    var token = await getTokenFromStorage();
    if(token!=null) {
      try {
        _api.setToken(token);
        var resp = await refreshToken();
        return true;
      } on Exception {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<User?> getUserFromStorage() async {
    dynamic user = await _storage.read(key: _USER_KEY);
    if (user != null) {
      _user = User.fromJson(user);
      return _user;
    }
    return user;
  }

  setUser(User user) async {
    await _storage.write(key: _USER_KEY, value: user.toJson());
    _user = user;
    notifyListeners();
  }

  removeUser() {
    _user = null;
    _storage.delete(key: _USER_KEY);
    notifyListeners();
  }

  Future<LoginResponse> refreshToken() async {
    try {
      var resp = await _api.refreshToken();
      bool setted = await setToken(Token(resp.access_token));
      setUser(resp.user);
      return resp;
    } on Exception {
      logout();
      rethrow;
    }
  }

  Future<String?> getTokenFromStorage() async {
    var token = await _storage.read(key: _TOKEN_KEY);
    return token?.toString();
  }

  setToken(Token token) async {
    _api.setToken(token.token);
    await _storage.write(key: _TOKEN_KEY, value: token.token);
    notifyListeners();
    return true;
  }

  removeToken() async {
    await _removeProtection();
    _storage.delete(key: _TOKEN_KEY);
    notifyListeners();
  }

  _removeProtection() async {
    await _storage.delete(key: _TOKEN_PROTECTED);
    return true;
  }

  Future<LoginResponse> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      LoginResponse response = await _api.login(email, password);
      await setToken(Token(response.access_token));
      await setUser(response.user);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      logout();
      rethrow;
    }
  }

  Future<LoginResponse> register(String name, String phone, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      LoginResponse response = await _api.register(name, phone, email, password);
      await setToken(Token(response.access_token));
      await setUser(response.user);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      logout();
      rethrow;
    }
  }

  Future<bool> logout() async {
    await removeToken();
    await removeUser();
    return true;
  }
}