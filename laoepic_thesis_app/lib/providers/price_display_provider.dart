
import 'package:flutter/foundation.dart';
import 'package:laoepic_thesis_app/data/services/exchange_rates_api.dart';
import 'package:laoepic_thesis_app/shared/utils/money_format.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PriceDisplayMode { lak, usd, thb }

/// Mirrors web `price-display-context` + `exchangeRates.ts`.
class PriceDisplayProvider extends ChangeNotifier {
  static const _storageKey = 'lao-epic-price-display';

  PriceDisplayMode _mode = PriceDisplayMode.lak;
  List<ExchangeRate> _rates = [];
  bool _loadingRates = false;

  PriceDisplayMode get mode => _mode;
  List<ExchangeRate> get rates => _rates;
  bool get loadingRates => _loadingRates;
  /// Loads  and notifies listeners.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == 'usd') {
      _mode = PriceDisplayMode.usd;
    } else if (stored == 'thb') {
      _mode = PriceDisplayMode.thb;
    } else {
      _mode = PriceDisplayMode.lak;
    }
    await refreshRates();
    notifyListeners();
  }

  /// Refresh rates for this module.
  Future<void> refreshRates() async {
    _loadingRates = true;
    notifyListeners();
    try {
      _rates = await ExchangeRatesApi.fetchLatest();
      if (_mode == PriceDisplayMode.usd && !_hasRate('USD')) {
        _mode = PriceDisplayMode.lak;
      }
      if (_mode == PriceDisplayMode.thb && !_hasRate('THB')) {
        _mode = PriceDisplayMode.lak;
      }
    } finally {
      _loadingRates = false;
      notifyListeners();
    }
  }

  bool _hasRate(String code) =>
      _rates.any((r) => r.currencyCode == code.toUpperCase());

  ExchangeRate? _pick(String code) {
    final c = code.toUpperCase();
    for (final r in _rates) {
      if (r.currencyCode == c) return r;
    }
    return null;
  }

  /// Updates mode and persists when needed.
  Future<void> setMode(PriceDisplayMode next) async {
    if (next == PriceDisplayMode.usd && !_hasRate('USD')) return;
    if (next == PriceDisplayMode.thb && !_hasRate('THB')) return;
    _mode = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      next == PriceDisplayMode.usd
          ? 'usd'
          : next == PriceDisplayMode.thb
          ? 'thb'
          : 'lak',
    );
    notifyListeners();
  }

  /// Is mode available for this module.
  bool isModeAvailable(PriceDisplayMode m) {
    switch (m) {
      case PriceDisplayMode.lak:
        return true;
      case PriceDisplayMode.usd:
        return _hasRate('USD');
      case PriceDisplayMode.thb:
        return _hasRate('THB');
    }
  }

  /// Format amount for this module.
  String formatAmount(dynamic amount, {String? baseCurrency}) {
    final lak = _toLak(amount, baseCurrency);
    if (lak == null) return MoneyFormat.format(amount, currency: baseCurrency);

    switch (_mode) {
      case PriceDisplayMode.lak:
        return MoneyFormat.format(lak, currency: 'LAK');
      case PriceDisplayMode.usd:
        final rate = _pick('USD');
        if (rate == null) return MoneyFormat.format(lak, currency: 'LAK');
        final v = lak / rate.rateValue;
        return '≈ \$${MoneyFormat.formatAmount(v, maxFractionDigits: 2)}';
      case PriceDisplayMode.thb:
        final rate = _pick('THB');
        if (rate == null) return MoneyFormat.format(lak, currency: 'LAK');
        final v = lak / rate.rateValue;
        return '≈ ฿${MoneyFormat.formatAmount(v, maxFractionDigits: 0)}';
    }
  }

  num? _toLak(dynamic amount, String? baseCurrency) {
    final n = MoneyFormat.parse(amount);
    if (n == null) return null;
    final code = MoneyFormat.normalizeCurrency(baseCurrency);
    if (code == 'LAK') return n;
    final rate = _pick(code);
    if (rate == null) return n;
    return n * rate.rateValue;
  }
}
