
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';

/// Collects a new username and submits it to the backend profile API.
class EditUsernamePage extends StatefulWidget {
  const EditUsernamePage({super.key});

  @override
  State<EditUsernamePage> createState() => _EditUsernamePageState();
}

class _EditUsernamePageState extends State<EditUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isSaving = false;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final payload = _decodeToken(token);
    userId = payload['user_id'].toString();

    _usernameController.text = prefs.getString('user_name') ?? '';
    _lastnameController.text = '';
    _phoneController.text = '';
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    return json.decode(payload);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final i18n = context.read<UiI18n>();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final url = Uri.parse('${AppConfig.baseUrl}/users/profile');
    final phone = int.tryParse(_phoneController.text);

    final response = await http.put(
      url,
      headers: {
        ...await buildAuthApiHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'first_name': _usernameController.text,
        'lastname': _lastnameController.text,
        'phone_number': phone,
        'photo': null,
      }),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (response.statusCode == 200) {
      await prefs.setString('user_name', _usernameController.text);
      await prefs.setString('user_lastname', _lastnameController.text);
      if (phone != null) {
        await prefs.setString('user_phone', phone.toString());
      }

      await AppFeedback.showSuccess(
        context,
        message: i18n.tr(I18nKey.authProfileUpdated),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      final parsed = AppFeedback.parseApiMessage(response.body);
      await AppFeedback.showError(
        context,
        message:
            parsed.isNotEmpty
                ? parsed
                : i18n.tr(I18nKey.authProfileUpdateFailed),
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
        title: Center(
          child: Text(
            i18n.tr(I18nKey.authEditUsernameTitle),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: i18n.tr(I18nKey.authFirstNameHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastnameController,
              decoration: InputDecoration(
                hintText: i18n.tr(I18nKey.authLastNameHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: i18n.tr(I18nKey.authPhoneHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              i18n.tr(I18nKey.authUsernameRules),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF084887),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        i18n.tr(I18nKey.authSave),
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
