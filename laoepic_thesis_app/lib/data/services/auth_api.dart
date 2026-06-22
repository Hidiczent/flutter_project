
import 'dart:convert';

import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:http/http.dart' as http;

/// JWT token and decoded user payload returned after a successful sign-in.
class AuthSession {
  final String token;
  final Map<String, dynamic>? user;

  const AuthSession({required this.token, this.user});
}

/// HTTP client for authentication endpoints such as Google OAuth login.
class AuthApi {
  /// Login with google for this module.
  static Future<AuthSession> loginWithGoogle(String idToken) async {
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/google'),
      headers: {
        ...await buildPublicApiHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'idToken': idToken}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message']?.toString() ?? 'Google sign-in failed');
    }
    final token = body['token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('No token returned');
    }
    return AuthSession(
      token: token,
      user: body['user'] as Map<String, dynamic>?,
    );
  }
}
