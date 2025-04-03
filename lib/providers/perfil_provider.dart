// providers/perfil_provider.dart
// ignore_for_file: non_constant_identifier_names

import 'package:SaveIt/domain/user.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class PerfilProvider with ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  User? _user;
  User? get user => _user;

  late ApiProvider _api;
  late AuthProvider _auth;
  bool initialized = false;
  bool isLoading = false;

  // Constructor SINGLETON
  static PerfilProvider _instancia = PerfilProvider._internal();
  PerfilProvider._internal();
  factory PerfilProvider({required ApiProvider api, required AuthProvider auth}) {
    if (!_instancia.initialized) {
      _instancia = PerfilProvider._internal();
      _instancia._api = api;
      _instancia._auth = auth;
      _instancia.initialized = true;
    }
    return _instancia;
  }

  // Actualiza los datos del usuario
  Future<List<String>?> updateUser(User user) async {
    if (!isLoading) {
      try {
        isLoading = true;
        User? u = await _api.updateUser(user);
        if (u != null) _auth.setUser(u);
        isLoading = false;
        notifyListeners();
        return [];
      } on DioException {
        isLoading = false;
        notifyListeners();
        return ['Algo salió mal', 'error'];
      } on Exception {
        isLoading = false;
        notifyListeners();
        return ['Algo salió mal', 'error'];
      }
    }
    return null;
  }

  // Función para cerrar sesión
  Future<bool> logout() async {
    await _auth.logout();
    return true;
  }

  // Función para obtener las cuentas del usuario
  Future<List<dynamic>> fetchAccounts() async {
    if (_auth.user == null) {
      return [];
    }
    final response = await _api.getAccountsByUserId(_auth.user!.id);
    // Se asume que response.data es una lista de cuentas
    return response.data;
  }

  // Función para eliminar la cuenta del usuario (y cerrar sesión)
  Future<bool> deleteUser(int userId) async {
    try {
      final response = await _api.deleteUser(userId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await logout();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
