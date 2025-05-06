import 'package:flutter/material.dart';
import 'package:flutter_project/Auth/pages/tourbooking.dart'; 




class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  // int selectedGuideIndex = 0;
  // int selectedTransportIndex = 0;
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // final List<Map<String, String>> guides = [
  //   {
  //     'name': 'Ms TavanH',
  //     'lastname': 'THAMMAVONG',
  //     'image': 'https://via.placeholder.com/100x100.png?text=Guide+1',
  //   },
  //   {
  //     'name': 'Mr Sompong',
  //     'lastname': 'THAMMAVONG',
  //     'image': 'https://via.placeholder.com/100x100.png?text=Guide+2',
  //   },
  // ];
  // final List<Map<String, String>> transportOptions = [
  //   {
  //     'title': 'Bus',
  //     'time': '5–6 Hour',
  //     'price': '200.000 kip',
  //     'image': 'assets/images/6.jpg',

  //   },
  //   {
  //     'title': 'Van',
  //     'time': '5–6 Hour',
  //     'price': '200.000 kip',
  //     'image': 'assets/images/6.jpg',
  //   },
  //   {
  //     'title': 'Taxi',
  //     'time': '5–6 Hour',
  //     'price': '200.000 kip',
  //     'image': 'assets/images/6.jpg',
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Color(0xFF084886),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.pop(context); // กลับหน้าก่อนหน้า
    },
  ),
  title: const Text(
    "Proceed with booking",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "We would like information about you to contact  and to notify you of events and to confirm bookings, please contact us if there are any errors.",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              sectionHeader("Get on the way"),
              infoRow(Icons.email, "2005saymay@gmail.com"),
              infoRow(Icons.phone, "020 54 349 032"),
              infoRow(Icons.phone_android, "+856 20 54 349 032"),
              const SizedBox(height: 12),
              sectionHeader("Write your information"),
              textField("Your Name", nameController),
              textField("Your Surname", surnameController),
              textField("Your Number", phoneController, prefixText: "+856 "),
              textField("Your Email", emailController),
              const SizedBox(height: 16),
              // sectionHeader("Select Guide to tours"),
              // const Text(
              //   "We would like information about you to contact  and to notify",
              //   style: TextStyle(fontSize: 13),
              // ),
              const SizedBox(height: 12),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: List.generate(
              //     guides.length,
              //     (index) => guideCard(index),
              //   ),
              // ),
              // const SizedBox(height: 24),
              // sectionHeader("Select transportation"),
              // const Text(
              //   "You can select about how to transportation do you want",
              //   style: TextStyle(fontSize: 13),
              // ),
              // const SizedBox(height: 12),
              // ...List.generate(
              //   transportOptions.length,
              //   (index) => transportCard(index),
              // ),
              // const SizedBox(height: 24),
             Center(
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: Color(0xFF084886),
    ),
    onPressed: () {
  if (_formKey.currentState!.validate()) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TourBookingPage()),
    );
  }
},

    child: const Text("Next", style: TextStyle(color: Colors.white)),
  ),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8),
    color: Color(0xFF084886),
    child: Padding(
      padding: const EdgeInsets.only(left: 12), // ✅ ขยับข้อความเฉพาะไปทางขวา
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.left,
      ),
    ),
  );
}


  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget textField(
    String label,
    TextEditingController controller, {
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          border: const OutlineInputBorder(),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  // Widget guideCard(int index) {
  //   final guide = guides[index];
  //   final isSelected = index == selectedGuideIndex;
  //   return Column(
  //     children: [
  //       Stack(
  //         alignment: Alignment.topRight,
  //         children: [
  //           CircleAvatar(
  //             backgroundImage: NetworkImage(guide['image']!),
  //             radius: 40,
  //           ),
  //           if (isSelected)
  //             const CircleAvatar(
  //               backgroundColor: Colors.green,
  //               radius: 12,
  //               child: Icon(Icons.check, size: 16, color: Colors.white),
  //             ),
  //         ],
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         guide['name']!,
  //         style: const TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       Text(guide['lastname']!),
  //       ElevatedButton(
  //         style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
  //         onPressed: () {
  //           setState(() => selectedGuideIndex = index);
  //         },
  //         child: const Text("Click"),
  //       ),
  //     ],
  //   );
  // }

//   Widget transportCard(int index) {
//     final transport = transportOptions[index];
//     final isSelected = index == selectedTransportIndex;
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       elevation: 3,
//       child: ListTile(
//         leading: Image.network(
//           transport['image']!,
//           width: 60,
//           fit: BoxFit.cover,
//         ),
//         title: Text(transport['title']!),
//         subtitle: Text(
//           "${transport['time']}\nStarting price: ${transport['price']!}",
//         ),
//         isThreeLine: true,
//         trailing: Icon(
//           isSelected ? Icons.check_circle : Icons.radio_button_off,
//           color: isSelected ? Colors.green : Colors.grey,
//         ),
//         onTap: () {
//           setState(() => selectedTransportIndex = index);
//         },
//       ),
//     );
//   }
}
