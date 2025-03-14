import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool selectLogin = true;
  String name = "";
  String phone = "";
  String email = "";
  String email2 = "";
  String password = "";
  String password2 = "";

  void toggleLogin(bool value) {
    selectLogin = value;
    notifyListeners();
  }

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
}
