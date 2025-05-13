import 'package:flutter/material.dart';

import 'package:flutter_project/Screens/BookingPages/booking.dart';
import 'package:flutter_project/models/package_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutTab extends StatefulWidget {
  final PackageModel package;
  const AboutTab({super.key, required this.package});

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    loadFavoriteStatus();
  }

  void loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorited = prefs.getBool('isFavorited') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Title
          Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 600), // ✅ สำคัญ
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.package.title}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "${widget.package.about}",
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text("Read More", style: TextStyle(color: Colors.orange)),
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
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                SectionTitle("About Trip"),
                ...widget.package.tourInfo.map((t) => BulletText(t)).toList(),

                // BulletText("Limit : 5 people"),
                // BulletText("Start trip 1: 15 July - 22 July 2024"),
                // BulletText("Start trip 2: 25 August - 1 September 2024"),
                // BulletText(
                //   "Location: Xaisomboun Province, Xao district, Naxaisavang village",
                // ),
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
                // ...widget.package.bring
                //     .map((item) => BulletText(item))
                //     .toList(),
                BulletText("A hat"),
                BulletText("Sunscreen"),
                BulletText("Mosquito repellent"),
                BulletText("Pocket money"),
                BulletText("Hiking shoes"),
                BulletText("Windproof clothing"),

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
                Text(
                  " ${widget.package.priceInUsd} USD",
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                BookingFormPage(packageId: widget.package.id),
                      ),
                    );
                  },
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
