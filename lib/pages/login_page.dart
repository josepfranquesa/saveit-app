/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../presentation/transactions/transaction_register_screen.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  static String id = 'login_page';

  const LoginPage({super.key});

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  bool selectLogin = true;

  // Variables para almacenar los datos ingresados
  String _name = "";
  String _phone = "";
  String _email = "";
  String _email2 = "";
  String _password = "";
  String _password2 = "";

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
                      onTap: () {
                        setState(() {
                          selectLogin = true;
                        });
                      },
                      child: Column(
                        children: [
                          const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectLogin)
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
                      onTap: () {
                        setState(() {
                          selectLogin = false;
                        });
                      },
                      child: Column(
                        children: [
                          const Text(
                            'Registrarse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!selectLogin)
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
                (selectLogin) ? _columnLogin() : _columnSignUp(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _columnSignUp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 15),
        _textFieldName(),
        const SizedBox(height: 15),
        _textFieldPhone(),
        const SizedBox(height: 15),
        _textFieldEmail(),
        const SizedBox(height: 15),
        _textFieldReapeatEmail(),
        const SizedBox(height: 15),
        _textFieldPassword(),
        const SizedBox(height: 15),
        _textFieldReapeatPassword(),
        const SizedBox(height: 30),
        _buttonSignUp(),
      ],
    );
  }

  Widget _columnLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        _textFieldEmail(),
        const SizedBox(height: 30),
        _textFieldPassword(),
        const SizedBox(height: 30),
        TextButton(
          onPressed: () {
            // Agregar funcionalidad de recuperación de contraseña
          },
          child: const Text(
            '¿Olvidé mi contraseña?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buttonLogin(),
      ],
    );
  }

  Widget _textFieldName() {
    return _TextFieldGeneral(
      labelText: 'Nombre',
      icon: const Icon(Icons.person_outline),
      onChanged: (value) {
        setState(() {
          _name = value;
        });
      },
    );
  }

  Widget _textFieldPhone() {
    return _TextFieldGeneral(
      labelText: 'Teléfono',
      icon: const Icon(Icons.phone),
      onChanged: (value) {
        setState(() {
          _phone = value;
        });
      },
    );
  }

  Widget _textFieldEmail() {
    return _TextFieldGeneral(
      labelText: 'Correo',
      icon: const Icon(Icons.email),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          _email = value;
        });
      },
    );
  }
  Widget _textFieldReapeatEmail() {
    return _TextFieldGeneral(
      labelText: 'Repite el correo',
      icon: const Icon(Icons.mark_email_read),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          _email2 = value;
        });
      },
    );
  }

  Widget _textFieldPassword() {
    return _TextFieldGeneral(
      labelText: 'Contraseña',
      icon: const Icon(Icons.lock_outline_rounded),
      onChanged: (value) {
        setState(() {
          _password = value;
        });
      },
      obscureText: true,
    );
  }

  Widget _textFieldReapeatPassword() {
    return _TextFieldGeneral(
      labelText: 'Repite contraseña',
      icon: const Icon(Icons.sync_lock),
      onChanged: (value) {
        setState(() {
          _password = value;
        });
      },
      obscureText: true,
    );
  }

  Widget _buttonSignUp() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      ),
      child: const Text(
        'Registrarse',
        style: TextStyle(color: Color(0xFF7B046F), fontSize: 20),
      ),
      onPressed: () {
        _registerUser();
      },
    );
  }

  Future<void> _registerUser() async {
    const String url = 'http://127.0.0.1:8000/api/register';

    Map<String, dynamic> userData = {
      "name": _name,
      "phone": _phone,
      "email": _email,
      "email_confirmation": _email2,
      "password": _password,
      "password_confirmation": _password2,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Registro exitoso: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro exitoso")),
        );
      } else {
        print("Error en el registro: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error de conexión: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo conectar con el servidor")),
      );
    }
  }

  Widget _buttonLogin() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
      ),
      child: const Text(
        'Iniciar sesión',
        style: TextStyle(color: Color(0xFF7B046F), fontSize: 20),
      ),
      onPressed: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        //await authProvider.login(authProvider.email, authProvider.password);

        if (authProvider.isLoggedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => TransactionRegisterScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error en el inicio de sesión")),
          );
        }
      },
    );
  }

  //void _logInUser() {
    // Implementar inicio de sesión aquí
  //}

}


class _TextFieldGeneral extends StatefulWidget {
  final String labelText;
  final Icon icon;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;

  const _TextFieldGeneral({
    required this.labelText,
    required this.icon,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  State<_TextFieldGeneral> createState() => _TextFieldGeneralState();
}

class _TextFieldGeneralState extends State<_TextFieldGeneral> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          prefixIcon: widget.icon,
          labelText: widget.labelText,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
*/