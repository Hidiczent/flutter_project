import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/home.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ พื้นหลังสีขาว
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/lao_epic_logo.png', // ✅ ใส่โลโก้ของคุณที่นี่
                  height: 100,
                ),
              ),
              const SizedBox(height: 48),

              // Text
              const Text(
                'Plan your',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              const Text(
                'Epic Vacation',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 48),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                    // TODO: navigate to SignInPage or LoginPage
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF084886),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
