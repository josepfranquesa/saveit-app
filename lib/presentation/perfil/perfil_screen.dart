import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  static String id = 'perfil_screen';

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Center(
        child: Text(
          'Página de perfil',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
