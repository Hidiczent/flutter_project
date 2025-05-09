import 'dart:convert';

class PackageModel {
  final int id;
  final String title;
  final String mainImageUrl;
  final String about;
  final List<String> tourInfo;
  final List<String> bring;
  final double priceInUsd;

  PackageModel({
    required this.id,
    required this.title,
    required this.mainImageUrl,
    required this.about,
    required this.tourInfo,
    required this.bring,
    required this.priceInUsd,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic raw) {
      try {
        if (raw is List) {
          return List<String>.from(raw);
        } else if (raw is String) {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return List<String>.from(decoded);
          }
        }
      } catch (_) {
        // ignore parsing error
      }
      return [];
    }

    return PackageModel(
      id: json['package_id'],
      title: json['title'] ?? '',
      about: json['about'] ?? '',
      mainImageUrl: json['main_image_url'] ?? '',
      tourInfo: parseList(json['tour_info']),
      bring: parseList(json['bring']),
      priceInUsd:
          json['price_in_usd'] is String
              ? double.tryParse(json['price_in_usd']) ?? 0.0
              : (json['price_in_usd'] as num).toDouble(),
    );
  }
}
