import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveIt/providers/auth_provider.dart';

class PerfilScreen extends StatefulWidget {
  static String id = 'perfil_screen';

  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Lista de cuentas ficticias
  List<Map<String, String>> accounts = [
    {"service": "Cuenta 1", "account": "personal"},
    {"service": "Cuenta 2", "account": "pareja"},
    {"service": "Cuenta 3", "account": "familia"},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Datos de usuario ficticios
    final String userName = authProvider.user?["name"] ?? "Nombre Usuario";
    final String userEmail = authProvider.user?["email"] ?? "usuario@example.com";
    final String userPhone = authProvider.user?["phone"] ?? "+123 456 789";

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📸 Foto de perfil
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://via.placeholder.com/150"),
            ),
            const SizedBox(height: 16),

            // 📝 Información del usuario
            Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(userEmail, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(userPhone, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),

            // 💾 Listado de cuentas de servicios
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Cuentas Registradas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: Text(account["service"] ?? ""),
                      subtitle: Text(account["account"] ?? ""),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            accounts.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Cuenta eliminada")),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 🔘 Botones de Cerrar Sesión y Eliminar Cuenta en una Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 🔴 Botón de Eliminar Cuenta (Rojo con texto blanco)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // Implementar lógica para eliminar cuenta
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Función de eliminar cuenta en desarrollo")),
                    );
                  },
                  child: const Text("Eliminar Cuenta", style: TextStyle(color: Colors.white)),
                ),

                // ⚪ Botón de Cerrar Sesión (Blanco con texto rojo)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red, // Texto rojo
                    side: const BorderSide(color: Colors.red), // Borde rojo
                  ),
                  onPressed: () {
                    authProvider.logout();
                    Navigator.pushReplacementNamed(context, 'auth_screen');
                  },
                  child: const Text("Cerrar Sesión"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
