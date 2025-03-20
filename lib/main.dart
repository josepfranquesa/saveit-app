import 'dart:io';
import 'package:SaveIt/app_config.dart';
import 'package:SaveIt/presentation/auth/auth_screen.dart';
import 'package:SaveIt/presentation/nav/main_screen.dart';
import 'package:SaveIt/providers/bottom_bar_provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:SaveIt/utils/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveIt/presentation/load/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔹 Configuración de `AppConfig`
  var configuredApp = AppConfig(
    appName: 'SaveIt',
    flavorName: 'development',
    apiBaseUrl: Platform.isAndroid ? "http://10.0.2.2:8000/api/v1" : "http://localhost:8000/api/v1",
    debugShowCheckedModeBanner: true,
    child: const SaveIt(),
  );

  runApp(configuredApp);
}

class SaveIt extends StatelessWidget {
  const SaveIt({super.key});

  @override
  Widget build(BuildContext context) {
    /// 🔹 Acceder a la configuración desde `AppConfig`
    final config = AppConfig.of(context);

    /// 🛑 Si `config` es null, mostrar un error amigable
    if (config == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              "⚠️ Error: Configuración no encontrada",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        /// 🔹 Se cambia `Provider` por `ChangeNotifierProvider`
        ChangeNotifierProvider<ApiProvider>(
          create: (_) => ApiProvider(url: config.apiBaseUrl),
        ),

        /// 🔹 Proxy Provider para `AuthProvider`, asegurando que se pase `ApiProvider` correctamente
        ChangeNotifierProxyProvider<ApiProvider, AuthProvider>(
          create: (context) {
            final api = Provider.of<ApiProvider>(context, listen: false);
            final authProvider = AuthProvider(api: api);
            authProvider.checkUserSession();
            return authProvider;
          },
          update: (_, api, authProvider) {
            authProvider!..updateApi(api);
            return authProvider;
          },
        ),

        /// 🔹 Proveedor del `BottomBarProvider`
        ChangeNotifierProvider(create: (_) => BottomBarProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: config.appName,
            debugShowCheckedModeBanner: config.debugShowCheckedModeBanner,
            theme: AppTheme.lightTheme,
            home: authProvider.isLoading
                ? SplashScreen()
                : (authProvider.isLoggedIn ? MainScreen() : AuthScreen()),
          );
        },
      ),
    );
  }
}
