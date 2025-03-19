import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  // Getters para la UI
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;

  // Estado de la UI para el login/registro
  bool selectLogin = true;
  String name = "";
  String phone = "";
  String email = "";
  String email2 = "";
  String password = "";
  String password2 = "";

  /// **Alternar entre Login y Registro**
  void toggleLogin(bool value) {
    selectLogin = value;
    notifyListeners();
  }

  // Métodos para actualizar los datos en la UI
  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setEmail2(String value) {
    email2 = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setPassword2(String value) {
    password2 = value;
    notifyListeners();
  }

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }


  /// **Verifica si el usuario ya tiene una sesión activa al iniciar la app**
  Future<void> checkUserSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      var response = await AuthService.checkToken();
      if (response["success"]) {
        _isLoggedIn = true;
        _user = response["user"];
        await _storage.write(key: "user", value: response["user"].toString());
      } else {
        _isLoggedIn = false;
        _user = null;
        await _storage.delete(key: "user");
      }
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// **Inicia sesión con email y contraseña**
  Future<Map<String, dynamic>> login() async {
    _isLoading = true;
    notifyListeners();

    var response = await AuthService.loginUser(
      email: email,
      password: password,
    );

    if (response["success"]) {
      _isLoggedIn = true;
      _user = response["user"];
      await _storage.write(key: "user", value: response["user"].toString());
      await _storage.write(key: "remember_token", value: response["token"]);
    } else {
      _isLoggedIn = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
    return response; // Devolver respuesta para manejar errores en la UI
  }

  /// **Registra un nuevo usuario**
  Future<Map<String, dynamic>> register() async {
    _isLoading = true;
    notifyListeners();

    var response = await AuthService.registerUser(
      name: name,
      phone: phone,
      email: email,
      email2: email2,
      password: password,
      password2: password2,
    );

    _isLoading = false;
    notifyListeners();
    return response; // Devolver respuesta para manejar errores en la UI
  }

  /// **Cierra sesión y borra datos del almacenamiento seguro**
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();
    await _storage.deleteAll();

    _isLoggedIn = false;
    _user = null;
    _isLoading = false;

    notifyListeners();
  }
}
