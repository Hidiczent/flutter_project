import 'package:flutter/material.dart';

class FullImage {
  static Future<void> showFullImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/ChatContract/Profile.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
