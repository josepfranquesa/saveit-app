import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveIt/app_config.dart';
import 'package:SaveIt/presentation/user/user_screen.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/services/auth_service.dart';
import 'package:SaveIt/utils/ui/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Proveedor de autenticación
      ],
      child: MaterialApp(
        title: "SaveIt",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Asegúrate de tener un archivo con el tema
        initialRoute: UserScreen.id, // Página de inicio
        routes: {
          UserScreen.id: (context) => UserScreen(),
        },
      ),
    );
  }
}



/*nova versio, codi Ivan

import 'package:beltime_app/app_config.dart';
import 'package:beltime_app/domain/insurance_branch.dart';
import 'package:beltime_app/presentation/splash_screen/splash_screen.dart';
import 'package:beltime_app/providers/adviser_provider.dart';
import 'package:beltime_app/providers/auth_provider.dart';
import 'package:beltime_app/providers/benefit_detail_provider.dart';
import 'package:beltime_app/providers/benefits_provider.dart';
import 'package:beltime_app/providers/bottom_bar_provider.dart';
import 'package:beltime_app/providers/insurance_branch_provider.dart';
import 'package:beltime_app/providers/insurance_detail_provider.dart';
import 'package:beltime_app/providers/insurance_provider.dart';
import 'package:beltime_app/providers/login_form_provider.dart';
import 'package:beltime_app/providers/register_form_provider.dart';
import 'package:beltime_app/providers/settings_provider.dart';
import 'package:beltime_app/providers/user_form_provider.dart';
import 'package:beltime_app/services/api.provider.dart';
import 'package:beltime_app/utils/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const BeltimeApp());
}

class BeltimeApp extends StatelessWidget {
  const BeltimeApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var config = AppConfig.of(context);

    return MultiProvider(
      providers: [
        ListenableProvider<ApiProvider>(create: (_) => ApiProvider(url: config!.apiBaseUrl)),
        ListenableProxyProvider<ApiProvider, AuthProvider>(update: (_, api, __) => AuthProvider(api: api),),
        ChangeNotifierProvider(create: (context) => BottomBarProvider()),
        ListenableProxyProvider<ApiProvider, SettingsProvider>(update: (_, api, __) => SettingsProvider(api: api),),
        ListenableProxyProvider<ApiProvider, LoginFormProvider>(update: (_, api, __) => LoginFormProvider(api: api),),
        ListenableProxyProvider<ApiProvider, RegisterFormProvider>(update: (_, api, __) => RegisterFormProvider(api: api),),
        ListenableProxyProvider<ApiProvider, InsuranceProvider>(update: (_, api, __) => InsuranceProvider(api: api),),
        ListenableProxyProvider<ApiProvider, InsuranceBranchProvider>(update: (_, api, __) => InsuranceBranchProvider(api: api),),
        ListenableProxyProvider<ApiProvider, AdviserProvider>(update: (_, api, __) => AdviserProvider(api: api),),
        ListenableProxyProvider2<ApiProvider, AuthProvider, UserFormProvider>(update: (_, api, auth, __) => UserFormProvider(api: api, auth: auth),),
        ListenableProxyProvider<ApiProvider, InsuranceDetailProvider>(update: (_, api, __) => InsuranceDetailProvider(api: api),),
        ListenableProxyProvider<ApiProvider, BenefitsProvider>(update: (_, api, __) => BenefitsProvider(api: api),),
        ListenableProxyProvider<ApiProvider, BenefitDetailProvider>(update: (_, api, __) => BenefitDetailProvider(api: api),),
      ],
      child: MaterialApp(
        title: config!.appName,
        debugShowCheckedModeBanner: config.debugShowCheckedModeBanner,
        theme: BeltimeTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}*/