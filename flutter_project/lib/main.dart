import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/booking.dart';
import 'package:flutter_project/Auth/pages/home.dart';
import 'package:flutter_project/AuthCheckPage.dart';
import 'package:flutter_project/Auth/pages/tourbooking.dart'; 

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BookingFormPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
