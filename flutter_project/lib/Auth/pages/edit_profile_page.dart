import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/Change_password_page.dart';
import 'package:flutter_project/Auth/pages/Edit_email.dart';
import 'package:flutter_project/Auth/pages/edit_username_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  late String token;
  late int userId;
  late String photoUrl = '';
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('❌ Upload Failed'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id') ?? 0;
    token = prefs.getString('jwt_token') ?? '';
    photoUrl = prefs.getString('user_photo_url') ?? '';
    setState(() {});
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    setState(() {
      _imageBytes = bytes; // ✅ เก็บ bytes โดยตรง
    });

    print('✅ Selected image');
  }

  Future<void> uploadImage() async {
    if (_imageBytes == null || userId == 0) {
      print('⚠️ No image selected or userId/token missing.');
      return;
    }

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${AppConfig.baseUrl}/users/profile-photo'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        _imageBytes!,
        filename: 'profile_photo.jpg',
      ),
    );

    try {
      var response = await request.send();
      final resBody = await response.stream.bytesToString();
      print('📦 Server Response Body: $resBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_url', data['path'] ?? '');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile photo updated successfully')),
        );

        setState(() {
          photoUrl = data['path'] ?? '';
          _imageBytes = null;
        });
      } else {
        // 🔥 ตรงนี้คือรับ error message จาก server แล้วแจ้งผ่าน dialog
        showErrorDialog('❌ Upload failed:\n$resBody');
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      showErrorDialog('❌ Upload failed: $e');
    }
  }

  Widget _infoTile(String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.all(5),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF084886),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _imageBytes != null
                          ? MemoryImage(_imageBytes!) // ✅ แสดงภาพจาก bytes
                          : (photoUrl.isNotEmpty
                              ? NetworkImage('${AppConfig.baseUrl}/$photoUrl')
                              : const AssetImage('assets/images/person1.jpg')
                                  as ImageProvider),
                ),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton(
              onPressed: uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF084886),
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Profile Photo',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          _infoTile(
            'Username',
            'Tap to update Username',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditUsernamePage(),
                  ),
                ),
          ),
          _infoTile(
            'Email',
            'Tap to update Email',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditEmail()),
                ),
          ),
          _infoTile(
            'Change Password',
            'Tap to update password',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
