
import 'dart:convert';

import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for a traveler review including rating, comment, and package reference.
class PackageReview {
  final String reviewId;
  final int rating;
  final String? comment;
  final String reviewerName;
  final String? createdAt;
  final String packageId;
  final String? packageTitle;
  final String? reviewerAvatar;

  const PackageReview({
    required this.reviewId,
    required this.rating,
    this.comment,
    required this.reviewerName,
    this.createdAt,
    required this.packageId,
    this.packageTitle,
    this.reviewerAvatar,
  });

  PackageReview copyWith({
    String? packageTitle,
    String? reviewerAvatar,
  }) {
    return PackageReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
      reviewerName: reviewerName,
      createdAt: createdAt,
      packageId: packageId,
      packageTitle: packageTitle ?? this.packageTitle,
      reviewerAvatar: reviewerAvatar ?? this.reviewerAvatar,
    );
  }

  factory PackageReview.fromJson(
    Map<String, dynamic> json, [
    String? fallbackPackageId,
  ]) {
    final pid =
        json['packageId']?.toString() ?? fallbackPackageId ?? '';
    return PackageReview(
      reviewId: json['reviewId']?.toString() ?? '',
      rating:
          json['rating'] is int
              ? json['rating'] as int
              : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
      reviewerName: json['reviewerName']?.toString() ?? 'Traveler',
      createdAt: json['createdAt']?.toString(),
      packageId: pid,
      packageTitle: json['packageTitle']?.toString(),
      reviewerAvatar: json['reviewerAvatar']?.toString(),
    );
  }
}

/// Creates and fetches package reviews, including featured reviews for the home page.
class ReviewsApi {
  static Future<List<PackageReview>> fetchByPackage(String packageId) async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/reviews/package/$packageId'),
      headers: await buildPublicApiHeaders(),
    );
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = body['data'];
    if (raw is! List) return [];
    return raw
        .map(
          (e) => PackageReview.fromJson(
            Map<String, dynamic>.from(e as Map),
            packageId,
          ),
        )
        .toList();
  }

  static Future<List<PackageReview>> fetchRecent({
    int limit = 3,
    List<int>? packageIds,
    Map<int, String>? packageTitles,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/reviews/recent').replace(
        queryParameters: {'limit': limit.toString()},
      );
      final res = await http.get(uri, headers: await buildPublicApiHeaders());
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = body['data'];
        if (raw is List) {
          final items =
              raw
                  .map(
                    (e) => PackageReview.fromJson(
                      Map<String, dynamic>.from(e as Map),
                    ),
                  )
                  .where((r) => (r.comment ?? '').trim().isNotEmpty)
                  .toList();
          if (items.isNotEmpty) {
            return items.take(limit).toList();
          }
        }
      }
    } catch (_) {
      /* fall through */
    }

    if (packageIds != null && packageIds.isNotEmpty) {
      return fetchFeatured(
        packageIds: packageIds,
        packageTitles: packageTitles,
        limit: limit,
      );
    }
    return [];
  }

  /// Creates  via POST on the API.
  static Future<void> create({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in');
    }
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/reviews'),
      headers: {
        ...await buildAuthApiHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bookingId': bookingId.toString(),
        'rating': rating,
        'comment': comment,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201 || body['success'] != true) {
      throw Exception(body['message']?.toString() ?? 'Failed to submit review');
    }
  }
  static Future<List<PackageReview>> fetchFeatured({
    required List<int> packageIds,
    Map<int, String>? packageTitles,
    int limit = 3,
  }) async {
    final out = <PackageReview>[];
    for (final id in packageIds) {
      if (out.length >= limit) break;
      final list = await fetchByPackage(id.toString());
      for (final r in list) {
        if (out.length >= limit) break;
        if ((r.comment ?? '').trim().isEmpty) continue;
        out.add(
          r.copyWith(
            packageTitle: r.packageTitle ?? packageTitles?[id],
          ),
        );
      }
    }
    out.sort((a, b) {
      final ta = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
      final tb = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
      return tb.compareTo(ta);
    });
    return out.take(limit).toList();
  }
}
