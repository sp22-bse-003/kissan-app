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

  // Keys for refreshing screens
  Key _productsKey = UniqueKey();
  Key _cartKey = UniqueKey();
  Key _knowledgeHubKey = UniqueKey();
  Key _profileKey = UniqueKey();

  List<Widget> get _screens => [
    ProductsScreen(key: _productsKey),
    CartScreen(key: _cartKey),
    KnowledgeHubScreen(key: _knowledgeHubKey),
    ProfileScreen(key: _profileKey),
  ];

  void _onItemTapped(int index) {
    // If tapping the same tab, refresh it
    if (index == _selectedIndex) {
      setState(() {
        switch (index) {
          case 0:
            _productsKey = UniqueKey();
            break;
          case 1:
            _cartKey = UniqueKey();
            break;
          case 2:
            _knowledgeHubKey = UniqueKey();
            break;
          case 3:
            _profileKey = UniqueKey();
            break;
        }
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.eco, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'KISSAN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF00E676)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      drawer: const CustomDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF00C853),
              unselectedItemColor: Colors.grey,
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
