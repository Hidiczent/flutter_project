import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/auth/pages/account_page.dart';
import 'package:laoepic_thesis_app/features/booking/pages/booking_history_page.dart';
import 'package:laoepic_thesis_app/features/favorite/pages/favorite_page.dart';
import 'package:laoepic_thesis_app/features/home/pages/home_page.dart';
import 'package:laoepic_thesis_app/features/package/pages/main_package_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/providers/bottom_nav_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

/// Bottom navigation shell after login.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  static const _shellColor = Color(0xFFF9F9F9);

  static const _tabs = <Widget>[
    HomePage(),
    MainPackagePage(),
    FavoritePage(),
    BookingHistoryPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<BottomNavProvider>();
    final i18n = context.watch<UiI18n>();

    return Scaffold(
      backgroundColor: _shellColor,
      body: IndexedStack(index: nav.currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _shellColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: nav.currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        iconSize: 22,
        onTap: nav.changeIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: i18n.tr(I18nKey.navHome),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.feed),
            label: i18n.tr(I18nKey.navPackage),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            label: i18n.tr(I18nKey.navFavorite),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.card_travel),
            label: i18n.tr(I18nKey.navTrip),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: i18n.tr(I18nKey.navAccount),
          ),
        ],
      ),
    );
  }
}
