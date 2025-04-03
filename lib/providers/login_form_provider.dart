
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String status = '';
  bool show_password = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late ApiProvider _api;
  bool initialized = false;

  //Constructor + SINGLETON
  static LoginFormProvider _instancia = LoginFormProvider._internal();
  LoginFormProvider._internal();
  factory LoginFormProvider({required ApiProvider api}) {
    if(!_instancia.initialized) {
      _instancia = LoginFormProvider._internal();
      _instancia._api = api;

      //init streams
      _instancia.initialized = true;
    }

    return _instancia;
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set showPassword(bool value) {
    show_password = value;
    notifyListeners();
  }

  initForm() {
    email = '';
    password = '';
    status = '';
    show_password = false;
    notifyListeners();
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  Future<List<String>> login(BuildContext context) async {
    try {
      isLoading = true;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(email, password);
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