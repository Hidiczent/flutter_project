
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';

/// Loads and caches images and detail data for the currently viewed tour package.
class PackageDetailProvider with ChangeNotifier {
  PackageModel? _package;
  List<String> _imageUrls = [];
  bool _isLoading = true;

  PackageModel? get package => _package;
  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;

  static String _normKey(String u) {
    final t = u.trim();
    if (t.isEmpty) return '';
    try {
      final uri = Uri.parse(t);
      return uri.replace(query: '').toString().toLowerCase();
    } catch (_) {
      return t.toLowerCase();
    }
  }

  /// Loads package and notifies listeners.
  Future<void> loadPackage(int packageId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/packages/$packageId'),
        headers: await buildPublicApiHeaders(),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = body['data'];
        if (body['success'] == true && raw is Map<String, dynamic>) {
          _package = PackageModel.fromJson(raw);
        }
      }

      final fromJson = _package?.bannerImageUrls ?? <String>[];

      final imgRes = await http.get(
        Uri.parse('${AppConfig.baseUrl}/packages/$packageId/images'),
        headers: await buildPublicApiHeaders(),
      );

      final merged = <String>[];
      final seen = <String>{};

      void addUnique(String u) {
        final k = _normKey(u);
        if (k.isEmpty || seen.contains(k)) return;
        seen.add(k);
        merged.add(u.trim());
      }

      if (imgRes.statusCode == 200) {
        final imgBody = jsonDecode(imgRes.body) as Map<String, dynamic>;
        final raw = imgBody['data'];
        if (imgBody['success'] == true && raw is List && raw.isNotEmpty) {
          for (final e in raw) {
            addUnique(AppConfig.mediaUrl((e as Map)['imageUrl'].toString()));
          }
        }
      }

      for (final u in fromJson) {
        addUnique(u);
      }

      _imageUrls = merged.isNotEmpty ? merged : List<String>.from(fromJson);
    } catch (e) {
      debugPrint('Error loadPackage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  @Deprecated('Use loadPackage')
  /// Fetches package detail from the Lao Epic API.
  Future<void> fetchPackageDetail(int packageId) => loadPackage(packageId);

  @Deprecated('Merged into loadPackage')
  /// Fetches images from the Lao Epic API.
  Future<void> fetchImages(int packageId) async {}

  /// Clear for this module.
  void clear() {
    _package = null;
    _imageUrls = [];
    _isLoading = true;
    notifyListeners();
  }
}
