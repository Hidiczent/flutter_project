import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config.dart';

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

    // ดึงจาก local (หรือเพิ่มให้เรียก API มา preload ก็ได้)
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

    final url = Uri.parse('${AppConfig.baseUrl}/users/$userId/profile');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': _usernameController.text,
        'lastname': _lastnameController.text,
        'phone_number': int.tryParse(_phoneController.text),
        'photo': null,
      }),
    );

    setState(() => _isSaving = false);

    if (response.statusCode == 200) {
      Navigator.pop(context); 
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Profile updated')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF084886),
        title: const Center(
          child: Text(
            "Edit Your Profile",
            style: TextStyle(color: Colors.white),
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
                hintText: 'Enter your username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastnameController,
              decoration: InputDecoration(
                hintText: 'Enter your lastname',
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
                hintText: 'Enter your Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Usernames can contain only letters, numbers, underscores, and periods.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF084886), 
                minimumSize: const Size.fromHeight(50), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), 
                ),
              ),
              child:
                  _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ), // ✅ เพิ่มขนาดตัวอักษร
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
