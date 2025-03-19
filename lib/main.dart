import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importación de archivos internos
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/utils/ui/theme.dart';

// Pantallas
import 'package:SaveIt/presentation/auth/auth_screen.dart';
import 'package:SaveIt/presentation/nav/main_screen.dart';
import 'package:SaveIt/presentation/graph/graph_screen.dart';
import 'package:SaveIt/presentation/savings/savings_screen.dart';
import 'package:SaveIt/presentation/transactions/transaction_register_screen.dart';
import 'package:SaveIt/presentation/coins/coins_screen.dart';
import 'package:SaveIt/presentation/perfil/perfil_screen.dart';
import 'package:SaveIt/presentation/load/splash_screen.dart';

import 'package:SaveIt/providers/bottom_bar_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomBarProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkUserSession()), // Carga la sesión al iniciar
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "SaveIt",
            theme: AppTheme.lightTheme,
            home: authProvider.isLoading
                ? SplashScreen() // Muestra pantalla de carga mientras verifica sesión
                : (authProvider.isLoggedIn ? MainScreen() : AuthScreen()), // Dirige a la pantalla correspondiente
            routes: {
              MainScreen.id: (context) => MainScreen(),
              AuthScreen.id: (context) => AuthScreen(),
              SplashScreen.id: (context) => SplashScreen(),
              GraphScreen.id: (context) => GraphScreen(),
              SavingsScreen.id: (context) => SavingsScreen(),
              TransactionRegisterScreen.id: (context) => TransactionRegisterScreen(),
              CoinsScreen.id: (context) => CoinsScreen(),
              PerfilScreen.id: (context) => PerfilScreen(),
            },
          );
        },
      ),
    );
  }
}
