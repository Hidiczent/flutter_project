import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'notification_page.dart';
import 'detail_booking_about_page.dart';
import 'home.dart';

class DetailBookingPacketPage extends StatefulWidget {
  const DetailBookingPacketPage({super.key});

  @override
  State<DetailBookingPacketPage> createState() =>
      _DetailBookingPacketPageState();
}

class _DetailBookingPacketPageState extends State<DetailBookingPacketPage> {
  bool isFavorited = false;
  @override
  void initState() {
    super.initState();
    checkToken();
    loadFavoriteStatus();
  }

  void loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorited = prefs.getBool('isFavorited') ?? false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      backgroundColor: Colors.grey[100],
      body: ListView(
        children: [
          // Banner Image
          Stack(
            children: [
              Image.asset(
                'assets/images/activity.jpg',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Icon(Icons.arrow_back, color: Colors.white),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        }, // 👈 ย้อนกลับไปหน้าก่อน
                        // child: const CircleAvatar(
                        //   child: Icon(Icons.arrow_back, color: Colors.black),
                        // ),
                      ),

                      // ✅ Favorite toggle + share + profile
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              setState(() {
                                isFavorited = !isFavorited;
                              });

                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('isFavorited', isFavorited);
                            },
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.share, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tab bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailBookingAboutPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "About",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const Text(
                  "Packet",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const Text(
                  " Activity",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Visit to Vangvieng Activity",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Text("Review 4.0 "),
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    Text(" (300)"),
                  ],
                ),
              ],
            ),
          ),

          // Service buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                ServiceIcon(label: "Travel", icon: Icons.directions_bus),
                ServiceIcon(label: "Hotel", icon: Icons.hotel),
                ServiceIcon(label: "Activity", icon: Icons.event),
                ServiceIcon(label: "Guide", icon: Icons.map),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Packet Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select packet", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("1 Day tour vang vieng\n₭ 1.399.000 KIP"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Collection"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Book now"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Inclusion list
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Colors.blueGrey[50],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  InclusionItem("English-speaking guide", true),
                  InclusionItem("Lunch", true),
                  InclusionItem("Round-trip transfers", true),
                  InclusionItem("Insurance provided", true),
                  InclusionItem("Boat ride", false),
                ],
              ),
            ),
          ),

          // Review section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Review", style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text("4.2", style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Icon(Icons.star, color: Colors.orange),
                    Icon(Icons.star, color: Colors.orange),
                    Icon(Icons.star, color: Colors.orange),
                    Icon(Icons.star, color: Colors.orange),
                    Icon(Icons.star_half, color: Colors.orange),
                  ],
                ),
                SizedBox(height: 12),
                ReviewItem(),
                ReviewItem(),
                ReviewItem(),
              ],
            ),
          ),

          sectionTitle('Other actions'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: ActionItem(icon: Icons.directions_bus, label: 'Travel'),
              ),
              Expanded(child: ActionItem(icon: Icons.house, label: 'Plan')),
              Expanded(child: ActionItem(icon: Icons.park, label: 'Event &')),
              Expanded(
                child: ActionItem(icon: Icons.bookmark, label: 'Booking'),
              ),
              Expanded(
                child: ActionItem(icon: Icons.collections, label: 'Collection'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
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
}

Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 22,
      horizontal: 16,
    ), // ✅ เพิ่ม padding ด้านข้าง
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis, // ✅ ป้องกันล้น
          ),
        ),
        const SizedBox(width: 8),
        const Text('See All', style: TextStyle(color: Colors.orange)),
      ],
    ),
  );
}

//imageCard
Widget imageCard(String title, String imagePath) {
  return AspectRatio(
    aspectRatio: 4 / 3, // ✅ ปรับสัดส่วนภาพ (4:3 เหมาะกับภาพแนวนอน)
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปภาพ
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          // หัวข้อด้านล่าง
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
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

//class ActionItem
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

// COMPONENTS

class ServiceIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const ServiceIcon({required this.label, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
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

class InclusionItem extends StatelessWidget {
  final String text;
  final bool included;

  const InclusionItem(this.text, this.included, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          included ? Icons.check_circle : Icons.cancel,
          color: included ? Colors.teal : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

/// Review
class ReviewItem extends StatelessWidget {
  const ReviewItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/pic1.jpg'),
                ),
                SizedBox(width: 8),
                Text("User", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 16),
                Icon(Icons.star, color: Colors.orange, size: 16),
                Icon(Icons.star, color: Colors.orange, size: 16),
                Icon(Icons.star, color: Colors.orange, size: 16),
                Icon(Icons.star, color: Colors.orange, size: 16),
              ],
            ),
            SizedBox(height: 4),
            Text("Nice one!!"),
          ],
        ),
      ),
    );
  }
}
