import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/booking_detail_page.dart';
import 'package:flutter_project/config.dart';
import 'package:flutter_project/models/NotificationModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> notifications = [];
  int unreadNotificationsCount =
      0; // ตัวแปรเก็บจำนวน notification ที่ยังไม่ได้อ่าน

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    // ตรวจสอบว่า token มีค่า
    if (token == null) {
      print("❌ No token found");
      return;
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/notification/user/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        notifications =
            data.map((json) => NotificationItem.fromJson(json)).toList();
        unreadNotificationsCount =
            notifications
                .where(
                  (notification) => notification.statusNotification == 'new',
                )
                .length; // นับจำนวน notification ที่ยังไม่ได้อ่าน
      });
    } else {
      print("❌ Failed to fetch notifications. Status: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  // Method to navigate to BookingDetailPage
  void navigateToBookingDetail(int orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingDetailPage(
              orderId: orderId,
            ), // Pass orderId to the new page
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF084886),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
          // เพิ่มไอคอน notification พร้อมตัวเลข
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.amber),
                onPressed: () {
                  // Do something when notification icon is tapped
                },
              ),
              if (unreadNotificationsCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
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
            ],
          ),
        ],
      ),
      body:
          notifications.isEmpty
              ? const Center(child: Text("No notifications yet."))
              : ListView.builder(
                itemCount: notifications.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(item.imageUrl),
                        backgroundColor: Colors.grey[200],
                      ),
                      title: Text(
                        "Your order for '${item.title}' has been ${item.statusNotification}",
                      ),
                      subtitle: Text(
                        "Order ID: ${item.orderId}\nStatus: ${item.orderStatus}",
                        style: TextStyle(
                          color:
                              item.orderStatus == 'confirmed'
                                  ? Colors.green
                                  : item.orderStatus == 'pending'
                                  ? Colors.yellow
                                  : item.orderStatus == 'cancelled'
                                  ? Colors.red
                                  : Colors
                                      .grey, // default color if no status matches
                        ),
                      ),
                      trailing:
                          item.statusNotification == 'new'
                              ? Icon(Icons.notifications, color: Colors.red)
                              : Icon(
                                Icons.notifications_active,
                                color: Colors.green,
                              ),

                      onTap: () {
                        // เปลี่ยนสถานะเป็น 'read'
                        setState(() {
                          item.statusNotification = 'read';
                          // อัพเดตจำนวน notifications ที่ยังไม่ได้อ่าน
                          unreadNotificationsCount =
                              notifications
                                  .where(
                                    (notification) =>
                                        notification.statusNotification ==
                                        'new',
                                  )
                                  .length;
                        });

                        // Navigate to BookingDetailPage when tapped
                        navigateToBookingDetail(item.orderId);
                      },
                    ),
                  );
                },
              ),
    );
  }
}
