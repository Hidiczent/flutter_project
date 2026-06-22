/// Package location and subtitle text for cards and detail screens.
library;

import 'package:laoepic_thesis_app/data/models/package_model.dart';

/// Supported UI locales for geo prefix labels (mirrors web `uiLocale.ts`).
enum UiLocale { lo, th, en }

/// Maps persisted/API locale code to [UiLocale].
UiLocale uiLocaleFromCode(String? code) {
  final c = (code ?? 'lo').toLowerCase();
  if (c.startsWith('th')) return UiLocale.th;
  if (c.startsWith('en')) return UiLocale.en;
  return UiLocale.lo;
}

class _GeoPrefixes {
  final String village;
  final String district;
  final String province;
  const _GeoPrefixes(this.village, this.district, this.province);
}

_GeoPrefixes _prefixes(UiLocale locale) {
  switch (locale) {
    case UiLocale.th:
      return const _GeoPrefixes('บ้าน', 'เมือง', 'แขวง');
    case UiLocale.en:
      return const _GeoPrefixes('Village', 'District', 'Province');
    case UiLocale.lo:
      return const _GeoPrefixes('ບ້ານ', 'ເມືອງ', 'ແຂວງ');
  }
}

/// Builds a localized village → district → province line from structured geo data.
String? structuredGeoLocation(PackageModel pkg, UiLocale locale) {
  final v = pkg.village;
  if (v == null) return null;
  final p = _prefixes(locale);
  final parts = <String>[
    if (v.name.trim().isNotEmpty) '${p.village} ${v.name.trim()}',
    if (v.district != null && v.district!.name.trim().isNotEmpty)
      '${p.district} ${v.district!.name.trim()}',
    if (v.province != null && v.province!.name.trim().isNotEmpty)
      '${p.province} ${v.province!.name.trim()}',
  ];
  if (parts.isEmpty) return null;
  return parts.join(', ');
}

/// Primary location string: structured geo, free-text location, or getting-there hint.
String getPackageDisplayLocation(PackageModel pkg, UiLocale locale) {
  final geo = structuredGeoLocation(pkg, locale);
  if (geo != null && geo.isNotEmpty) return geo;
  final loc = pkg.location?.trim();
  if (loc != null && loc.isNotEmpty) return loc;
  for (final item in pkg.gettingThere) {
    final t = item.trim();
    if (t.isNotEmpty) return t;
  }
  return '';
}

/// Secondary line for package cards (location, facility, or opening hours).
String getPackageCardSubtitle(PackageModel pkg, UiLocale locale) {
  final location = getPackageDisplayLocation(pkg, locale);
  if (location.isNotEmpty) return location;
  if (pkg.facilities.isNotEmpty && pkg.facilities.first.trim().isNotEmpty) {
    return pkg.facilities.first.trim();
  }
  if (pkg.openingHours.isNotEmpty && pkg.openingHours.first.trim().isNotEmpty) {
    return pkg.openingHours.first.trim();
  }
  return '';
}

/// Province name when the package is linked to Lao geo hierarchy.
String? getPackageProvinceName(PackageModel pkg) {
  return pkg.village?.province?.name.trim().isNotEmpty == true
      ? pkg.village!.province!.name.trim()
      : null;
}
