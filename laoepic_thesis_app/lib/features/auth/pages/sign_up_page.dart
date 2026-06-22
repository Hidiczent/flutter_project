
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/auth/pages/verify_otp_page.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';

/// Registration form that creates a new traveler account and sends an OTP for verification.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final i18n = context.read<UiI18n>();
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.trim().isEmpty) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authFillAllFields),
      );
      return;
    }

    if (password.length < 6) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authPasswordRules),
      );
      return;
    }

    setState(() => isLoading = true);
    final result = await _requestRegisterOtp(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
    if (!mounted) return;
    setState(() => isLoading = false);

    if (result.ok) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => VerifyOtpPage(
                email: email,
                action: 'register',
              ),
        ),
      );
    } else {
      final fallback = result.message ?? i18n.tr(I18nKey.authSignUpFailed);
      final msg = AppFeedback.parseApiMessage(fallback);
      await AppFeedback.showBusinessNotice(
        context,
        message: msg.isNotEmpty ? msg : i18n.tr(I18nKey.authSignUpFailed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ResponsiveScrollBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LaoEpicLogo(),
              SizedBox(height: ResponsiveLayout.gap(context, factor: 0.03)),
                Text(
                  i18n.tr(I18nKey.authSignUpTitle),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveLayout.gap(context, factor: 0.03)),
                buildInputBox(
                  i18n.tr(I18nKey.authSignUpName),
                  Icons.person,
                  _nameController,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                buildInputBox(
                  i18n.tr(I18nKey.authSignUpEmail),
                  Icons.email,
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
                const SizedBox(height: 16),
                buildInputBox(
                  i18n.tr(I18nKey.authPhoneHint),
                  Icons.phone,
                  _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                buildInputBoxPassword(
                  i18n.tr(I18nKey.authSignUpPassword),
                  Icons.lock,
                  _passwordController,
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF084887),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          i18n.tr(I18nKey.authCreateAccount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
              ],
          ),
        ),
      ),
    );
  }
  Widget buildInputBox(
    String hint,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool autocorrect = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: autocorrect,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          hintText: hint,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }
  Widget buildInputBoxPassword(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hint,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<({bool ok, String? message})> _requestRegisterOtp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/auth/register/request-otp');
    try {
      final body = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'password': password,
      };
      if (phone.isNotEmpty) {
        body['phone'] = phone;
      }

      final response = await http.post(
        url,
        headers: {
          ...await buildPublicApiHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      if (response.statusCode == 200 && data?['success'] == true) {
        return (ok: true, message: null);
      }

      final msg =
          data?['message']?.toString() ??
          (response.statusCode >= 400
              ? 'HTTP ${response.statusCode}'
              : null);
      return (ok: false, message: msg);
    } catch (_) {
      final i18n = context.read<UiI18n>();
      return (ok: false, message: i18n.tr(I18nKey.commonNetworkError));
    }
  }
}
