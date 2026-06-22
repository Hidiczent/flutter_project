import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';

/// Drives `MaterialApp.locale` and syncs `Accept-Language` for API calls via [readApiLocaleCode].
class ApiLocaleProvider extends ChangeNotifier {
  String _code = 'en';

  /// Function for this module.
  void Function(String code)? onLocaleChanged;

  String get code => _code;
  /// Loads  and notifies listeners.
  Future<void> load() async {
    _code = await readApiLocaleCode();
    onLocaleChanged?.call(_code);
    notifyListeners();
  }

  /// Updates locale and persists when needed.
  Future<void> setLocale(String next) async {
    await writeApiLocaleCode(next);
    _code = await readApiLocaleCode();
    onLocaleChanged?.call(_code);
    notifyListeners();
  }

  static Locale materialLocaleFrom(String code) {
    switch (code) {
      case 'th':
        return const Locale('th');
      case 'lo':
        return const Locale('lo');
      default:
        return const Locale('en');
    }
  }
}
