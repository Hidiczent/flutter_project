
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/data/services/wishlist_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _guestKey = 'favorites_guest';
const _legacyKey = 'favorites';

/// Manages wishlisted package IDs for both guest local storage and logged-in API sync.
class FavoriteProvider with ChangeNotifier {
  final Map<int, bool> _favorites = {};
  bool _loading = false;

  Map<int, bool> get favorites => Map.unmodifiable(_favorites);
  bool get isLoading => _loading;

  FavoriteProvider() {
    loadFavorites();
  }

  /// Is favorited for this module.
  bool isFavorited(int packageId) => _favorites[packageId] ?? false;

  List<int> get favoriteIds =>
      _favorites.entries.where((e) => e.value).map((e) => e.key).toList();

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
  /// Loads favorites and notifies listeners.
  Future<void> loadFavorites() async {
    _loading = true;
    notifyListeners();

    final token = await _token();
    if (token != null && token.isNotEmpty) {
      try {
        final ids = await WishlistApi.fetchIds(token);
        _favorites
          ..clear()
          ..addEntries(
            ids.map((id) {
              final n = int.tryParse(id);
              return n == null ? null : MapEntry(n, true);
            }).whereType<MapEntry<int, bool>>(),
          );
      } catch (_) {
        await _loadGuestFavorites();
      }
    } else {
      await _loadGuestFavorites();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _loadGuestFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_guestKey) ?? prefs.getString(_legacyKey);
    _favorites.clear();
    if (jsonString == null) return;
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        final id = int.tryParse(key);
        if (id != null && value == true) _favorites[id] = true;
      });
    } catch (_) {}
  }

  Future<void> _saveGuestFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final stringKeyMap = _favorites.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    await prefs.setString(_guestKey, jsonEncode(stringKeyMap));
  }

  /// Merge guest wishlist after login for this module.
  Future<void> mergeGuestWishlistAfterLogin() async {
    final token = await _token();
    if (token == null || token.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final guestRaw = prefs.getString(_guestKey) ?? prefs.getString(_legacyKey);
    if (guestRaw != null) {
      try {
        final decoded = jsonDecode(guestRaw) as Map<String, dynamic>;
        final ids =
            decoded.entries
                .where((e) => e.value == true)
                .map((e) => e.key)
                .toList();
        if (ids.isNotEmpty) {
          await WishlistApi.mergeGuest(token, ids);
        }
        await prefs.remove(_guestKey);
        await prefs.remove(_legacyKey);
      } catch (_) {}
    }
    await loadFavorites();
  }

  /// Toggle favorite for this module.
  Future<void> toggleFavorite(int packageId) async {
    final token = await _token();
    if (token != null && token.isNotEmpty) {
      try {
        final inList = await WishlistApi.toggle(token, packageId);
        _favorites[packageId] = inList;
      } catch (_) {
        _favorites[packageId] = !(_favorites[packageId] ?? false);
        await _saveGuestFavorites();
      }
    } else {
      _favorites[packageId] = !(_favorites[packageId] ?? false);
      await _saveGuestFavorites();
    }
    notifyListeners();
  }
}
