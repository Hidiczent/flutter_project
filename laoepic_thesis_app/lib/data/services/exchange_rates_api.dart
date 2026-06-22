
import 'dart:convert';

import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:http/http.dart' as http;

/// Single currency conversion rate record from the backend exchange-rates API.
class ExchangeRate {
  final String currencyCode;
  final double rateValue;

  const ExchangeRate({required this.currencyCode, required this.rateValue});

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      currencyCode: json['currencyCode']?.toString().toUpperCase() ?? '',
      rateValue: double.tryParse(json['rateValue']?.toString() ?? '') ?? 0,
    );
  }
}

/// Loads latest LAK/USD/THB exchange rates used for approximate price display.
class ExchangeRatesApi {
  static Future<List<ExchangeRate>> fetchLatest() async {
    final res = await http.get(
      Uri.parse('${AppConfig.baseUrl}/exchange-rates/public/latest'),
      headers: await buildPublicApiHeaders(),
    );
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = body['data'];
    if (raw is! List) return [];
    return raw
        .map((e) => ExchangeRate.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((r) => r.currencyCode.isNotEmpty && r.rateValue > 0)
        .toList();
  }
}
