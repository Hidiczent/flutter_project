import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/Account_page.dart';
import 'package:flutter_project/Screens/BookingPages/historybook.dart';
import 'package:flutter_project/Screens/FavoritePages/Favorite.dart';
import 'package:flutter_project/Screens/HomePage/HomePage.dart';
import 'package:flutter_project/Screens/PackagePages/Main_PackagePage.dart';
import 'package:provider/provider.dart';
import '../provider/bottom_nav_provider.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final List<Widget> pages = const [
    HomePage(),
    PackagePage(),
    FavoritePage(),
    BookingHistoryPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);

    return Scaffold(
      // ✅ ใช้ IndexedStack เพื่อเก็บ state ของแต่ละหน้า
      body: Container(
        color: const Color(0xFFF9F9F9),
        child: IndexedStack(index: navProvider.currentIndex, children: pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFF9F9F9),
        type: BottomNavigationBarType.fixed,
        currentIndex: navProvider.currentIndex,
        selectedItemColor: const Color(0xFF084886),
        unselectedItemColor: Colors.grey,
        onTap: navProvider.changeIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Package'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.card_travel), label: 'Trip'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
