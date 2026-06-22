
import 'dart:convert';

import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/data/models/package_village.dart';
import 'package:http/http.dart' as http;

/// Fetches catalog metadata like provinces, villages, package types, and tour seasons.
class CatalogApi {
  static List<T> _parseList<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = body['data'];
    final list = raw is List ? raw : <dynamic>[];
    return list
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<List<PopularProvince>> fetchPopularProvinces({
    int limit = 3,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/geo/provinces/popular',
    ).replace(queryParameters: {'limit': '$limit'});
    final response = await http.get(uri, headers: await buildPublicApiHeaders());
    return _parseList(response, PopularProvince.fromJson);
  }

  static Future<List<PackageTypeItem>> fetchPackageTypes({int limit = 50}) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/package-types').replace(
      queryParameters: {'page': '1', 'limit': '$limit', 'status': 'active'},
    );
    final response = await http.get(uri, headers: await buildPublicApiHeaders());
    final items = _parseList(response, PackageTypeItem.fromJson);
    items.sort((a, b) => b.packageCount.compareTo(a.packageCount));
    return items;
  }

  static Future<List<TourSeasonItem>> fetchTourSeasons() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/tour-seasons');
    final response = await http.get(uri, headers: await buildPublicApiHeaders());
    final items = _parseList(response, TourSeasonItem.fromJson);
    return items.where((s) => s.status != 'inactive').toList();
  }
}
