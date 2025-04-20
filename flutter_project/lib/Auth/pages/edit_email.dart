import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config.dart';

class EditEmail extends StatefulWidget {
  const EditEmail({super.key});

  @override
  State<EditEmail> createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmail> {
  final TextEditingController _emailcontroller = TextEditingController();

  String userId = '';
  bool _isSaving = false;

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
    _emailcontroller.text = prefs.getString('user_email') ?? '';
    ;
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

    final url = Uri.parse('${AppConfig.baseUrl}/users/$userId/email');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': _emailcontroller.text}),
    );

    setState(() => _isSaving = false);

    if (response.statusCode == 200) {
      Navigator.pop(context); // ✅ กลับหน้าเดิม
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Email updated')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update email')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF084886),
        title: const Center(
          child: Text("Edit Your Email", style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _emailcontroller,
              decoration: InputDecoration(
                hintText: 'Enter your Email',
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
                backgroundColor: Color(0xFF084886), // ✅ เปลี่ยนสีปุ่ม
                minimumSize: const Size.fromHeight(50), // ✅ เพิ่มความสูงปุ่ม
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // ✅ ขอบโค้ง
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
