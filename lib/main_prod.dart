import 'package:flutter/material.dart';
import 'package:SaveIt/app_config.dart';
import 'main.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var configuredApp = const AppConfig(
    appName: 'SaveIt',
    flavorName: 'production',
    apiBaseUrl: 'https://api.saveit.es',
    debugShowCheckedModeBanner: false,
    child: SaveItApp(),
  );

  runApp(configuredApp);
}