// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/login_response.dart';
import '../domain/token.dart';
import '../services/api.provider.dart';
import 'package:SaveIt/domain/user.dart';

class AuthProvider extends ChangeNotifier {
  static const _TOKEN_KEY = "savitl_token";
  static const _USER_KEY = "saveitl_user";

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late ApiProvider _api;

  User? _user;
  User? get user => _user;

  bool initialized = false;

  // Estado de UI para alternar entre Login y Registro
  bool _selectLogin = true;
  bool get selectLogin => _selectLogin;

  String _name = "";
  String _phone = "";
  String _email = "";
  String _email2 = "";
  String _password = "";
  String _password2 = "";

  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String get email2 => _email2;
  String get password => _password;
  String get password2 => _password2;

  void toggleLogin(bool value) {
    _selectLogin = value;
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setEmail2(String value) {
    _email2 = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setPassword2(String value) {
    _password2 = value;
    notifyListeners();
  }

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  // 🔹 Método para actualizar ApiProvider dinámicamente
  void updateApi(ApiProvider api) {
    _api = api;
    notifyListeners();
  }

  // Constructor
  AuthProvider({required ApiProvider api}) {
    _api = api;
    getUserFromStorage();
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkUserSession() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await isUserLogged();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> isUserLogged() async {
    return await _initTokenListener();
  }

  Future<bool> _initTokenListener() async {
    var token = await getTokenFromStorage();
    if (token != null) {
      try {
        _api.setToken(token);
        await refreshToken();
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<User?> getUserFromStorage() async {
    dynamic user = await _storage.read(key: _USER_KEY);
    if (user != null) {
      _user = User.fromJson(user);
      return _user;
    }
    return null;
  }

  Future<void> setUser(User user) async {
    await _storage.write(key: _USER_KEY, value: user.toJson());
    _user = user;
    notifyListeners();
  }

  Future<void> removeUser() async {
    _user = null;
    await _storage.delete(key: _USER_KEY);
    notifyListeners();
  }

  Future<LoginResponse> refreshToken() async {
    try {
      var resp = await _api.refreshToken();
      await setToken(Token(resp.access_token));
      await setUser(resp.user);
      return resp;
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<String?> getTokenFromStorage() async {
    return await _storage.read(key: _TOKEN_KEY);
  }

  Future<void> setToken(Token token) async {
    _api.setToken(token.token);
    await _storage.write(key: _TOKEN_KEY, value: token.token);
    notifyListeners();
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _TOKEN_KEY);
    notifyListeners();
  }

  Future<LoginResponse> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await _api.login(email, password);
      await setToken(Token(response.access_token));
      await setUser(response.user);
      setLoggedIn(true);
      return response;
    } catch (e) {
      await logout();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LoginResponse> register(String name, String email, String password, String phone_number, String phone_prefix) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await _api.register(name, email, password, phone_number, phone_prefix);
      await setToken(Token(response.access_token));
      await setUser(response.user);
      setLoggedIn(true);
      return response;
    } catch (e) {
      await logout();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    await removeToken();
    await removeUser();
    setLoggedIn(false);
    return true;
  }
}
