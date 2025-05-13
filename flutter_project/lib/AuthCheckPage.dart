import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/LogIN.dart';
import 'package:flutter_project/MainPage.dart';
import 'package:flutter_project/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthCheckPage extends StatelessWidget {
  const AuthCheckPage({super.key});

  // Function to check if the user is logged in
  // by verifying the JWT token stored in SharedPreferences.
  // Returns true if the token is valid, false otherwise.      
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/auth/verify-token'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    }
    return false;
  }


  /// Build method to display the appropriate page based on login status.
  /// If the user is logged in, show the MainPage.
  /// If not, show the LoginPage.
  /// Uses a FutureBuilder to handle the asynchronous checkLoginStatus function.
  /// Displays a loading indicator while waiting for the result.
  /// If the connection is waiting, show a CircularProgressIndicator.
  /// If the connection is done and the user is logged in, show the MainPage.
  /// If the connection is done and the user is not logged in, show the LoginPage.
  /// Uses the checkLoginStatus function to determine the login status. 
  @override 
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data == true) {
          return MainPage(); // ✅ ตอนนี้อยู่ใน scope ของ MultiProvider แล้ว
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
