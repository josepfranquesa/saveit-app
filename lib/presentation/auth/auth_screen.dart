import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/ui/widgets/text_field_general.dart';
import '../../utils/ui/theme.dart';
import '../transactions/transaction_register_screen.dart';
import 'package:SaveIt/presentation/nav/main_screen.dart';


class AuthScreen extends StatefulWidget {
  static String id = 'auth_screen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Set<String> errorFields = {}; // Solo almacena los nombres de los campos con errores

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Color(0xFF7B046F),
                Color(0xFFFFA0D8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_login.png',
                  height: 200,
                  width: 300,
                  fit: BoxFit.contain,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => authProvider.toggleLogin(true)),
                      child: Column(
                        children: [
                          const Text(
                            'Iniciar sesión',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          if (authProvider.selectLogin)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 3,
                              width: 100,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => authProvider.toggleLogin(false)),
                      child: Column(
                        children: [
                          const Text(
                            'Registrarse',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          if (!authProvider.selectLogin)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 3,
                              width: 100,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                authProvider.selectLogin ? _columnLogin(authProvider) : _columnSignUp(authProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _columnSignUp(AuthProvider authProvider) {
    return Column(
      children: [
        TextFieldGeneral(
          labelText: 'Nombre',
          icon: const Icon(Icons.person_outline),
          onChanged: authProvider.setName,
          hasError: errorFields.contains("name"),
        ),
        TextFieldGeneral(
          labelText: 'Teléfono',
          icon: const Icon(Icons.phone),
          onChanged: authProvider.setPhone,
          hasError: errorFields.contains("phone"),
        ),
        TextFieldGeneral(
          labelText: 'Correo',
          icon: const Icon(Icons.email),
          onChanged: authProvider.setEmail,
          hasError: errorFields.contains("email"),
        ),
        TextFieldGeneral(
          labelText: 'Repite el correo',
          icon: const Icon(Icons.mark_email_read),
          onChanged: authProvider.setEmail2,
          hasError: errorFields.contains("email_confirmation"),
        ),
        TextFieldGeneral(
          labelText: 'Contraseña',
          icon: const Icon(Icons.lock_outline_rounded),
          obscureText: true,
          onChanged: authProvider.setPassword,
          hasError: errorFields.contains("password"),
        ),
        TextFieldGeneral(
          labelText: 'Repite contraseña',
          icon: const Icon(Icons.sync_lock),
          obscureText: true,
          onChanged: authProvider.setPassword2,
          hasError: errorFields.contains("password_confirmation"),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
          ),
          child: const Text(
            'Registrarse',
            style: TextStyle(color: Color(0xFF7B046F), fontSize: 20),
          ),
          onPressed: () async {
            Map<String, dynamic> result = await AuthService.registerUser(
              name: authProvider.name,
              phone: authProvider.phone,
              email: authProvider.email,
              email2: authProvider.email2,
              password: authProvider.password,
              password2: authProvider.password2,
            );

            setState(() {
              errorFields.clear();
              if (!result["success"] && result.containsKey("error_fields")) {
                errorFields.addAll(List<String>.from(result["error_fields"]));
              }
            });

            String errorMessage;

            if (result["success"]) {
              errorMessage = result["message"] ?? "Registro exitoso";
              authProvider.toggleLogin(true);
            } else {
              errorMessage = result.containsKey("errors")
                  ? result["errors"].values.join("\n")
                  : result["message"] ?? "Error inesperado";
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          },
        ),
      ],
    );
  }

  Widget _columnLogin(AuthProvider authProvider) {
    return Column(
      children: [
        TextFieldGeneral(
          labelText: 'Correo',
          icon: const Icon(Icons.email),
          onChanged: authProvider.setEmail,
          hasError: errorFields.contains("email"),
        ),
        TextFieldGeneral(
          labelText: 'Contraseña',
          icon: const Icon(Icons.lock_outline_rounded),
          obscureText: true,
          onChanged: authProvider.setPassword,
          hasError: errorFields.contains("password"),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
          ),
          child: const Text(
            'Iniciar sesión',
            style: TextStyle(color: Color(0xFF7B046F), fontSize: 20),
          ),
          onPressed: () async {
            Map<String, dynamic> result = await AuthService.loginUser(
              email: authProvider.email,
              password: authProvider.password,
            );

            setState(() {
              errorFields.clear();
              if (!result["success"] && result.containsKey("error_fields")) {
                errorFields.addAll(List<String>.from(result["error_fields"]));
              }
            });

            if (result["success"]) {
              // 🔹 Guardar estado de autenticación en el AuthProvider
              authProvider.setLoggedIn(true);

              // 🔹 Redirigir a MainScreen y eliminar historial de navegación
              Navigator.pushReplacementNamed(context, MainScreen.id);
            } else {
              String errorMessage = result.containsKey("errors")
                  ? result["errors"].values.join("\n")
                  : result["message"] ?? "Error inesperado";

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            }
          },
        ),
      ],
    );
  }

}
