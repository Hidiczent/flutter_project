import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/Display_message.dart';
import 'package:flutter_project/Auth/pages/Account_page.dart';
import 'package:flutter_project/config.dart';
import 'package:flutter_project/models/package_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/Auth/pages/Historybook.dart';
import 'notification_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_project/Auth/pages/Detail_booking_packet_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PackageModel> packageList = [];
  String searchQuery = '';
  List<PackageModel> filteredPackages = [];
  int unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    checkToken();
    fetchPackages(); // ✅ เพิ่ม
    fetchUnreadNotificationsCount(); // ✅ เพิ่ม

    // ✅ เรียกเมื่อตอนเข้า
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

  Future<void> fetchPackages() async {
    final url = Uri.parse('${AppConfig.baseUrl}/packages/packages');
    try {
      final response = await http.get(url);
      // print('📦 Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          data = decoded['data'];
        } else {
          throw Exception("Unexpected response format: ${decoded.runtimeType}");
        }

        final List<PackageModel> loaded =
            data.map((item) => PackageModel.fromJson(item)).toList();

        setState(() {
          packageList = loaded;
          filteredPackages = List.from(packageList);
        });
      } else {
        print('❌ Failed to load packages: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  Future<void> fetchUnreadNotificationsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print('❌ No token found');
      return;
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/notification/user/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        unreadNotificationsCount =
            data
                .where(
                  (notification) =>
                      notification['status_notification'] == 'new',
                )
                .length;
      });
    } else {
      print("❌ Failed to fetch notifications. Status: ${response.statusCode}");
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print('❌ No token found');
      return;
    }

    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/notification/update/$notificationId'),
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'status_notification': 'read', // เปลี่ยนสถานะเป็น "read"
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Notification marked as read');
      // ถ้าต้องการสามารถเรียกข้อมูลการแจ้งเตือนใหม่เพื่อนำไปแสดงผล
    } else {
      print(
        "❌ Failed to update notification status. Status: ${response.statusCode}",
      );
    }
  }

  @override
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
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        // ✅ ครอบ TextField ด้วย Expanded
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              searchQuery = val.toLowerCase();
                              filteredPackages =
                                  packageList
                                      .where(
                                        (pkg) => pkg.title
                                            .toLowerCase()
                                            .contains(searchQuery),
                                      )
                                      .toList();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search package...',
                            border: InputBorder.none,
                            isDense: true, // ✅ ช่วยให้ช่องเล็กลง
                          ),
                        ),
                      ),
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
                        if (unreadNotificationsCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$unreadNotificationsCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
              children:
                  filteredPackages.map((pkg) {
                    return activityCardFromApi(pkg, context);
                  }).toList(),
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
                  context,
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/Act4.jpg",
                  context,
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/Act3.jpg",
                  context,
                ),
                activityCard(
                  "Collecting coffee and how to make......",
                  "assets/images/activity.jpg",
                  context,
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
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookingHistoryPage(),
              ),
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

  //  click link to detail page
  Widget activityCard(String title, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => DetailBookingPacketPage(packageId: pkg.id),
        //   ),
        // );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
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

Widget activityCardFromApi(PackageModel pkg, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailBookingPacketPage(packageId: pkg.id),
        ),
      );
    },
    child: Container(
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
            child: Image.network(
              pkg.mainImageUrl,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Image.asset(
                    'assets/images/default.jpg',
                    fit: BoxFit.cover,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.title,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  pkg.about,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  "${pkg.priceInUsd} USD",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
