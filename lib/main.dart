import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:SaveIt/app_config.dart';
import 'package:SaveIt/presentation/auth/login_screen.dart';
import 'package:SaveIt/providers/account_list_provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/bottom_bar_provider.dart';
import 'package:SaveIt/providers/coins_provider.dart';
import 'package:SaveIt/providers/graph_provider.dart';
import 'package:SaveIt/providers/login_form_provider.dart';
import 'package:SaveIt/providers/perfil_provider.dart';
import 'package:SaveIt/providers/register_form_provider.dart';
import 'package:SaveIt/providers/savings_provider.dart';
import 'package:SaveIt/providers/transaction_register_provider.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:SaveIt/utils/ui/theme.dart';

void main() {
  runApp(const SaveItApp());
}

class SaveItApp extends StatelessWidget {
  const SaveItApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.of(context);

    return MultiProvider(
      providers: [
        // 1. Cliente HTTP
        ListenableProvider<ApiProvider>(
          create: (_) => ApiProvider(url: config!.apiBaseUrl),
        ),

        // 2. Autenticación
        ListenableProxyProvider<ApiProvider, AuthProvider>(
          update: (_, api, __) => AuthProvider(api: api),
        ),

        // 3. Lista de cuentas
        ListenableProxyProvider<ApiProvider, AccountListProvider>(
          update: (_, api, __) => AccountListProvider(api),
        ),

        // 4. Formularios de login/register
        ListenableProxyProvider<ApiProvider, LoginFormProvider>(
          update: (_, api, __) => LoginFormProvider(api: api),
        ),
        ListenableProxyProvider<ApiProvider, RegisterFormProvider>(
          update: (_, api, __) => RegisterFormProvider(api: api),
        ),

        // 5. BBDD local de navegación inferior
        ChangeNotifierProvider(create: (_) => BottomBarProvider()),

        // 6. Transacciones (y hace uso de AuthProvider)
        ListenableProxyProvider2<ApiProvider, AuthProvider, TransactionRegisterProvider>(
          update: (_, api, auth, __) =>
              TransactionRegisterProvider(api: api, auth: auth),
        ),

        // 7. Otras secciones que necesitan ApiProvider + AuthProvider
        ListenableProxyProvider2<ApiProvider, AuthProvider, CoinsProvider>(
          update: (_, api, auth, __) => CoinsProvider(api: api, auth: auth),
        ),
        ListenableProxyProvider2<ApiProvider, AuthProvider, PerfilProvider>(
          update: (_, api, auth, __) => PerfilProvider(api: api, auth: auth),
        ),
        ListenableProxyProvider2<ApiProvider, AuthProvider, SavingsProvider>(
          update: (_, api, auth, __) => SavingsProvider(api: api, auth: auth),
        ),
        ListenableProxyProvider2<ApiProvider, AuthProvider, GraphProvider>(
          update: (_, api, auth, __) => GraphProvider(api: api, auth: auth),
        ),
      ],
      child: MaterialApp(
        title: config?.appName ?? 'SaveIt',
        debugShowCheckedModeBanner: config?.debugShowCheckedModeBanner ?? false,
        theme: SaveItTheme.light,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],

        home: const LoginScreen(),
      ),
    );
  }
}
