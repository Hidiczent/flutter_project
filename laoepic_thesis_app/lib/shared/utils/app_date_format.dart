/// Locale-aware date/time formatting for en, lo, and th.
library;

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

final Set<String> _initializedLocales = {};

/// Loads Intl symbol data for a locale code (required before formatting lo/th).
Future<void> ensureDateFormatting(String localeCode) async {
  final code = _normalizeLocale(localeCode);
  if (_initializedLocales.contains(code)) return;
  await initializeDateFormatting(code);
  _initializedLocales.add(code);
}

/// Preloads date formatting data for the three supported UI locales.
Future<void> ensureCommonDateLocales() async {
  for (final code in ['en', 'lo', 'th']) {
    await ensureDateFormatting(code);
  }
}

/// Maps API locale codes (`en`, `lo`, `th`) to Intl locale ids.
String _normalizeLocale(String code) {
  final c = code.trim().toLowerCase();
  if (c.startsWith('lo')) return 'lo';
  if (c.startsWith('th')) return 'th';
  return 'en';
}

/// Formats an ISO-8601 timestamp for display in the user's locale.
String formatDateTimeLocalized(
  String? iso,
  String localeCode, {
  bool dateOnly = false,
}) {
  if (iso == null || iso.isEmpty) return '—';
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  final local = d.toLocal();
  final code = _normalizeLocale(localeCode);
  try {
    if (dateOnly) {
      return DateFormat.yMMMd(code).format(local);
    }
    return DateFormat.yMMMd(code).add_jm().format(local);
  } catch (_) {
    if (dateOnly) {
      return DateFormat('dd/MM/yyyy').format(local);
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(local);
  }
}

/// Formats an inclusive date range using [formatDateTimeLocalized].
String formatDateRangeLocalized(
  String startIso,
  String endIso,
  String localeCode,
) {
  return '${formatDateTimeLocalized(startIso, localeCode, dateOnly: true)} – ${formatDateTimeLocalized(endIso, localeCode, dateOnly: true)}';
}
