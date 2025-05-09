// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_project/config.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class BookingConfirmedPage extends StatefulWidget {
//   const BookingConfirmedPage({super.key});

//   @override
//   _BookingConfirmedPageState createState() => _BookingConfirmedPageState();
// }

// class _BookingConfirmedPageState extends State<BookingConfirmedPage> {
//   late Future<Map<String, dynamic>> bookingDetails;

//   @override
//   void initState() {
//     super.initState();
//     bookingDetails = fetchBookingDetails();  // กำหนดค่า Future ที่จะใช้ใน FutureBuilder
//   }

//   Future<Map<String, dynamic>> fetchBookingDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('jwt_token');  // ดึง token จาก shared preferences

//     if (token == null) {
//       print('❌ Token not found');
//       return {};  // คืนค่าว่างเมื่อไม่มี token
//     }

//     final response = await http.get(
//       Uri.parse('${AppConfig.baseUrl}/orders/orders/confirmed'),
//       headers: {
//         'Authorization': 'Bearer $token',  // ส่ง token ไปใน headers
//       },
//     );

//     if (response.statusCode == 200) {
//       print('✅ Data fetched successfully');
//       return jsonDecode(response.body);  // คืนค่าที่ได้รับจาก API
//     } else {
//       print('❌ Failed to fetch order details');
//       throw Exception('Failed to load order details');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Color(0xFF084886),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Booking Confirmed',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: bookingDetails,  // ใช้ตัวแปร bookingDetails
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No booking details found.'));
//           }

//           var data = snapshot.data!;
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Congratulations!',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text('Your tickets are successfully booked.'),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Booking ID: #${data['booking_id']}',
//                         style: const TextStyle(color: Colors.blue),
//                       ),
//                       Text('Booked On: ${data['booking_date']}'),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     Text(
//                       'Booking Details',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text('CHANGE', style: TextStyle(color: Colors.purple)),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 ListTile(
//                   leading: const Icon(Icons.description),
//                   title: const Text('Package'),
//                   subtitle: Text(data['package_name']),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.group),
//                   title: const Text('Passengers'),
//                   subtitle: Text('${data['passengers_count']}'),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.date_range),
//                   title: const Text('Departure'),
//                   subtitle: Text('${data['departure_date']}'),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Payment Summary',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 summaryRow('Subtotal', '${data['subtotal']}'),
//                 summaryRow('GST (18%)', '${data['gst']}'),
//                 const Divider(),
//                 Row(
//                   children: const [
//                     Icon(Icons.check_circle, color: Colors.green, size: 20),
//                     SizedBox(width: 8),
//                     Text('Use my wallet credits'),
//                     Spacer(),
//                     Text('1.000.000'),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 const Padding(
//                   padding: EdgeInsets.only(left: 28.0),
//                   child: Text(
//                     'Available: 2.500.000',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget summaryRow(String label, String amount) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label),
//           Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }
