
import 'dart:io';

import 'package:SaveIt/main.dart';
import 'package:flutter/material.dart';
import 'app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var configuredApp = AppConfig(
    appName: 'SaveIt',
    flavorName: 'development',
    // apiBaseUrl: "http://192.168.1.100:8000/api/v1",
    apiBaseUrl: Platform.isAndroid ? "http://10.0.2.2:8000/api/v1" :"http://localhost:8000/api/v1",
    child: new SaveIt(),
    debugShowCheckedModeBanner: true,
  );

  runApp(configuredApp);
}