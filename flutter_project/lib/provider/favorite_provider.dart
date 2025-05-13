import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteProvider with ChangeNotifier {
  Map<int, bool> _favorites = {}; // 🧠 save Status  favorite  packageId

  Map<int, bool> get favorites => _favorites;

  FavoriteProvider() {
    loadFavorites(); // Call loadFavorites when the app starts
  }

// Function to check if a package is favorited
  // This function takes a packageId as an argument and returns true if the package is favorited, false otherwise
  // It uses the _favorites map to check the status of the package
  // If the packageId is not found in the map, it returns false
  // This function is used to determine whether to show the favorite icon as filled or not
  // It is called in the UI to update the favorite icon based on the user's selection
  bool isFavorited(int packageId) {
    return _favorites[packageId] ?? false;
  }
  // Function to toggle the favorite status of a package
  // This function takes a packageId as an argument and toggles its favorite status
  // It updates the _favorites map to reflect the new status
  // It also saves the updated favorites to SharedPreferences
  // This function is called when the user taps on the favorite icon in the UI
  // It uses the SharedPreferences package to save the favorites locally
  // This allows the app to remember the user's favorite packages even after restarting
  // It uses the jsonEncode function to convert the map to a JSON string
  void toggleFavorite(int packageId) async {
    _favorites[packageId] = !(_favorites[packageId] ?? false);

    final prefs = await SharedPreferences.getInstance();
    final stringKeyMap = _favorites.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    prefs.setString(
      'favorites',
      jsonEncode(stringKeyMap),
    ); // ✅ Use key to  String

    notifyListeners(); // Notify listeners to update the UI
  // This function is called when the user taps on the favorite icon in the UI
  }


// Function to load favorites from SharedPreferences
  // This function retrieves the saved favorites from SharedPreferences
  // It uses the SharedPreferences package to access the saved data
  // It uses the jsonDecode function to convert the JSON string back to a map
  // This function is called when the app starts to load the saved favorites
  // It uses the notifyListeners function to update the UI after loading the favorites
  // This allows the app to remember the user's favorite packages even after restarting
  // It uses the jsonDecode function to convert the JSON string back to a map
  // It uses the MapEntry function to convert the string keys back to integers
  // It uses the notifyListeners function to update the UI after loading the favorites
  // This allows the app to remember the user's favorite packages even after restarting
  // It uses the jsonDecode function to convert the JSON string back to a map
  // It uses the MapEntry function to convert the string keys back to integers
  // It uses the notifyListeners function to update the UI after loading the favorites  
  void loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('favorites');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      _favorites = decoded.map((key, value) => MapEntry(int.parse(key), value));
      notifyListeners();
    }
  }
}
