import 'package:flutter/material.dart';

class BottomNavProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  // Function to change the current index
  // This function is called when the user taps on a different tab in the bottom navigation bar
  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
