import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  static String id = 'graph_screen';

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráficos'),
      ),
      body: Center(
        child: Text(
          'Página de gráficos',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
