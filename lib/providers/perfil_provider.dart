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

  //Constructor + SINGLETON
  static PerfilProvider _instancia = PerfilProvider._internal();
  PerfilProvider._internal();
  factory PerfilProvider({required ApiProvider api, required AuthProvider auth}) {
    if(!_instancia.initialized) {
      _instancia = PerfilProvider._internal();
      _instancia._api = api;
      _instancia._auth = auth;
      _instancia.initialized = true;
    }

    return _instancia;
  }

  User initForm(User u) {
    return _user =
        User(
          id: 1,
          name: 'Test user fake',
          email: 'test@email.com',
          phone: '123456789',
        );
  }

  Future<List<String>?> updateUser(User user) async {
    if(!isLoading) {
      try {
        isLoading = true;
        User? u = await _api.updateUser(user);
        if(u!=null) _auth.setUser(user);
        isLoading = false;
        notifyListeners();
        return [];
      } on DioException {
        isLoading = false;
        notifyListeners();
        return ['Algo salió mal','error'];
      } on Exception {
        isLoading = false;
        notifyListeners();
        return ['Algo salió mal','error'];
      }
    }
    return null;
  }

  Future<bool> logout() async {
    await _auth.logout();
    return true;
  }
}