
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/auth/pages/login_page.dart';
import 'package:laoepic_thesis_app/features/auth/pages/reset_password_page.dart';
import 'package:laoepic_thesis_app/features/auth/pages/intro_page.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:laoepic_thesis_app/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';

/// OTP entry screen used during sign-up, email change, or password reset flows.
class VerifyOtpPage extends StatefulWidget {
  final String email;
  final String action;

  const VerifyOtpPage({super.key, required this.email, required this.action});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final i18n = context.read<UiI18n>();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authEnterOtp),
      );
      return;
    }

    final String apiEndpoint;
    final Map<String, dynamic> body;

    if (widget.action == 'register') {
      apiEndpoint = '${AppConfig.baseUrl}/auth/register/verify-otp';
      body = {'email': widget.email, 'otp': otp};
    } else {
      apiEndpoint = '${AppConfig.baseUrl}/otp/verify';
      body = {
        'email': widget.email,
        'otp': otp,
        'action': widget.action,
      };
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
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

      final ok =
          (response.statusCode == 200 || response.statusCode == 201) &&
          data?['success'] == true;

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (ok) {
        if (widget.action == 'register') {
          await _persistSessionFromAuthResponse(data!);
        }
        await handleSuccess();
      } else {
        final parsed = AppFeedback.parseApiMessage(response.body);
        final msg =
            parsed.isNotEmpty
                ? parsed
                : (data?['message']?.toString() ??
                    i18n.tr(I18nKey.authInvalidOtp));
        await AppFeedback.showBusinessNotice(context, message: msg);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await AppFeedback.showError(
        context,
        message: i18n.tr(I18nKey.authServerConnectFailed),
      );
    }
  }

  Future<void> resendOtp() async {
    if (widget.action != 'register') return;

    final i18n = context.read<UiI18n>();
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register/resend-otp'),
        headers: {
          ...await buildPublicApiHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': widget.email}),
      );

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200 && data?['success'] == true) {
        await AppFeedback.showSuccess(
          context,
          message: i18n.tr(I18nKey.authOtpResent),
        );
      } else {
        final parsed = AppFeedback.parseApiMessage(response.body);
        final msg =
            parsed.isNotEmpty
                ? parsed
                : (data?['message']?.toString() ??
                    i18n.tr(I18nKey.authSignUpFailed));
        await AppFeedback.showBusinessNotice(context, message: msg);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await AppFeedback.showError(
        context,
        message: i18n.tr(I18nKey.commonNetworkError),
      );
    }
  }

  Future<void> _persistSessionFromAuthResponse(
    Map<String, dynamic> data,
  ) async {
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) return;

    final user = data['user'] as Map<String, dynamic>?;
    final decoded = _decodeToken(token);
    final userIdRaw = user?['userId'] ?? decoded['userId'] ?? decoded['user_id'];
    final userEmail = (user?['email'] ?? decoded['email'] ?? widget.email) as String;
    final userName = (user?['fullName'] ?? decoded['fullName'] ?? '') as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_email', userEmail);
    await prefs.setString('user_name', userName);
    final userId = int.tryParse(userIdRaw?.toString() ?? '') ?? 0;
    await prefs.setInt('user_id', userId);

    final phone = user?['phone']?.toString().trim();
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString('user_phone', phone);
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> handleSuccess() async {
    final i18n = context.read<UiI18n>();
    if (widget.action == 'register' || widget.action == 'verify_email') {
      await AppFeedback.showSuccess(
        context,
        message: i18n.tr(I18nKey.authEmailVerifiedLogin),
      );
      if (!mounted) return;
      if (widget.action == 'register') {
        await context.read<FavoriteProvider>().mergeGuestWishlistAfterLogin();
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  widget.action == 'register'
                      ? const IntroPage()
                      : const LoginPage(),
        ),
      );
    } else if (widget.action == 'reset_password') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: widget.email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF084887),
        centerTitle: true,
        title: Text(
          i18n.tr(I18nKey.authVerifyOtpTitle),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: ResponsiveScrollBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: i18n.tr(I18nKey.authOtpCodeHint),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF084887),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                onPressed: _isLoading ? null : verifyOtp,
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          i18n.tr(I18nKey.authVerifyOtpButton),
                          style: const TextStyle(color: Colors.white),
                        ),
              ),
            ),
            if (widget.action == 'register') ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : resendOtp,
                child: Text(i18n.tr(I18nKey.authResendOtp)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
