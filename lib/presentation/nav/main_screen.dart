import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SaveIt/utils/ui/app_colors.dart';

import 'package:SaveIt/presentation/graph/graph_screen.dart';
import 'package:SaveIt/presentation/savings/savings_screen.dart';
import 'package:SaveIt/presentation/transactions/transaction_register_screen.dart';
import 'package:SaveIt/presentation/coins/coins_screen.dart';
import 'package:SaveIt/presentation/perfil/perfil_screen.dart';

import 'package:SaveIt/providers/bottom_bar_provider.dart';

class MainScreen extends StatefulWidget {
  static String id = 'main_screen';

  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final bottomBarProvider = Provider.of<BottomBarProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: bottomBarProvider.selectedTab,
        children: const [
          GraphScreen(),
          SavingsScreen(),
          TransactionRegisterScreen(),
          CoinsScreen(),
          PerfilScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomBarProvider.selectedTab,
        onTap: (index) {
          bottomBarProvider.changeSelectedTab(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.principal,
        backgroundColor: AppColors.secondary.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Gráfico"),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: "Ahorros"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Registrar"),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Monedas"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
