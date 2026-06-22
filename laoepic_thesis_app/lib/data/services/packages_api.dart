
import 'dart:convert';

import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/data/models/package_list_filters.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:http/http.dart' as http;

/// Queries the tour package list with optional search and filter parameters.
class PackagesApi {
  static Future<List<PackageModel>> fetchPackages({
    PackageListFilters filters = const PackageListFilters(),
    int page = 1,
    int limit = 50,
    bool includeDraft = true,
  }) async {
    final query = filters.toQueryParams(page: page, limit: limit);
    if (includeDraft) {
      query['includeDraft'] = '1';
    }
    final uri = Uri.parse('${AppConfig.baseUrl}/packages').replace(
      queryParameters: query,
    );
    final response = await http.get(uri, headers: await buildPublicApiHeaders());
    if (response.statusCode != 200) {
      throw Exception('Failed to load packages (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = body['data'];
    final list = raw is List ? raw : <dynamic>[];
    return list
        .map((e) => PackageModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
