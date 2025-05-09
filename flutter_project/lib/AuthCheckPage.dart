import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/Login.dart';
import 'package:flutter_project/Auth/pages/home.dart';
import 'package:flutter_project/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  if (token != null && token.isNotEmpty) {
    // ทำการตรวจสอบ token ว่ายังไม่หมดอายุ
    final isTokenValid = await checkTokenValidity(token);
    if (isTokenValid) {
      // ถ้า token ยังไม่หมดอายุ → ไปหน้า Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // หากหมดอายุ → ไปหน้า Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  } else {
    // ❌ ไม่มี token → ไปหน้า Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

Future<bool> checkTokenValidity(String token) async {
  // ทำการส่ง request ไปยัง Backend เพื่อตรวจสอบว่า token ยังใช้ได้หรือไม่
  final response = await http.get(
    Uri.parse('${AppConfig.baseUrl}/auth/verify-token'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  return response.statusCode == 200;  // หาก token ใช้ได้จะส่งกลับ true
}


  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
