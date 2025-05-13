import 'package:flutter/material.dart';
import 'package:flutter_project/Screens/BookingPages/booking.dart';
import 'package:flutter_project/models/package_model.dart';

class PacketTab extends StatelessWidget {
  final PackageModel package;
  const PacketTab({super.key, required this.package});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${package.title}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Price: ${package.priceInUsd} USD",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  children: const [
                    Text(
                      "Review 4.0 ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    Text(
                      " (300)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  child: Text("${package.title},\n${package.priceInUsd} USD"),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF084886),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BookingFormPage(packageId: package.id),
                        ),
                      );
                    },
                    child: const Text(
                      "Book now",
                      style: TextStyle(color: Colors.white),
                    ),
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
