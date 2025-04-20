import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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

          // Current password
          _passwordField('Current Password', _currentPasswordController),

          // New password
          _passwordField('New Password', _newPasswordController),

          // Confirm password
          _passwordField('Confirm New Password', _confirmPasswordController),

          const SizedBox(height: 12),

          // Forgot password
          TextButton(
            onPressed: () {
              // handle forgot password
            },
            child: const Text(
              'Forgot your password?',
              style: TextStyle(color: Colors.blue),
            ),
          ),

          const SizedBox(height: 12),

          // Checkbox: Logout from other devices
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

          // Button
          ElevatedButton(
            onPressed: () {
              // Handle password change
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF084886),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: const Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
