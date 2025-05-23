import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/VerifyOtpPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  // bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/lao_epic_logo.png', height: 180),
                const SizedBox(height: 30),
                const Text(
                  'Sign up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                buildInputBox("Name", Icons.person, _nameController),
                const SizedBox(height: 16),
                buildInputBox("Email", Icons.email, _emailController),
                const SizedBox(height: 16),
                buildInputBoxPassword(
                  "Password",
                  Icons.lock,
                  _passwordController,
                ),
                const SizedBox(height: 24),

                isLoading
                    ? const CircularProgressIndicator() // ✅ แสดงโหลด
                    : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() => isLoading = true);
                          final success = await registerUser(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          setState(() => isLoading = false);

                          if (success) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VerifyOtpPage(
                                      email: _emailController.text.trim(),
                                      action: 'register',
                                    ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("❌ Sign up failed")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF084886),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildInputBox(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildInputBoxPassword(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<bool> registerUser(String name, String email, String password) async {
    final url = Uri.parse('${AppConfig.baseUrl}/users/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'action': 'register',
          'metadata': {
            'first_name': name,
            'lastname': 'Default', // ✅ ต้องใส่ (แม้จะ dummy)
            'phone_number': '0000000000', // ✅ ต้องใส่
            'password': password,
            'role': 'user', // ✅ default เป็น user
          },
        }),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error sending OTP: $e");
      return false;
    }
  }
}
