import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/account_page.dart';
import 'package:flutter_project/Auth/pages/change_password_page.dart';
import 'package:flutter_project/Auth/pages/edit_email.dart';
import 'package:flutter_project/Auth/pages/edit_username_page.dart';
import 'package:flutter_project/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String userId = '';
  String firstName = '';
  String phone = '';

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    final name = prefs.getString('user_name') ?? '';
    final userIdFromToken = _extractUserIdFromToken(token);

    setState(() {
      userId = userIdFromToken ?? '';
      firstName = name;
      _firstNameController.text = name;
      _phoneController.text = '';
    });
  }

  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload);
      return data['user_id']?.toString();
    } catch (e) {
      // print('❌ Token decode failed: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (userId.isEmpty) return;

    setState(() => _isSaving = true);

    final url = Uri.parse('${AppConfig.baseUrl}/users/$userId/profile');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': _firstNameController.text,
        'lastname': '',
        'phone_number': int.tryParse(_phoneController.text),
        'photo': null,
      }),
    );

    setState(() => _isSaving = false);
    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Profile updated')));

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AccountPage()),
      );
    } else {
      // print("❌ Response: ${response.body}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
    }
  }

  // ส่วนนี้คือ UI เดิมของคุณ ไม่เปลี่ยนแปลง
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF084886),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SizedBox(height: 12),

          // Profile imag
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/person1.jpg'),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('Change photo')),

          const SizedBox(height: 24),
          const Text('About you', style: TextStyle(color: Colors.grey)),

          // Name field (editable)
          _infoTile(
            'Edit Profile ',
            'Tap to update Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditUsernamePage(),
                ),
              );
            },
          ),

          // Username field (ไม่แก้ไข)
          _infoTile(
            'Email',
            'Tap to update Email',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditEmail()),
              );
            },
          ),

          _infoTile(
            'Change Password',
            'Tap to update password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
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
    );
  }

  Widget _infoTile(String title, String value, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.all(5),
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(color: Colors.black)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
