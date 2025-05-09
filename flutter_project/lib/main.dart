import 'package:flutter/material.dart';
import 'package:flutter_project/AuthCheckPage.dart';

void main() => runApp(const MyApp());

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
