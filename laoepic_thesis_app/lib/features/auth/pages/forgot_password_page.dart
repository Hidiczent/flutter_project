
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/auth/pages/reset_password_page.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';

/// Requests a password-reset OTP sent to the user's registered email.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> requestResetOtp() async {
    setState(() => _isLoading = true);
    final i18n = context.read<UiI18n>();

    final url = Uri.parse('${AppConfig.baseUrl}/users/reset-password/request');
    try {
      final response = await http.post(
        url,
        headers: {
          ...await buildPublicApiHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': _emailController.text.trim()}),
      );
      setState(() => _isLoading = false);

      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ResetPasswordPage(email: _emailController.text.trim()),
          ),
        );
      } else {
        if (!mounted) return;
        final trimmed = response.body.trim();
        final parsed = AppFeedback.parseApiMessage(response.body);
        final jsonBlob = trimmed.startsWith('{') && parsed == trimmed;
        final msg =
            !jsonBlob && parsed.isNotEmpty
                ? parsed
                : i18n.tr(
                  I18nKey.authFailedWithBody,
                  params: {'body': trimmed},
                );
        await AppFeedback.showError(context, message: msg);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Error: $e");
      if (!mounted) return;
      await AppFeedback.showError(
        context,
        message: i18n.tr(I18nKey.commonNetworkError),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF084887),
        title: Text(
          i18n.tr(I18nKey.authForgotPasswordTitle),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: ResponsiveScrollBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: i18n.tr(I18nKey.authEmailHint)),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
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
                    onPressed: requestResetOtp,
                    child: Text(
                      i18n.tr(I18nKey.authRequestOtpReset),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
