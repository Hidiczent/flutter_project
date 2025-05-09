import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project/config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetailPage extends StatefulWidget {
  final int orderId;
  const BookingDetailPage({super.key, required this.orderId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  Map<String, dynamic>? orderDetail;

  @override
  void initState() {
    super.initState();
    fetchOrderDetail();
  }

  int get orderId => widget.orderId; // ใช้ getter เพื่อเข้าถึง orderId

  Future<void> fetchOrderDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(
      'jwt_token',
    ); // Get token from shared preferences

    if (token == null) {
      print('❌ Token not found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/orders/order/$orderId'), // Correct URL
        headers: {
          'Authorization': 'Bearer $token', // Send token in headers
        },
      );

      if (response.statusCode == 200) {
        print('✅ Data fetched successfully');
        // Decode the response as Map<String, dynamic> for a single order
        Map<String, dynamic> data = jsonDecode(response.body);

        // Set the orderDetail state
        setState(() {
          orderDetail = data;
        });
      } else {
        print('❌ Failed to fetch order details: ${response.statusCode}');
        throw Exception('Failed to load order details');
      }
    } catch (error) {
      print('❌ Error occurred: $error');
    }
  }

  // Format the date to show only Day-Month-Year
  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(
        dateString,
      ); // Parse string to DateTime
      return DateFormat(
        'dd-MM-yyyy',
      ).format(dateTime); // Format to Day-Month-Year
    } catch (e) {
      print('Error formatting date: $e');
      return dateString; // Return the original string if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่า orderDetail มีค่าแล้วหรือไม่
    if (orderDetail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF084886),
        title: const Text('Booking Detail'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Booking Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID: ${orderDetail!['order_id']}",
                      style: boldText.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text("Status: ${orderDetail!['order_status']}"),
                    const SizedBox(height: 8),
                    Text(
                      "Package Title: ${orderDetail!['package_title'] ?? 'Not Available'}",
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "Booked Date: ${formatDate(orderDetail!['order_date'])}",
                    ),
                    if (orderDetail!['cancellation_reason'] != null)
                      Text("Cancelled: ${orderDetail!['cancellation_reason']}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Info Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // child: Padding(
              //   padding: const EdgeInsets.all(16),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Text(
              //         "Payment Info",
              //         style: TextStyle(fontWeight: FontWeight.bold),
              //       ),
              //       const SizedBox(height: 8),
              //       Text("Payment ID: ${orderDetail!['id_payment']}"),
              //       if (orderDetail!['cancellation_date'] != null)
              //         Text(
              //           "Cancelled On: ${orderDetail!['cancellation_date']}",
              //         ),
              //     ],
              //   ),
              // ),
            ),
            // const SizedBox(height: 16),

            // Extra Information Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Additional Info",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Name: ${orderDetail!['first_name']} ${orderDetail!['last_name']}",
                    ),
                    Text("Email: ${orderDetail!['email']}"),
                    Text("Birth: ${formatDate(orderDetail!['Birth'])}"),
                    Text("Note: ${orderDetail!['Note']}"),
                    Text(
                      "Participants: ${orderDetail!['Number_of_participants']}",
                    ),
                    Text(
                      "Passport Number: ${orderDetail!['Number_of_pass_port']}",
                    ),
                    Text(
                      "Date for Book: ${formatDate(orderDetail!['Date_for_book'])}",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get boldText => const TextStyle(fontWeight: FontWeight.bold);
}
