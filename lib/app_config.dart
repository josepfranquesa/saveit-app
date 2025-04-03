import 'package:flutter/widgets.dart';

class AppConfig extends InheritedWidget {
  const AppConfig(
      {super.key, required this.appName,
        required this.flavorName,
        required this.apiBaseUrl,
        required this.debugShowCheckedModeBanner,
        required super.child});

  final String appName;
  final String flavorName;
  final String apiBaseUrl;
  final bool debugShowCheckedModeBanner;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}