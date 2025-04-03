import 'package:flutter/material.dart';
import 'package:SaveIt/app_config.dart';
import 'main.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var configuredApp = AppConfig(
    appName: 'SaveIt',
    flavorName: 'preproduction',
    apiBaseUrl: 'https://test.api.saveit.es',
    debugShowCheckedModeBanner: true,
    child: new SaveItApp(),
  );

  runApp(configuredApp);
}