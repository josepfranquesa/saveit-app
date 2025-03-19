import 'package:flutter/material.dart';

class SavingsScreen extends StatefulWidget {
  static String id = 'savings_screen';

  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ahorros'),
      ),
      body: Center(
        child: Text(
          'Página de ahorro',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
