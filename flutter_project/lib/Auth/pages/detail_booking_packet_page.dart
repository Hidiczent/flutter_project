import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_project/Auth/pages/Account_page.dart';
// import 'package:flutter_project/Auth/pages/Booking.dart';
import 'package:flutter_project/Auth/pages/PacketTab.dart';
import 'package:flutter_project/config.dart';
import 'package:flutter_project/models/package_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'About_tab.dart';
// import 'home.dart';

class DetailBookingPacketPage extends StatefulWidget {
  final int packageId;

  const DetailBookingPacketPage({super.key, required this.packageId});

  @override
  State<DetailBookingPacketPage> createState() =>
      _DetailBookingPacketPageState();
}

class _DetailBookingPacketPageState extends State<DetailBookingPacketPage>
    with SingleTickerProviderStateMixin {
  bool isFavorited = false;
  late TabController _tabController;

  PackageModel? package;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    checkToken();
    loadFavoriteStatus();
    fetchPackageDetail();
    fetchPackageImages();
    _tabController = TabController(length: 3, vsync: this);
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
    } else {
      print("❌ No token found");
    }
  }

  Future<void> fetchPackageDetail() async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/packages/package/${widget.packageId}',
    );
    // print("📥 Fetching package detail from: $url");

    try {
      final response = await http.get(url);
      // print("📦 Raw package response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("✅ Decoded package data: $data");

        setState(() {
          package = PackageModel.fromJson(data);
          // print("📦 Parsed PackageModel: ${package!.title}");
        });
      } else {
        print(
          "❌ Failed to load package detail. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("❌ Error while fetching package detail: $e");
    }
  }

  Future<void> fetchPackageImages() async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/packageImage/package-images/${widget.packageId}',
    );
    // print("📥 Fetching images from: $url");

    try {
      final response = await http.get(url);
      // print("📸 Raw image response: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          imageUrls =
              data.map<String>((item) => item['image_url'] as String).toList();
          // print("✅ Loaded ${imageUrls.length} image(s)");
        });
      } else {
        print("❌ Failed to load images. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error loading images: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (package == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // 👈 ทำให้ปุ่มย้อนกลับเป็นสีขาว

          backgroundColor: Color(0xFF084886),
          title: Text("Package Detaill", style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            // 🔼 ภาพด้านบน
            SizedBox(
              height: 250,
              child:
                  imageUrls.isEmpty
                      ? Image.asset('assets/images/Act3.jpg', fit: BoxFit.cover)
                      : PageView.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Image.asset(
                                  'assets/images/Act3.jpg',
                                  fit: BoxFit.cover,
                                ),
                          );
                        },
                      ),
            ),

            // ✅ TabBar แยกออกมา
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF084886),
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              indicatorColor: const Color(0xFF084886),
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Packet'),
                Tab(text: 'Activity'),
              ],
            ),

            // ✅ TabBarView อยู่ใน Expanded เพื่อให้ scroll ได้
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  AboutTab(package: package!),
                  PacketTab(package: package!),
                  const Center(child: Text("Activity section coming soon")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
