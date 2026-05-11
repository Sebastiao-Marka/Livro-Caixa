import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/routes/app_routes.dart';
import '../main.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Uri uri = Uri.parse(
    "https://play.google.com/store/apps/details?id=com.portalcomercial&pcampaignid=web_share",
  );
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.main, arguments: false);
              },
              child: Icon(Icons.bar_chart),
            ),
            label: 'Painel',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lançamentos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Categorias',
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          await launch(
            'https://play.google.com/store/apps/details?id=com.portalcomercial&pcampaignid=web_share',
          );
        },
        child: Image.asset("assets/zabe_icon.png", width: 50),
      ),
    );
  }
}
