import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/account_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'notification_page.dart';
import 'detail_booking_packet_page.dart';
import 'home.dart';

class DetailBookingAboutPage extends StatefulWidget {
  const DetailBookingAboutPage({super.key});

  @override
  State<DetailBookingAboutPage> createState() => _DetailBookingAboutPageState();
}

class _DetailBookingAboutPageState extends State<DetailBookingAboutPage> {
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
                const Text(
                  "About",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailBookingPacketPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Packet",
                    style: TextStyle(fontWeight: FontWeight.w500),
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
          Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(
              maxWidth: 600,
            ), // 🔹 Limit width if needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Visit to Vangvieng Activity ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Experience a fun and challenging trip that no one can beat this time, along with a tour of Laos' historical caves that are unknown to many and vast lakes, as well as living with local people who are ready to share new vocabulary with all of us Beyond the borders of Tokyo, there is an abundance of enchanting scenes to enjoy and cultural treasures to discover. One of this tour's highlights is found in the coastal town of Kawazu, known across Japan for the Kawazu-zakura – mainland Japan's earliest blooming cherry trees. Every year, the town holds the Kawazu Cherry Blossom Festival to celebrate the arrival of the bright pink blooms, with annual activities and cherry-flavored festival food. While in the area, we'll stop by Nanadaru Falls – the seven poetic waterfalls of the Izu Peninsula Geopark. We will venture into the breathtaking region around Mount Fuji for a ride on the Kachi Ropeway and enchanting views of the mountains and valleys below, then go to admire the colorful silk-dyeing techniques of Itchiku Kubota at a museum near Lake Kawaguchi.",
                  style: TextStyle(color: Colors.grey),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                Text("Read More", style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),

          // line
          const Divider(
            color: Colors.grey, // You can customize the color
            thickness: 1, // Line thickness
            indent: 20, // Start padding
            endIndent: 20, // End padding
          ),
          // Tour information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: const [
                SectionTitle("About Trip"),
                BulletText("Limit : 5 people"),
                BulletText("Start trip 1: 15 July - 22 July 2024"),
                BulletText("Start trip 2: 25 August - 1 September 2024"),
                BulletText(
                  "Location: Xaisomboun Province, Xao district, Naxaisavang village",
                ),
                // line
                Divider(
                  color: Colors.grey, // You can customize the color
                  thickness: 1, // Line thickness
                  indent: 20, // Start padding
                  endIndent: 20, // End padding
                ),
                SizedBox(height: 24),
                SectionTitle("Highlights"),
                BulletText(
                  "Walk to see the Pong cave with a difficult and challenging path.",
                ),
                BulletText(
                  "Try a boat in the lake to see the scenery of the green river and the beautiful rock formations.",
                ),
                BulletText("View across the river with green rice paddies."),
                SizedBox(height: 24),
                // line
                Divider(
                  color: Colors.grey, // You can customize the color
                  thickness: 1, // Line thickness
                  indent: 20, // Start padding
                  endIndent: 20, // End padding
                ),
                SectionTitle("What To Bring"),
                BulletText("A hat"),
                BulletText("Sunscreen"),
                BulletText("Mosquito repellent"),
                BulletText("Pocket money"),
                BulletText("Hiking shoes"),
                BulletText("Windproof clothing"),
                // line
                Divider(
                  color: Colors.grey, // You can customize the color
                  thickness: 1, // Line thickness
                  indent: 20, // Start padding
                  endIndent: 20, // End padding
                ),

                SectionTitle("Not suitable for"),
                BulletText("Pregnant Women"),
                BulletText("People with mobility impairments"),
                BulletText("People with heart problems"),
              ],
            ),
          ),

          //Other you can see line
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Other you can see",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF084886),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Food",
                          style: TextStyle(color: Color(0xFF084886)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Hotel",
                          style: TextStyle(color: Color(0xFF084886)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Text(
                  "Price",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "US\$ 10.85",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF084886),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "If you add 1 person, the price will increase by ",
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  "85 dollars.",
                  style: TextStyle(fontSize: 16, color: Colors.orange),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF084886),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Book now",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // other actions
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
          //footer
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

// tour info
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

//tour info
class BulletText extends StatelessWidget {
  final String text;
  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
