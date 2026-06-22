import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/shared/utils/app_date_format.dart';

/// One-time startup: bindings, optional `.env`, date locales, and i18n bootstrap.
class AppBootstrap {
  AppBootstrap._();

  static Future<UiI18n> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await ensureCommonDateLocales();
    await _loadEnvIfPresent();
    return UiI18n.createFromSavedLocale();
  }

  static Future<void> _loadEnvIfPresent() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // `.env` is optional; copy from `.env.example` for local Google Sign-In.
    }
  }
}
