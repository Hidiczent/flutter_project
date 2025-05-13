import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_project/Screens/BookingPages/detail_booking_packet_page.dart';
import 'package:flutter_project/Screens/Nofitications/notification_page.dart';
import 'package:flutter_project/widget/Package_Card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project/Auth/pages/Display_message.dart';
import 'package:flutter_project/config.dart';
import 'package:flutter_project/models/package_model.dart';
import 'package:flutter_project/provider/package_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  int unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    checkToken();
    fetchUnreadNotificationsCount();
  }

  void checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      print("🔐 Token: $token");
    } else {
      print("❌ No token found");
    }
  }
  /// Fetch unread notifications count
  Future<void> fetchUnreadNotificationsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/notification/user/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        unreadNotificationsCount =
            data.where((n) => n['status_notification'] == 'new').length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final packages = packageProvider.packages;
    final filteredPackages =
        packages
            .where(
              (pkg) =>
                  pkg.title.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body:
          packageProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  sectionTitle('Popular Province'),
                  imageCard('Vientiane', 'assets/images/Default.jpg'),
                  sectionTitle('Popular Activities'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          filteredPackages
                              .map((pkg) => PackageCard(pkg: pkg))
                              .toList(),
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
                  SizedBox(height: 20),
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
                ],
              ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        decoration: const BoxDecoration(color: Color(0xFF084886)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        decoration: const InputDecoration(
                          hintText: 'Search package...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              children: [
                GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.amber,
                    size: 30,
                  ),
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
                        border: Border.all(color: Colors.white, width: 1),
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
            const SizedBox(width: 12),
            GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Displaymenu()),
                  ),
              child: const FaIcon(
                FontAwesomeIcons.solidCommentDots,
                color: Colors.amber,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) => Padding(
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

  Widget imageCard(String title, String imagePath) => Container(
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

  Widget activityCardFromApi(PackageModel pkg) => GestureDetector(
    onTap:
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBookingPacketPage(packageId: pkg.id),
          ),
        ),
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
                  children: List.generate(
                    5,
                    (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
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

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Column(
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
