import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/Account_page.dart';
import 'package:flutter_project/Auth/pages/booking_detail_page.dart';
import 'package:flutter_project/Auth/pages/home.dart';
import 'package:flutter_project/config.dart';
import 'package:flutter_project/models/BookingHistoryModel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  late Future<List<BookingHistoryModel>> bookingHistoryFuture;

  @override
  void initState() {
    super.initState();
    bookingHistoryFuture = fetchBookingHistory();
  }

  Future<List<BookingHistoryModel>> fetchBookingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/orders/user/history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => BookingHistoryModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load booking history');
    }
  }

  Future<void> cancelOrder(int orderId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/orders/cancel/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"reason": reason}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order cancelled successfully")),
      );

      setState(() {
        bookingHistoryFuture = fetchBookingHistory(); // โหลดใหม่
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel order: ${response.body}")),
      );
    }
  }

  void showCancelDialog(int orderId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 10),
                Text("Cancel Order"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Are you sure you want to cancel this order?",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Reason",
                    hintText: "Enter your cancellation reason",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  cancelOrder(orderId, reasonController.text);
                },
                icon: const Icon(Icons.check),
                label: const Text("Confirm"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Booking'),
        backgroundColor: const Color(0xFF084886),
        centerTitle: true,
      ),
      body: FutureBuilder<List<BookingHistoryModel>>(
        future: bookingHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final historyList = snapshot.data ?? [];

          if (historyList.isEmpty) {
            return const Center(child: Text('No booking history found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailPage(orderId: item.orderId),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.packageTitle ?? "No Title"),
                              // Text(item.location),
                              Text("pay to trip: \$${item.price}"),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(DateTime.parse(item.dateRange)),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.status,
                                    style: TextStyle(
                                      color:
                                          item.status.toLowerCase() ==
                                                  'cancelled'
                                              ? Colors
                                                  .red // สีเทาเมื่อสถานะเป็น 'cancelled'
                                              : item.status.toLowerCase() ==
                                                  'pending'
                                              ? Colors
                                                  .amberAccent // สีเหลืองเมื่อสถานะเป็น 'pending'
                                              : Colors
                                                  .green, // สีส้มเมื่อสถานะเป็น 'confirmed'
                                    ),
                                  ),

                                  if (item.status.toLowerCase() != 'cancelled')
                                    TextButton(
                                      onPressed: () {
                                        showCancelDialog(
                                          item.orderId,
                                        ); // ✅ เรียก dialog
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                ],
                              ),

                              Text(
                                'Collection: ${item.points} points',
                                style: const TextStyle(
                                  color: Color(0xFF084886),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            item.imageUrl.isNotEmpty
                                ? item.imageUrl
                                : 'https://yourdomain.com/assets/images/Act3.jpg', // fallback จาก URL
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  'assets/images/Act3.jpg', // fallback ภายในแอป
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountPage()),
            );
          }
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
