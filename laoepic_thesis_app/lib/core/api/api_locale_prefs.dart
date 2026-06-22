
import 'package:shared_preferences/shared_preferences.dart';

/// Stored API / content locale. Must match backend `TranslationLocale`: en | th | lo.
const String kApiLocalePrefsKey = 'api_locale';

/// Reads the persisted API content locale code (en, th, or lo) from SharedPreferences.
Future<String> readApiLocaleCode() async {
  final p = await SharedPreferences.getInstance();
  final s = p.getString(kApiLocalePrefsKey)?.toLowerCase().trim();
  if (s == 'th' || s == 'lo' || s == 'en') return s ?? 'en';
  return 'en';
}

/// Persists the chosen API content locale so requests send the matching Accept-Language header.
Future<void> writeApiLocaleCode(String code) async {
  final v = code.toLowerCase().trim();
  if (v != 'th' && v != 'lo' && v != 'en') return;
  final p = await SharedPreferences.getInstance();
  await p.setString(kApiLocalePrefsKey, v);
}

/// Returns HTTP headers with `Accept-Language` set to [code] (`en`, `th`, or `lo`).
Map<String, String> localeHeadersFromCode(String code) {
  return {'Accept-Language': code};
}

/// Builds default HTTP headers including Accept-Language from stored locale prefs.
Future<Map<String, String>> buildPublicApiHeaders() async {
  final c = await readApiLocaleCode();
  return Map<String, String>.from(localeHeadersFromCode(c));
}

/// Like [buildPublicApiHeaders] but adds a Bearer token when the user is signed in.
Future<Map<String, String>> buildAuthApiHeaders(String? token) async {
  final h = await buildPublicApiHeaders();
  if (token != null && token.isNotEmpty) {
    h['Authorization'] = 'Bearer $token';
  }
  return h;
}
