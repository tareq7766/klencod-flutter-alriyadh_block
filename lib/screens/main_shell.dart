import 'package:flutter/material.dart';
import '../services/product_repository.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'contact_screen.dart';
import 'about_screen.dart';
import 'admin_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  static const _titles = ['الرئيسية', 'المنتجات', 'التواصل', 'عن المصنع', 'لوحة الإدارة'];
  static const _screens = <Widget>[HomeScreen(), ProductsScreen(), ContactScreen(), AboutScreen(), AdminScreen()];

  @override
  void initState() {
    super.initState();
    ProductRepository.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'المنتجات'),
          NavigationDestination(icon: Icon(Icons.phone_outlined), selectedIcon: Icon(Icons.phone), label: 'التواصل'),
          NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'عن المصنع'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'الإدارة'),
        ],
      ),
    );
  }
}