
/// Data model for package list filters parsed from API JSON.
class PackageListFilters {
  final String? provinceId;
  final String? seasonId;
  final String? typeId;
  final String? location;
  final String? search;

  const PackageListFilters({
    this.provinceId,
    this.seasonId,
    this.typeId,
    this.location,
    this.search,
  });

  bool get hasServerFilter =>
      (provinceId != null && provinceId!.isNotEmpty) ||
      (seasonId != null && seasonId!.isNotEmpty) ||
      (typeId != null && typeId!.isNotEmpty) ||
      (location != null && location!.isNotEmpty) ||
      (search != null && search!.isNotEmpty);

  PackageListFilters copyWith({
    String? provinceId,
    String? seasonId,
    String? typeId,
    String? location,
    String? search,
    bool clearProvinceId = false,
    bool clearSeasonId = false,
    bool clearTypeId = false,
    bool clearLocation = false,
    bool clearSearch = false,
  }) {
    return PackageListFilters(
      provinceId: clearProvinceId ? null : (provinceId ?? this.provinceId),
      seasonId: clearSeasonId ? null : (seasonId ?? this.seasonId),
      typeId: clearTypeId ? null : (typeId ?? this.typeId),
      location: clearLocation ? null : (location ?? this.location),
      search: clearSearch ? null : (search ?? this.search),
    );
  }

  Map<String, String> toQueryParams({int page = 1, int limit = 50}) {
    final q = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (provinceId != null && provinceId!.isNotEmpty) {
      q['provinceId'] = provinceId!;
    }
    if (seasonId != null && seasonId!.isNotEmpty) q['seasonId'] = seasonId!;
    if (typeId != null && typeId!.isNotEmpty) q['typeId'] = typeId!;
    if (location != null && location!.isNotEmpty) q['location'] = location!;
    if (search != null && search!.isNotEmpty) q['search'] = search!;
    return q;
  }

  @override
  bool operator ==(Object other) =>
      other is PackageListFilters &&
      other.provinceId == provinceId &&
      other.seasonId == seasonId &&
      other.typeId == typeId &&
      other.location == location &&
      other.search == search;

  @override
  int get hashCode => Object.hash(provinceId, seasonId, typeId, location, search);
}
