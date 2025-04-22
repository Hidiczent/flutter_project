import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config.dart'; // import baseUrl

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
    final oldPass = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final url = Uri.parse('${AppConfig.baseUrl}/users/$userId/password');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'old_password': oldPass, 'new_password': newPass}),
    );

    setState(() => _isSaving = false);

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Password updated successfully')),
      );
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Old password is incorrect')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to update password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF084886),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            'Your password must be at least 6 characters and include a number, a letter, and a special character (!\$@%)',
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 20),

          _passwordField('Current Password', _currentPasswordController),
          _passwordField('New Password', _newPasswordController),
          _passwordField('Confirm New Password', _confirmPasswordController),

          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot your password?',
              style: TextStyle(color: Colors.blue),
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
            title: const Text(
              'Log out from other devices. Choose this if someone else is using your account.',
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF084886),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child:
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'Change Password',
                      style: TextStyle(
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
