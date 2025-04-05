import 'package:SaveIt/app_config.dart';
import 'package:SaveIt/presentation/auth/login_screen.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/bottom_bar_provider.dart';
import 'package:SaveIt/providers/login_form_provider.dart';
import 'package:SaveIt/providers/perfil_provider.dart';
import 'package:SaveIt/providers/register_form_provider.dart';
import 'package:SaveIt/providers/transaction_register_provider.dart';
//import 'package:SaveIt/providers/settings_provider.dart';
//import 'package:SaveIt/providers/user_form_provider.dart';
import 'package:SaveIt/services/api.provider.dart';
import 'package:SaveIt/utils/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SaveItApp());
}

class SaveItApp extends StatelessWidget {
  const SaveItApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var config = AppConfig.of(context);

    return MultiProvider(
      providers: [
        ListenableProvider<ApiProvider>(create: (_) => ApiProvider(url: config!.apiBaseUrl)),
        ListenableProxyProvider<ApiProvider, AuthProvider>(update: (_, api, __) => AuthProvider(api: api),),
        ChangeNotifierProvider(create: (context) => BottomBarProvider()),
        ListenableProxyProvider<ApiProvider, LoginFormProvider>(update: (_, api, __) => LoginFormProvider(api: api),),
        ListenableProxyProvider<ApiProvider, RegisterFormProvider>(update: (_, api, __) => RegisterFormProvider(api: api),),
        ListenableProxyProvider2<ApiProvider, AuthProvider, TransactionRegisterProvider>(update: (_, api, auth, __) => TransactionRegisterProvider(api: api, auth: auth),),
        ListenableProxyProvider2<ApiProvider, AuthProvider, PerfilProvider>(update: (_, api, auth, __) => PerfilProvider(api: api, auth: auth),),
      ],
      child: MaterialApp(
        title: config!.appName,
        debugShowCheckedModeBanner: config.debugShowCheckedModeBanner,
        theme: SaveItTheme.light,
        home:  const LoginScreen(),
      ),
    );
  }
}
