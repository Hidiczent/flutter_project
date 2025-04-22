import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/Display_message.dart';
import 'package:flutter_project/Auth/pages/account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    checkToken(); // ✅ เรียกเมื่อตอนเข้า
  }

  void checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      print("🔐 Token: $token");
      // ✅ คุณสามารถ decode JWT หรือ fetch ข้อมูลผู้ใช้ที่นี่ได้
    } else {
      print("❌ No token found");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
          decoration: const BoxDecoration(color: Color(0xFF084886)),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Search', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Notification Icon with red dot
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications,
                          color: Colors.amber,
                          size: 30,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Yellow bubble with 'M'
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Displaymenu(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.solidCommentDots,
                      color: Colors.amber,
                      size: 25,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          sectionTitle('Popular Province'),
          imageCard('Vientiane', 'assets/images/Default.jpg'),
          sectionTitle('Popular Activities'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                activityCard(
                  "Collecting coffee and how to make .....",
                  "assets/images/activity.jpg",
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/activity.jpg",
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/activity.jpg",
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/activity.jpg",
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                activityCard(
                  "Collecting coffee and how to make .....",
                  "assets/images/Homeste.jpg",
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/Act4.JPG",
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/Act3.jpg",
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/activity.jpg",
                ),
              ],
            ),
          ),

          sectionTitle('Popular Place in Laos'),
          Row(
            children: [
              Expanded(
                child: imageCard(
                  'Kuangsi Waterfall',
                  'assets/images/Default.jpg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: imageCard(
                  'That Luang Stupa',
                  'assets/images/Default.jpg',
                ),
              ),
            ],
          ),

          sectionTitle('Other actions'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ActionItem(icon: Icons.directions_bus, label: 'Travel'),
              ActionItem(icon: Icons.house, label: 'Plan'),
              ActionItem(icon: Icons.park, label: 'Event &'),
              ActionItem(icon: Icons.bookmark, label: 'Booking'),
              ActionItem(icon: Icons.collections, label: 'Collection'),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: imageCard(
                  'Phou Khao Khouay',
                  'assets/images/activity.jpg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: imageCard(
                  'Wat Xieng Thong',
                  'assets/images/activity.jpg',
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // ✅ ทำให้แสดงครบ 5 ไอคอน
        selectedItemColor: Color(0xFF084886), // ✅ ถูกต้อง

        unselectedItemColor: Colors.grey,
        currentIndex: 0, // หรือสร้างตัวแปรใน StatefulWidget เพื่อเปลี่ยนหน้า
        onTap: (index) {
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountPage()),
            );
          }
          // ใส่ logic ถ้าคุณต้องการเปลี่ยนหน้า
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.card_travel), label: 'Trip'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('See All', style: TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }

  Widget imageCard(String title, String imagePath) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget activityCard(String title, String imagePath) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "South Pakxong district  Pakse province",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: List.generate(5, (index) {
                    return const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 6),
                const Text(
                  "500.000 KIP",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget locationIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.teal),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget actionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.teal[50],
          child: Icon(icon, color: Colors.teal),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1DF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFE98A15), size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE37E00),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
