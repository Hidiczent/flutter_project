import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'logIN.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
                Image.asset('assets/images/Flag_of_Laos.svg', height: 80),
                const SizedBox(height: 24),

                const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                buildInputBox(
                  hint: 'email',
                  icon: Icons.person,
                  controller: _usernameController,
                ),
                const SizedBox(height: 16),

                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12),
                //   decoration: boxDecoration(),
                //   child: Row(
                //     children: [
                //       SvgPicture.asset(
                //         'assets/images/Flag_of_Laos.svg',
                //         width: 30,
                //       ),
                //       const SizedBox(width: 8),
                //       const Text('+856'),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: TextField(
                //           controller: _phoneController,
                //           keyboardType: TextInputType.phone,
                //           decoration: const InputDecoration(
                //             hintText: 'Phone number',
                //             border: InputBorder.none,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),buildInputBoxpassword
                const SizedBox(height: 16),

                buildInputBoxpassword(
                  hint: "password",
                  icon: Icons.lock,
                  controller: _passwordController,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final token = await loginUser(
                        _usernameController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      if (token != null) {
                        print("✅ Token: $token");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sign in failed')),
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
                      'Continue',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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

  BoxDecoration boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }

  Widget buildInputBox({
    required String hint,
    IconData? icon,
    TextEditingController? controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: boxDecoration(),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          icon: icon != null ? Icon(icon) : null,
        ),
      ),
    );
  }

  Widget buildInputBoxpassword({
  required String hint,
  IconData? icon,
  TextEditingController? controller,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: boxDecoration(),
    child: TextField(
      controller: controller,
      obscureText: true, // ✅ ซ่อนรหัสผ่าน
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        icon: icon != null ? Icon(icon) : null,
      ),
    ),
  );
}


  Future<String?> loginUser(String email, String password) async {
    final url = Uri.parse(
      'http://192.168.100.159:5000/login',
    ); // replace with your backend IP

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        print("❌ Sign in failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error: $e");
      return null;
    }
  }
}
