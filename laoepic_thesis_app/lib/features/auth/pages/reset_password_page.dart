
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:laoepic_thesis_app/shared/utils/responsive_layout.dart';

/// Sets a new password after the user verifies their reset OTP.
class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Future<void> resetPassword() async {
    final i18n = context.read<UiI18n>();
    final url = Uri.parse('${AppConfig.baseUrl}/users/reset-password/confirm');
    try {
      final response = await http.post(
        url,
        headers: {
          ...await buildPublicApiHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "email": widget.email,
          "otp": _otpController.text.trim(),
          "new_password": _newPasswordController.text.trim(),
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        await AppFeedback.showSuccess(
          context,
          message: i18n.tr(I18nKey.authResetSuccess),
        );
        if (!mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
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
      print("❌ Error resetting password: $e");
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
        backgroundColor: Color(0xFF084887),
        title: Text(
          i18n.tr(I18nKey.authResetPasswordTitle),
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
                prefixIcon: const Icon(Icons.lock_clock_outlined),
                labelText: i18n.tr(I18nKey.authOtpCodeHint),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: i18n.tr(I18nKey.authNewPassword),
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
                onPressed: resetPassword,
                child: Text(
                  i18n.tr(I18nKey.authResetPasswordButton),
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
