import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBarProvider with ChangeNotifier {
  int _selectedTab = 2; // Iniciar en "Registrar Transacción"

  int get selectedTab => _selectedTab;

  void changeSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }
}
