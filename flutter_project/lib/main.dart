import 'package:flutter/material.dart';
import 'package:flutter_project/AuthCheckPage.dart';
import 'package:flutter_project/provider/Package_Detail_Provider.dart';
import 'package:flutter_project/provider/bottom_nav_provider.dart';
import 'package:flutter_project/provider/favorite_provider.dart';
import 'package:flutter_project/provider/package_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BottomNavProvider()),
      ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ChangeNotifierProvider(create: (_) => PackageProvider()), 
      ChangeNotifierProvider(create: (_) => PackageDetailProvider()),
    ],
    child: const MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.white,
          ), // ✅ ทำให้ปุ่ม back สีขาว
          backgroundColor: Color(0xFF084886),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),

      home: AuthCheckPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
