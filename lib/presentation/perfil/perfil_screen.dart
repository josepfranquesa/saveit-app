import 'package:SaveIt/domain/user.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/perfil_provider.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';
import 'package:SaveIt/utils/ui/widgets/filled_simple_button.dart';
import 'package:SaveIt/utils/helpers/utils_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  User? _user;
  late PerfilProvider _perfilProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
      // Inicializamos _user con el usuario autenticado o con un usuario demo
      setState(() {
        _user = authProvider.user ??
            User(
              id: 0,
              name: 'Usuario Demo',
              email: 'demo@email.com',
              phone: '000000000',
            );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mientras _user sea null, mostramos un indicador de carga
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Perfil"),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          color: AppColors.backgroundInApp,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bloque superior: Información del usuario
              _buildUserInfo(),
              const SizedBox(height: 20),
              // Bloque central: Lista de cuentas
              Expanded(child: _buildAccountsList()),
              const SizedBox(height: 20),
              // Bloque inferior: Botones de cerrar sesión y eliminar cuenta
              _buildButtonsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _user!.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _user!.email,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _user!.phone,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList() {
    return FutureBuilder(
      future: _perfilProvider.fetchAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar las cuentas"));
        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return const Center(child: Text("No hay cuentas disponibles"));
        } else {
          List accounts = snapshot.data as List;
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account['name'] ?? 'Cuenta ${account['id'] ?? index}'),
                subtitle: Text("ID: ${account['id'] ?? ''}"),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón de Cerrar sesión
        Expanded(
          child: FilledSimpleButton(
            text: "Cerrar sesión",
            onPressedFunction: (ctx) async {
              await _perfilProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        // Botón de Eliminar cuenta
        Expanded(
          child: FilledSimpleButton(
            text: "Eliminar cuenta",
            onPressedFunction: (ctx) async {
              bool success = await _perfilProvider.deleteUser(_user!.id);
              if (success) {
                AppUtils.toast(context, title: "Cuenta eliminada", type: "success");
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                AppUtils.toast(context, title: "Error al eliminar la cuenta", type: "error");
              }
            },
          ),
        ),
      ],
    );
  }
}
