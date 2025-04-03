import 'package:flutter/material.dart';
import 'package:SaveIt/app_config.dart';
import 'main.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var configuredApp = AppConfig(
    appName: 'SaveIt',
    flavorName: 'production',
    apiBaseUrl: 'https://api.saveit.es',
    debugShowCheckedModeBanner: false,
    child: new SaveItApp(),
  );

  runApp(configuredApp);
}