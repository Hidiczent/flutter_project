
import 'dart:convert';

import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:http/http.dart' as http;

/// Syncs favorite package IDs with the backend wishlist for signed-in users.
class WishlistApi {
  static Future<List<String>> fetchIds(String token) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/wishlist/ids'),
      headers: await buildAuthApiHeaders(token),
    );
    if (response.statusCode != 200) return [];
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is! Map<String, dynamic>) return [];
    final ids = data['packageIds'];
    if (ids is! List) return [];
    return ids.map((e) => e.toString()).toList();
  }

  /// Toggle for this module.
  static Future<bool> toggle(String token, int packageId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/wishlist/toggle'),
      headers: {
        ...await buildAuthApiHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'packageId': packageId.toString()}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Wishlist toggle failed');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data['inWishlist'] == true;
    }
    return false;
  }

  /// Merge guest for this module.
  static Future<int> mergeGuest(String token, List<String> packageIds) async {
    if (packageIds.isEmpty) return 0;
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/wishlist/merge'),
      headers: {
        ...await buildAuthApiHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'packageIds': packageIds}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) return 0;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data['merged'] is int
          ? data['merged'] as int
          : int.tryParse('${data['merged']}') ?? 0;
    }
    return 0;
  }
}
