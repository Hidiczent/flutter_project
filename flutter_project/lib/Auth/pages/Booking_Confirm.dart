import 'package:flutter/material.dart';

class BookingConfirmedPage extends StatelessWidget {
  const BookingConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF084886),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Congratulations!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text('Your tickets are successfully booked.'),
                  SizedBox(height: 10),
                  Text('Booking ID:  #A145XD', style: TextStyle(color: Colors.blue)),
                  Text('Booked On:  13/07/2018'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Booking Details', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('CHANGE', style: TextStyle(color: Colors.purple)),
              ],
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.description),
              title: Text('Package'),
              subtitle: Text('Experience Kerala'),
            ),
            const ListTile(
              leading: Icon(Icons.group),
              title: Text('Passengers'),
              subtitle: Text('2 Adults, 1 Child'),
            ),
            const ListTile(
              leading: Icon(Icons.date_range),
              title: Text('Departure'),
              subtitle: Text('18/07/2018 • 11:00 pm'),
            ),
            const SizedBox(height: 20),
            const Text('Payment Summary', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            summaryRow('Subtotal', '1.500.000'),
            summaryRow('GST (18%)', '1.000.000'),
            const Divider(),
            Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Use my wallet credits'),
                Spacer(),
                Text('1.000.000'),
              ],
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 28.0),
              child: Text('Available: 2.500.000', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
