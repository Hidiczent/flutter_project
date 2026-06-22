
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API base URL for Lao Epic backend.
///
/// Values are read from (first match wins):
/// 1. `--dart-define` / `--dart-define-from-file` (JSON, e.g. `dart_defines.json`)
/// 2. Bundled `.env` asset (see `.env.example`)
class AppConfig {
  static const String _defaultOrigin =
      'https://laoepicthesisback-end-development.up.railway.app';

  static String _env(String key) => dotenv.env[key]?.trim() ?? '';

  static String get googleWebClientId {
    const fromDefine = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _env('GOOGLE_WEB_CLIENT_ID');
  }

  static bool get isGoogleSignInConfigured => googleWebClientId.isNotEmpty;

  static String get googleIosClientId {
    const fromDefine = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _env('GOOGLE_IOS_CLIENT_ID');
  }

  static String? get googleIosUrlScheme {
    final id = googleIosClientId;
    if (id.isEmpty || !id.endsWith('.apps.googleusercontent.com')) return null;
    final prefix = id.replaceAll('.apps.googleusercontent.com', '');
    return 'com.googleusercontent.apps.$prefix';
  }

  static String get origin {
    const fromDefine = String.fromEnvironment('API_ORIGIN');
    final raw = fromDefine.trim().isNotEmpty
        ? fromDefine.trim()
        : (_env('API_ORIGIN').isNotEmpty ? _env('API_ORIGIN') : _defaultOrigin);
    return raw.replaceAll(RegExp(r'/+$'), '');
  }

  static String get baseUrl => '$origin/api';

  /// Media url for this module.
  static String mediaUrl(String path) {
    final p = path.trim();
    if (p.isEmpty) return p;
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    if (p.startsWith('/')) return '$origin$p';
    return '$origin/$p';
  }
}
