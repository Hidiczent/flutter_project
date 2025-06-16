import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteProvider with ChangeNotifier {
  Map<int, bool> _favorites = {}; // 🧠 save Status  favorite  packageId

  Map<int, bool> get favorites => _favorites;

  FavoriteProvider() {
    loadFavorites(); // Call loadFavorites when the app starts
  }

  bool isFavorited(int packageId) {
    return _favorites[packageId] ?? false;
  }

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
