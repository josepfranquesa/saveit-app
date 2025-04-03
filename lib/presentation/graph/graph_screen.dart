import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  static String id = 'graph_screen';

  const GraphScreen({super.key});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos'),
      ),
      body: const Center(
        child: Text(
          'Página de gráficos',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
