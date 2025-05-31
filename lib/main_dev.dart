import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'app_config.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final jsonString = await rootBundle.loadString('lib/config/dev_config.json');
  // final configData = json.decode(jsonString);

  var configuredApp = AppConfig(
    appName: 'SaveIt',
    flavorName: 'development',
    apiBaseUrl: Platform.isAndroid ? "http://10.0.2.2:8000/api" : "http://localhost:8000/api",    debugShowCheckedModeBanner: true,
    child: const SaveItApp(),
  );

  runApp(configuredApp);
}
