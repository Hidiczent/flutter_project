import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/Auth/pages/edit_profile_page.dart';
import 'package:flutter_project/Auth/pages/Login.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String userName = 'No Name';
  String userEmail = 'No Email';

  @override
  void initState() {
    super.initState();
    loadUserData(); // ✅ Load user data
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'No Name';
      userEmail = prefs.getString('user_email') ?? 'No Email';
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ Clear token and user data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/ProfileBG.gif',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 110, left: 20),
                child: Positioned(
                  bottom: 0,
                  left: 16,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(
                          'assets/images/Profile.jpg',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.email_outlined, size: 20),
                              SizedBox(width: 5),
                              Text(
                                '$userEmail',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('Manage Your Account'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    },
                  ),
                  sectionItem(Icons.article_outlined, 'Your Post In Feed'),
                  sectionItem(Icons.reviews, 'Review'),
                  const SizedBox(height: 24),
                  const Text(
                    'Help',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  sectionItem(Icons.help_outline, 'Contract Service Customer'),
                  sectionItem(
                    Icons.volunteer_activism_outlined,
                    'Question To Accommodation',
                  ),
                  sectionItem(
                    Icons.shield_outlined,
                    'Safety Information Center',
                  ),
                  sectionItem(Icons.chat_outlined, 'Feedback'),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: logout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      onTap: () {
        // Optional: add action
      },
    );
  }
}
