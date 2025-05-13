// import 'package:flutter/material.dart';
// import 'package:flutter_project/Auth/pages/Payment.dart';
// import 'package:flutter_project/Auth/pages/Booking.dart';

// class TourBookingPage extends StatefulWidget {
//   const TourBookingPage({super.key});

//   @override
//   State<TourBookingPage> createState() => _TourBookingPageState();
// }

// class _TourBookingPageState extends State<TourBookingPage> {
//   int selectedDateIndex = 0;
//   int selectedTimeIndex = 0;
//   int personCount = 3;

//   final List<String> dates = ['04/04', '05/04', '06/04', '07/04'];
//   final List<String> times = ['08:30', '10:30', '12:00', '13:00'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 Image.asset(
//                   'assets/images/6.jpg',
//                   width: double.infinity,
//                   height: 200,
//                   fit: BoxFit.cover,
//                 ),
//                 Positioned(
//                   top: 16,
//                   left: 16,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.black),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => BookingFormPage(
//                                   packageId: widget.package.id,
//                                 ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text(
//                 'Visit to Vangvieng Activity',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Please select a tour date',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Check'),
//                       Text('30/03/2024 - 25/09/2024 📅'),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: List.generate(dates.length, (index) {
//                       final isSelected = index == selectedDateIndex;
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: ChoiceChip(
//                           label: Text(dates[index]),
//                           selected: isSelected,
//                           onSelected: (_) {
//                             setState(() => selectedDateIndex = index);
//                           },
//                           selectedColor: Color(0xFFE98A15),
//                         ),
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 12),
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [Text('Time'), Text('Custom time 📅')],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: List.generate(times.length, (index) {
//                       final isSelected = index == selectedTimeIndex;
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: ChoiceChip(
//                           label: Text(times[index]),
//                           selected: isSelected,
//                           onSelected: (_) {
//                             setState(() => selectedTimeIndex = index);
//                           },
//                           selectedColor: Color(0xFFE98A15),
//                         ),
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text('Person'),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.remove),
//                         onPressed: () {
//                           if (personCount > 1) {
//                             setState(() => personCount--);
//                           }
//                         },
//                       ),
//                       Text(
//                         '$personCount',
//                         style: const TextStyle(fontSize: 18),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           setState(() => personCount++);
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: const BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.black12)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text(
//                         '₭ 1.399.000 KIP',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {},
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF084886),

//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                         ),
//                         child: const Text(
//                           'Add cart',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const PaymentPage(),
//                             ),
//                           );
//                         },

//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF084886),

//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                         ),
//                         child: const Text(
//                           'Booking',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
