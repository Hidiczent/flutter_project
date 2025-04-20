import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/change_password_page.dart';
import 'package:flutter_project/Auth/pages/edit_username_page.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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

          // Profile image
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

          _infoTile('Name', 'tadamkhsvslv'),
          _infoTile(
            'Username',
            'eyeblack10',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditUsernamePage(),
                ),
              );
            },
          ),

          _infoTile('Bio', 'Add a bio'),
          _infoTile('Links', 'Add'),
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

          const Text(
            'Change display order',
            style: TextStyle(color: Colors.grey),
          ),
          const ListTile(
            title: Text('TikTok Studio'),
            trailing: Icon(Icons.drag_handle),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(color: Colors.black)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
