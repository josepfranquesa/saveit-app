import 'package:SaveIt/domain/user.dart';
import 'package:SaveIt/providers/auth_provider.dart';
import 'package:SaveIt/providers/perfil_provider.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';
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
    // Inicializar _user y _perfilProvider después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _perfilProvider = Provider.of<PerfilProvider>(context, listen: false);
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
    // Mientras _user sea null se muestra un loading
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
              // Información del usuario
              _buildUserInfo(),
              const SizedBox(height: 20),
              const Text(
                "Cuentas",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Lista de cuentas
              Expanded(child: _buildAccountsList()),
              const SizedBox(height: 20),
              // Botones: Cerrar sesión y Eliminar cuenta (usuario)
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
        } else if (!snapshot.hasData) {
          return const Center(child: Text("No hay datos disponibles"));
        } else {
          final dynamic data = snapshot.data;
          List accounts = [];
          if (data is List) {
            accounts = data;
          } else if (data is Map<String, dynamic>) {
            accounts = (data['accounts'] as List?) ?? [];
          }
          if (accounts.isEmpty) {
            return const Center(child: Text("No hay cuentas disponibles"));
          }
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              // Obtener la lista de usuarios asociados a la cuenta
              List<dynamic> accountUsers = account['account_user'] ?? [];
              // Extraer los nombres y unirlos con comas
              String usersNames = accountUsers.isNotEmpty
                  ? accountUsers.map((user) => user['name']).join(', ')
                  : 'Sin usuarios asignados';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Información de la cuenta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account['title'] ?? 'Cuenta ${account['id'] ?? index}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              usersNames,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Ícono de basura con confirmación para eliminar la cuenta
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(account['id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }



  void _showDeleteConfirmation(int accountId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dejar de formar parte de esta cuenta'),
          content: const Text('¿Estás seguro de que deseas salir esta cuenta?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Llama al método para eliminar la cuenta
                bool success = await _perfilProvider.deleteUserAccount(accountId, _user!.id);
                Navigator.of(context).pop(); // Cierra el diálogo
                if (success) {
                  AppUtils.toast(context, title: "Cuenta eliminada", type: "success");
                  setState(() {}); // Actualiza la lista de cuentas
                } else {
                  AppUtils.toast(context, title: "Error al eliminar la cuenta", type: "error");
                }
              },
              child: const Text(
                'Salir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón "Cerrar sesión": fondo blanco, borde rojo, texto rojo
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.danger, // Color del texto
              side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size(0, 40), // Altura mínima 40
            ),
            onPressed: () async {
              await _perfilProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(fontSize: 14, color: AppColors.danger),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Botón "Eliminar cuenta": fondo rojo, borde blanco, texto blanco
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white, // Color del texto
              side: const BorderSide(color: AppColors.white),
              minimumSize: const Size(0, 40),
            ),
            onPressed: () async {
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
            child: const Text(
              "Eliminar cuenta",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
