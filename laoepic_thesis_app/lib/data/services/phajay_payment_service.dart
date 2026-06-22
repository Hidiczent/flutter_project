
import 'dart:convert';

import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:http/http.dart' as http;

/// PhaJay payment helpers — parity with web `createPhajayPaymentQr` / payment-link.
class PhajayPaymentService {
  static const List<String> qrBanks = [
    'bcel',
    'jdb',
    'ldb',
    'ib',
    'stb',
    'm_money',
  ];

  static Future<Map<String, dynamic>?> createPaymentLink({
    required String token,
    required String invoiceId,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/payments/phajay/payment-link'),
      headers: {
        ...await buildAuthApiHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'invoiceId': invoiceId}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) return null;
    return body['data'] as Map<String, dynamic>?;
  }

  static Future<Map<String, dynamic>?> createPaymentQr({
    required String token,
    required String invoiceId,
    String bank = 'bcel',
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/payments/phajay/payment-qr'),
      headers: {
        ...await buildAuthApiHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'invoiceId': invoiceId, 'bank': bank}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) return null;
    return body['data'] as Map<String, dynamic>?;
  }
}
