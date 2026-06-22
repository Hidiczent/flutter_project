import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';

/// Loads flat string maps from [assets/i18n/en.json] and [assets/i18n/lo.json].
/// API / persisted locale `th` uses English UI strings until you add `th.json`.
class UiI18n extends ChangeNotifier {
  static const Map<String, String> _empty = {};

  UiI18n({Map<String, String>? bootstrap})
      : _bootstrap = _copyMap(bootstrap),
        _strings = _copyMap(bootstrap);

  final Map<String, String> _bootstrap;
  Map<String, String> _strings;
  String _lastSyncedCode = '';
  Future<void> _loadChain = Future.value();

  static Map<String, String> _copyMap(Map<String, String>? source) {
    if (source == null || source.isEmpty) return Map<String, String>.from(_empty);
    return Map<String, String>.from(source);
  }

  /// Preferred startup: loads saved locale strings before [runApp].
  static Future<UiI18n> createFromSavedLocale() async {
    final code = await readApiLocaleCode();
    final bootstrap = await loadBootstrapForLocale(code);
    return UiI18n(bootstrap: bootstrap);
  }

  /// Parse JSON for use in [main] bootstrap (same format as asset files).
  static Map<String, String> parseJsonMap(String raw) {
    if (raw.trim().isEmpty) return Map<String, String>.from(_empty);
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return Map<String, String>.from(_empty);
      return Map<String, String>.from(
        decoded.map(
          (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
        ),
      );
    } catch (e, st) {
      debugPrint('UiI18n.parseJsonMap failed: $e\n$st');
      return Map<String, String>.from(_empty);
    }
  }

  /// Load strings for app startup (before [runApp]).
  static Future<Map<String, String>> loadBootstrapForLocale(
    String apiLocaleCode,
  ) async {
    final normalized = apiLocaleCode.toLowerCase().trim();
    try {
      final enRaw = await rootBundle.loadString('assets/i18n/en.json');
      final enMap = parseJsonMap(enRaw);
      if (normalized == 'lo') {
        final loRaw = await rootBundle.loadString('assets/i18n/lo.json');
        final loMap = parseJsonMap(loRaw);
        return Map<String, String>.from({...enMap, ...loMap});
      }
      return Map<String, String>.from(enMap);
    } catch (e, st) {
      debugPrint('UiI18n.loadBootstrapForLocale failed: $e\n$st');
      return Map<String, String>.from(_empty);
    }
  }

  /// True after first successful load for the current locale target.
  bool get isReady => _strings.isNotEmpty;

  /// Replace `{name}` placeholders in the resolved string.
  String tr(String key, {Map<String, String>? params, String? fallback}) {
    var s = _strings[key] ?? _bootstrap[key] ?? fallback ?? key;
    if (kDebugMode && s == key && fallback == null) {
      debugPrint('UiI18n: missing key "$key" (locale=$_lastSyncedCode)');
    }
    if (params != null && params.isNotEmpty) {
      for (final e in params.entries) {
        s = s.replaceAll('{${e.key}}', e.value);
      }
    }
    return s;
  }

  /// Called when [ApiLocaleProvider] notifies (wired from [main]).
  void syncFromLocaleCode(String apiLocaleCode) {
    final normalized = apiLocaleCode.toLowerCase().trim();
    if (normalized.isEmpty) return;
    unawaited(_scheduleLoad(normalized));
  }

  /// Reload JSON from assets (use after adding keys or when UI shows raw key names).
  Future<void> reloadFromAssets(String apiLocaleCode) async {
    final normalized = apiLocaleCode.toLowerCase().trim();
    if (normalized.isEmpty) return;
    await _scheduleLoad(normalized);
  }

  Future<void> _scheduleLoad(String normalized) {
    _loadChain = _loadChain.then((_) => _loadForCode(normalized));
    return _loadChain;
  }

  Future<void> _loadForCode(String apiLocaleCode) async {
    try {
      final merged = await loadBootstrapForLocale(apiLocaleCode);
      if (merged.isEmpty) return;
      _strings = Map<String, String>.from(merged);
      _lastSyncedCode = apiLocaleCode;
    } catch (e, st) {
      debugPrint('UiI18n: failed to load assets/i18n: $e\n$st');
    }
    notifyListeners();
  }
}
