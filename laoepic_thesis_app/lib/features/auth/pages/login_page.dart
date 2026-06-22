
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/features/auth/pages/forgot_password_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:laoepic_thesis_app/providers/favorite_provider.dart';
import 'package:provider/provider.dart';

import 'package:laoepic_thesis_app/features/auth/pages/sign_up_page.dart';
import 'package:laoepic_thesis_app/features/auth/pages/intro_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/data/services/auth_api.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Sign-in screen supporting email/password and Google OAuth for Lao Epic travelers.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool get _isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool _isLoading = false;
  bool _googleLoading = false;

  Future<void> _persistSession(String token, Map<String, dynamic>? user) async {
    final decoded = _decodeToken(token);
    final userIdRaw = user?['userId'] ?? decoded['userId'] ?? decoded['user_id'];
    final userEmail = (user?['email'] ?? decoded['email'] ?? '') as String;
    final userName = (user?['fullName'] ?? decoded['fullName'] ?? '') as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_email', userEmail);
    await prefs.setString('user_name', userName);
    final userId = int.tryParse(userIdRaw?.toString() ?? '') ?? 0;
    await prefs.setInt('user_id', userId);

    final img = user?['profileImage']?.toString().trim();
    if (img != null && img.isNotEmpty) {
      await prefs.setString('user_photo_url', img);
    } else {
      await prefs.remove('user_photo_url');
    }
    final phone = user?['phone']?.toString().trim();
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString('user_phone', phone);
    } else {
      await prefs.remove('user_phone');
    }
  }

  Future<void> _loginWithGoogle() async {
    final i18n = context.read<UiI18n>();
    if (AppConfig.googleWebClientId.isEmpty) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authGoogleNotConfigured),
      );
      return;
    }

    if (_isIos && AppConfig.googleIosClientId.isEmpty) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authGoogleIosNotConfigured),
      );
      return;
    }

    setState(() => _googleLoading = true);
    try {
      final iosClientId = AppConfig.googleIosClientId;
      final googleSignIn = GoogleSignIn(
        clientId: _isIos && iosClientId.isNotEmpty ? iosClientId : null,
        serverClientId: AppConfig.googleWebClientId,
        scopes: const ['email'],
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        if (!mounted) return;
        await AppFeedback.showWarning(
          context,
          message: i18n.tr(I18nKey.authGoogleSignInCancelled),
        );
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        if (!mounted) return;
        await AppFeedback.showError(
          context,
          message: i18n.tr(I18nKey.authLoginFailedGeneric),
        );
        return;
      }

      final session = await AuthApi.loginWithGoogle(idToken);
      await _persistSession(session.token, session.user);

      if (!mounted) return;
      await context.read<FavoriteProvider>().mergeGuestWishlistAfterLogin();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroPage()),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final detail = (e.message ?? e.code).trim();
      await AppFeedback.showError(
        context,
        message: detail.isNotEmpty ? detail : i18n.tr(I18nKey.authLoginFailedGeneric),
      );
    } catch (e) {
      if (!mounted) return;
      final text = e.toString().replaceFirst('Exception: ', '').trim();
      await AppFeedback.showError(
        context,
        message: text.isNotEmpty ? text : i18n.tr(I18nKey.commonNetworkError),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      final i18n = context.read<UiI18n>();
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authEnterEmailPassword),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: {
          ...await buildPublicApiHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      late final Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        if (!mounted) return;
        final i18n = context.read<UiI18n>();
        await AppFeedback.showError(
          context,
          message: i18n.tr(
            I18nKey.authLoginFailedCode,
            params: {'code': '${response.statusCode}'},
          ),
        );
        return;
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token'] as String?;
        final user = data['user'] as Map<String, dynamic>?;
        if (token == null || token.isEmpty) {
          if (!mounted) return;
          final i18n = context.read<UiI18n>();
          await AppFeedback.showError(
            context,
            message: i18n.tr(I18nKey.authLoginFailedNoToken),
          );
          return;
        }

        await _persistSession(token, user);

        if (!mounted) return;
        await context.read<FavoriteProvider>().mergeGuestWishlistAfterLogin();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IntroPage()),
        );
      } else {
        if (!mounted) return;
        final i18n = context.read<UiI18n>();
        final parsed = AppFeedback.parseApiMessage(response.body);
        final msg =
            parsed.isNotEmpty
                ? parsed
                : (data['message']?.toString() ??
                    i18n.tr(I18nKey.authLoginFailedGeneric));
        await AppFeedback.showBusinessNotice(
          context,
          title: i18n.tr(I18nKey.authSignInNotCompleted),
          message: msg,
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      if (!mounted) return;
      final i18n = context.read<UiI18n>();
      await AppFeedback.showError(
        context,
        message: i18n.tr(I18nKey.commonNetworkError),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    return json.decode(payload);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ResponsiveScrollBody(
          centerWhenFits: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LaoEpicLogo(),
              SizedBox(height: ResponsiveLayout.gap(context)),
              Text(
                i18n.tr(I18nKey.authLoginTitle),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: ResponsiveLayout.gap(context)),

              // Email input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                  hintText: i18n.tr(I18nKey.authEmailHint),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.018)),

              // Password input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  ),
                  hintText: i18n.tr(I18nKey.authPasswordHint),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.01)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    i18n.tr(I18nKey.authForgotPassword),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.01)),
              Row(
                children: [
                  const Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(i18n.tr(I18nKey.commonOr)),
                  ),
                  const Expanded(child: Divider(thickness: 1)),
                ],
              ),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.018)),
              googleSignInButton(
                label: i18n.tr(I18nKey.authLoginWithGoogle),
                loading: _googleLoading,
                onPressed: _loginWithGoogle,
              ),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.03)),
              ElevatedButton(
                onPressed: _isLoading ? null : _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF084887),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        i18n.tr(I18nKey.commonContinue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
              ),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.012)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: Text(
                  i18n.tr(I18nKey.authCreateNewAccount),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.01)),
            ],
          ),
        ),
      ),
    );
  }

  Widget googleSignInButton({
    required String label,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/google.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
