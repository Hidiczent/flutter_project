import 'package:flutter/material.dart';
import 'package:flutter_project/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingFormPage extends StatefulWidget {
  final int packageId; // ✅ เพิ่ม

  const BookingFormPage({super.key, required this.packageId});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final birthController = TextEditingController();
  final noteController = TextEditingController();
  final passportController = TextEditingController();
  final bookingDateController = TextEditingController();

  String? selectedNationalityId;
  List<Map<String, dynamic>> nationalities = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchNationalities();
  }

  Future<void> fetchNationalities() async {
    final url = Uri.parse('${AppConfig.baseUrl}/nationality/nationalities');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // DEBUG:
      print("Raw nationality: $data");

      // FILTER: only if structure is correct
      final filtered =
          List<Map<String, dynamic>>.from(data)
              .where((n) => n['ID_Nationality'] != null && n['name'] != null)
              .toList();

      setState(() {
        nationalities = filtered;
        isLoading = false;
      });

      print(
        "Filtered: ${filtered.map((e) => '${e['nationality_id']}-${e['name']}')}",
      );
    } else {
      print("Failed to load nationalities: ${res.body}");
    }
  }

  String? formatDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length != 3) return null;

      final year = parts[0];
      final month = parts[2].padLeft(2, '0');
      final day = parts[1].padLeft(2, '0');

      return "$year-$month-$day";
    } catch (_) {
      return null;
    }
  }

  String? formatBirthDate(String input) {
    try {
      // รับจาก TextField เป็น dd/MM/yyyy
      final parsed = DateFormat('dd/MM/yyyy').parseStrict(input);
      return DateFormat('yyyy-MM-dd').format(parsed); // ✅ ส่งแบบ MySQL
    } catch (e) {
      return null; // จะกลายเป็น 'Invalid date' ถ้า parse ไม่ผ่าน
    }
  }

  String? formatBookingDate(String input) {
    try {
      final parsed = DateFormat('dd/MM/yyyy').parseStrict(input);
      return parsed.toIso8601String(); // ส่งไป backend ได้เลย
    } catch (_) {
      return null;
    }
  }

  Future<void> submitBooking() async {
    setState(() => isSubmitting = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); // ✅

    if (token == null) {
      print("❌ No token found");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must login before booking")),
      );
      return;
    }
    final birthFormatted = formatBirthDate(birthController.text);
    final bookingDateFormatted = formatBookingDate(bookingDateController.text);
    if (birthFormatted == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid birth date format")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    // 🔹 STEP 1: Submit register_form_to_book
    final url = Uri.parse('${AppConfig.baseUrl}/registerform/send-form-email');

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // ✅ เพิ่มบรรทัดนี้
      },
      body: jsonEncode({
        "first_name": nameController.text,
        "last_name": surnameController.text,
        "email": emailController.text,
        "birth": birthFormatted,
        "nationality_id": selectedNationalityId,
        "date_for_booking": bookingDateFormatted,
        "number_of_participants": 1,
        "passport_number": passportController.text,
        "note": noteController.text,
        "package_id": widget.packageId,
      }),
    );

    if (res.statusCode == 200) {
      final responseData = jsonDecode(res.body);
      final reformbookId = responseData['form']?['ID_Reformbook']; // ✅ สำคัญ

      if (reformbookId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Reformbook ID not found")),
        );
        setState(() => isSubmitting = false);
        print({
          "first_name": nameController.text,
          "last_name": surnameController.text,
          "email": emailController.text,
          "birth": birthFormatted,
          "nationality_id": selectedNationalityId,
          "date_for_booking": DateTime.now().toIso8601String(),
          "number_of_participants": 1,
          "passport_number": passportController.text,

          "note": noteController.text,
          "package_id": widget.packageId,
        });

        return;
      }

      // 🔹 STEP 2: Create order
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final orderRes = await http.post(
        Uri.parse('${AppConfig.baseUrl}/orders/users/orders'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "ID_Reformbook": reformbookId,
          "package_id": widget.packageId,
          "order_date": DateTime.now().toIso8601String(),
          "order_status": "Pending",
          "id_payment": null, // หรือใส่ค่าที่เกี่ยวข้อง
        }),
      );

      setState(() => isSubmitting = false);

      if (orderRes.statusCode == 201) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: const Text("Booking Created"),
                content: const Text(
                  "Your booking has been submitted successfully.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // กลับหน้า Home
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Create order failed: ${orderRes.body}")),
        );
      }
    } else {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Booking failed: ${res.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF084886),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Proceed with booking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "We would like information about you to contact and to notify you of events and to confirm bookings.",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                sectionHeader("Write your information"),
                textField("First Name", nameController),
                textField("Last Name", surnameController),
                textField("Phone Number", phoneController),
                textField("Email", emailController),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );

                      if (pickedDate != null) {
                        bookingDateController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(pickedDate);
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: bookingDateController,
                        decoration: const InputDecoration(
                          labelText: "Date for Booking (dd/MM/yyyy)",
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        birthController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(pickedDate);
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: birthController,
                        decoration: const InputDecoration(
                          labelText: "Birth (dd/MM/yyyy)",
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Nationality"),
                  value: selectedNationalityId,
                  items:
                      nationalities.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['ID_Nationality'].toString(), // ✅ ตรง key
                          child: Text(item['name']),
                        );
                      }).toList(),
                  onChanged: (val) {
                    print("Selected: $val"); // ✅ Debug
                    setState(() => selectedNationalityId = val);
                  },
                  validator: (val) => val == null ? 'Required' : null,
                ),

                textField("Passport Number", passportController),
                textField("Note (optional)", noteController),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF084886),
                  ),
                  onPressed:
                      isSubmitting
                          ? null
                          : () {
                            if (_formKey.currentState!.validate()) {
                              submitBooking();
                            }
                          },
                  child:
                      isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Next",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF084886),
      borderRadius: BorderRadius.circular(5),
    ),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.only(left: 12),
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

  Widget textField(String label, TextEditingController controller) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    ),
  );
}
