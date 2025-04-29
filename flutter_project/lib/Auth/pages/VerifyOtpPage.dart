import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/reset_passwor.dart';
import 'package:flutter_project/config.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  final String action;

  const VerifyOtpPage({super.key, required this.email, required this.action});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❗ Please enter OTP")));
      return;
    }

    String apiEndpoint = '';
    Map<String, dynamic> body = {
      'email': widget.email,
      'otp': otp,
      'action': widget.action,
    };

    // ✅ จัดการ endpoint ตาม action
    if (widget.action == 'register') {
      apiEndpoint = '${AppConfig.baseUrl}/otp/confirm-register';
    } else {
      apiEndpoint = '${AppConfig.baseUrl}/otp/verify';
    }

    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");
      if (response.statusCode == 200) {
        handleSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Invalid or expired OTP")),
        );
      }
    } catch (e) {
      print("❌ Error verifying OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to connect to server")),
      );
    }
  }

  void handleSuccess() {
    if (widget.action == 'register' || widget.action == 'verify_email') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Email verified, please login')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } else if (widget.action == 'reset_password') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: widget.email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF084886),
        centerTitle: true,
        title: const Text('Verify OTP', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF084886),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                onPressed: verifyOtp,
                child: const Text(
                  'Verify OTP',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
