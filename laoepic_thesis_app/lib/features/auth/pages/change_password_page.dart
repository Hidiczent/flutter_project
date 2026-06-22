
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/auth/pages/forgot_password_page.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';

/// Form screen where signed-in users update their password after verifying the current one.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _logoutOtherDevices = true;
  bool _isSaving = false;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final parts = token.split('.');
    if (parts.length == 3) {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = json.decode(payload);
      setState(() {
        userId = data['user_id'].toString();
      });
    }
  }

  Future<void> _changePassword() async {
    final i18n = context.read<UiI18n>();
    final oldPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (userId.isEmpty) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authUserIdNotLoaded),
      );
      return;
    }

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authFillAllFields),
      );
      return;
    }

    if (newPass != confirmPass) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.authPasswordsNoMatch),
      );
      return;
    }

    setState(() => _isSaving = true);

    final url = Uri.parse('${AppConfig.baseUrl}/users/$userId/password');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        url,
        headers: {
          ...await buildAuthApiHeaders(token),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'old_password': oldPass,
          'new_password': newPass,
          'confirm_password': confirmPass,
        }),
      );
      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (!mounted) return;
      if (response.statusCode == 200) {
        await AppFeedback.showSuccess(
          context,
          message: i18n.tr(I18nKey.authPasswordUpdated),
        );
        if (!mounted) return;
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        await AppFeedback.showError(
          context,
          message: i18n.tr(I18nKey.authOldPasswordWrong),
        );
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
      print("❌ Error: $e");
      if (!mounted) return;
      await AppFeedback.showError(
        context,
        message: i18n.tr(I18nKey.commonNetworkError),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF084887),
        elevation: 0,
        centerTitle: true,
        title: Text(
          i18n.tr(I18nKey.authChangePasswordTitle),
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            i18n.tr(I18nKey.authPasswordRules),
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 20),
          _passwordField(i18n.tr(I18nKey.authCurrentPassword), _currentPasswordController),
          _passwordField(i18n.tr(I18nKey.authNewPasswordLabel), _newPasswordController),
          _passwordField(i18n.tr(I18nKey.authConfirmNewPassword), _confirmPasswordController),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage(),
                ),
              );
            },
            child: Text(
              i18n.tr(I18nKey.authForgotYourPassword),
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _logoutOtherDevices,
            onChanged: (val) {
              setState(() {
                _logoutOtherDevices = val ?? true;
              });
            },
            title: Text(i18n.tr(I18nKey.authLogoutOtherDevices)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF084887),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child:
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      i18n.tr(I18nKey.authSave),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
