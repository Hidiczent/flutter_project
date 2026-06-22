import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/app/main_shell_page.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/features/auth/pages/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Routes to [MainShellPage] or [LoginPage] after validating the stored JWT.
class AuthCheckPage extends StatelessWidget {
  const AuthCheckPage({super.key});

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) return false;

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/auth/me'),
      headers: await buildAuthApiHeaders(token),
    );
    if (response.statusCode != 200) return false;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['success'] == true && data['data'] != null;
    } catch (_) {
      return false;
    }
  }

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
        if (snapshot.data == true) {
          return const MainShellPage();
        }
        return const LoginPage();
      },
    );
  }
}
