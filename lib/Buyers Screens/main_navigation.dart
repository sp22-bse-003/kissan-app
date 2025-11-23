import 'package:flutter/material.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';
import 'custom_drawer.dart';
import '../Buyers Screens/cart_screen.dart';
import '../Buyers Screens/products_screen.dart';
import '../Buyers Screens/knowledge_hub_screen.dart';
import '../Buyers Screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProductsScreen(),
    const CartScreen(),
    const KnowledgeHubScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _initialScreens = [
    const ProductsScreen(),
    const CartScreen(),
    const KnowledgeHubScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      setState(() {
        _screens[index] = _initialScreens[index];
      });
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerItemSelected(String item) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
        ),
      ),
      drawer: const CustomDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.black,
              onTap: _onItemTapped,
              selectedFontSize: 14,
              unselectedFontSize: 13,
              iconSize: 28,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopify),
                  label: AppLocalizations.of(context)!.products,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_cart),
                  label: AppLocalizations.of(context)!.cart,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.book),
                  label: AppLocalizations.of(context)!.knowledgeHub,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: AppLocalizations.of(context)!.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
