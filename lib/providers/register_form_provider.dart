
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RegisterFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String phone = '';
  String password = '';
  String repeat_password = '';

  bool show_password = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool initialized = false;

  //Constructor + SINGLETON
  static RegisterFormProvider _instancia = RegisterFormProvider._internal();
  RegisterFormProvider._internal();
  factory RegisterFormProvider({required ApiProvider api}) {
    if(!_instancia.initialized) {
      _instancia = RegisterFormProvider._internal();
      _instancia.initialized = true;
    }

    return _instancia;
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  setName(String value) {
    name = value;
    notifyListeners();
  }

  setEmail(String value) {
    email = value;
    notifyListeners();
  }

  setPassword(String value) {
    password = value;
    notifyListeners();
  }

  setRepeatPassword(String value) {
    repeat_password = value;
    notifyListeners();
  }

  setPhoneNumber(String value) {
    phone = value;
    notifyListeners();
  }

  set showPassword(bool value) {
    show_password = value;
    notifyListeners();
  }

  bool isValidForm() {
    return name != '' && email != '' && password != '' && repeat_password != '' && password == repeat_password  && email.contains('@') && phone.length == 9;
  }

  Future<List<String>> register(BuildContext context) async {
    try {
      isLoading = true;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.register(name, phone, email, password);
      isLoading = false;
      notifyListeners();
      return [];
    } on DioException catch (e) {
      isLoading = false;
      notifyListeners();
      Clipboard.setData(ClipboardData(text: e.toString()));
      if(e.response?.statusCode==401) return ['El correo y la contraseña no coinciden','error'];
      return ['Algo salió mal','error'];
    } on Exception catch (e) {
      isLoading = false;
      notifyListeners();
      Clipboard.setData(ClipboardData(text: e.toString()));
      return ['Algo salió mal','error'];
    }
  }
}