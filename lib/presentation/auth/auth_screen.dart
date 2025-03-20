import 'package:SaveIt/services/api.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/login_response.dart';
import '../../providers/auth_provider.dart';
import '../../utils/ui/widgets/text_field_general.dart';
import '../../utils/ui/app_colors.dart';
import '../nav/main_screen.dart';

class AuthScreen extends StatefulWidget {
  static String id = 'auth_screen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final Set<String> errorFields = {}; // Almacena los nombres de los campos con errores

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                AppColors.principal,
                AppColors.secondary,
              ],
            ),
          ),
          child: Center(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider == null) {
                  return const CircularProgressIndicator();
                }
                return Column(
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
                          onTap: () => authProvider.toggleLogin(true),
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
                          onTap: () => authProvider.toggleLogin(false),
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
                    authProvider.selectLogin ? _buildLoginForm(authProvider) : _buildRegisterForm(authProvider),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
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
          child: authProvider.isLoading
              ? const CircularProgressIndicator(color: AppColors.principal)
              : const Text('Iniciar sesión', style: TextStyle(color: AppColors.principal, fontSize: 20)),
          onPressed: authProvider.isLoading ? null : () async {
            _handleLogin(authProvider);
          },
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider) {
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
          child: authProvider.isLoading
              ? const CircularProgressIndicator(color: AppColors.principal)
              : const Text('Registrarse', style: TextStyle(color: AppColors.principal, fontSize: 20)),
          onPressed: authProvider.isLoading ? null : () async {
            _handleRegister(authProvider);
          },
        ),
      ],
    );
  }

  void _handleLogin(AuthProvider authProvider) async {
    try {
      await authProvider.login(authProvider.email, authProvider.password);
      Navigator.pushReplacementNamed(context, MainScreen.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en el inicio de sesión: \$e")),
      );
    }
  }

  void _handleRegister(AuthProvider authProvider) async {
    try {
      await authProvider.register(authProvider.name, authProvider.email, authProvider.password, authProvider.phone, "");
      Navigator.pushReplacementNamed(context, MainScreen.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en el registro: \$e")),
      );
    }
  }
}
