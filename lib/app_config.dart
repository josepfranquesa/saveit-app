import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  AppConfig(
      {required this.appName,
        required this.flavorName,
        required this.apiBaseUrl,
        required this.debugShowCheckedModeBanner,
        required Widget child})
      : super(child: child);

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