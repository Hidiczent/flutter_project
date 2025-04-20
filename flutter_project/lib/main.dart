import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/signIN.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SignInPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
