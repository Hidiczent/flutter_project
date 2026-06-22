/// Currency parsing and formatting helpers (Lao kip dot grouping).
library;

import 'package:intl/intl.dart';

/// Money display for Laos: `100.000 LAK` (dot thousands, space, currency code).
abstract final class MoneyFormat {
  static final NumberFormat _whole = NumberFormat('#,##0', 'de_DE');
  static final NumberFormat _decimal = NumberFormat('#,##0.##', 'de_DE');

  /// Normalizes currency codes (`KIP`, `₭`) to `LAK`.
  static String normalizeCurrency(String? code) {
    final c = (code ?? 'LAK').trim().toUpperCase();
    if (c == 'KIP' || c == '₭') return 'LAK';
    return c.isEmpty ? 'LAK' : c;
  }

  /// Parses numeric strings from API or user input (handles `.` and `,`).
  static num? parse(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    var s = value.toString().trim();
    if (s.isEmpty) return null;
    s = s.replaceAll(RegExp(r'[^\d,.\-]'), '');
    if (s.isEmpty) return null;

    if (s.contains(',') && s.contains('.')) {
      if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(',', '');
      }
    } else if (s.contains(',')) {
      final parts = s.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        s = '${parts[0]}.${parts[1]}';
      } else {
        s = s.replaceAll(',', '');
      }
    }

    return num.tryParse(s);
  }

  /// Formats a number with locale-appropriate grouping (no currency suffix).
  static String formatAmount(num? value, {int maxFractionDigits = 0}) {
    if (value == null) return '0';
    final n = value.toDouble();
    if (maxFractionDigits == 0 || n == n.roundToDouble()) {
      return _whole.format(n.round());
    }
    return _decimal.format(n);
  }

  /// Full price label, e.g. `1.399.000 LAK`.
  static String format(
    dynamic amount, {
    String? currency,
    bool showCurrency = true,
  }) {
    final code = normalizeCurrency(currency);
    final n = parse(amount);
    final digits = code == 'LAK' ? 0 : 2;
    final formatted = formatAmount(n, maxFractionDigits: digits);
    if (!showCurrency) return formatted;
    return '$formatted $code';
  }
}
