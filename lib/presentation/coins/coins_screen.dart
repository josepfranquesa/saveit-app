import 'package:flutter/material.dart';

class CoinsScreen extends StatefulWidget {
  static String id = 'coins_screen';

  @override
  _CoinsScreenState createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monedas'),
      ),
      body: Center(
        child: Text(
          'Página de monedas',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
