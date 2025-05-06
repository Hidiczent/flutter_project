import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/home.dart'; 
import 'package:flutter_project/Auth/pages/booking_confirm.dart';



class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Color(0xFF084886),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()),
  );
},
        ),
        title: const Text(
          'History to booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The latest', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingConfirmedPage()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Living in the fields with the villagers',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('In Luangnamtha, Lao'),
                            SizedBox(height: 4),
                            Text('pay to trip : \$50'),
                            Text('04.19~04.26/2024'),
                            Text('Compete trip', style: TextStyle(color: Color(0xFFE98A15))),
                            Text('Collection:  100 points', style: TextStyle(color: Color(0xFF084886))),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12)),
                        child: Image.asset(
                          'assets/images/6.jpg',
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Divider(),
          const Text(
            'In March',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          )
        ],
      ),
    )
    );
  }
}
