
import 'package:laoepic_thesis_app/config/app_config.dart';

/// Data model for geo place ref parsed from API JSON.
class GeoPlaceRef {
  final String id;
  final String name;

  const GeoPlaceRef({required this.id, required this.name});

  factory GeoPlaceRef.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GeoPlaceRef(id: '', name: '');
    return GeoPlaceRef(
      id: json['provinceId']?.toString() ??
          json['districtId']?.toString() ??
          json['villageId']?.toString() ??
          '',
      name: json['name']?.toString() ?? '',
    );
  }
}

/// Data model for package village parsed from API JSON.
class PackageVillage {
  final String villageId;
  final String name;
  final GeoPlaceRef? district;
  final GeoPlaceRef? province;

  const PackageVillage({
    required this.villageId,
    required this.name,
    this.district,
    this.province,
  });

  factory PackageVillage.fromJson(Map<String, dynamic> json) {
    final districtRaw = json['district'];
    GeoPlaceRef? district;
    GeoPlaceRef? province;
    if (districtRaw is Map<String, dynamic>) {
      district = GeoPlaceRef(
        id: districtRaw['districtId']?.toString() ?? '',
        name: districtRaw['name']?.toString() ?? '',
      );
      final provRaw = districtRaw['province'];
      if (provRaw is Map<String, dynamic>) {
        province = GeoPlaceRef(
          id: provRaw['provinceId']?.toString() ?? '',
          name: provRaw['name']?.toString() ?? '',
        );
      }
    }
    final provDirect = json['province'];
    if (province == null && provDirect is Map<String, dynamic>) {
      province = GeoPlaceRef.fromJson(provDirect);
    }

    return PackageVillage(
      villageId: json['villageId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      district: district,
      province: province,
    );
  }
}

/// Data model for popular province parsed from API JSON.
class PopularProvince {
  final String provinceId;
  final String name;
  final int packageCount;
  final String? imageUrl;

  const PopularProvince({
    required this.provinceId,
    required this.name,
    this.packageCount = 0,
    this.imageUrl,
  });

  factory PopularProvince.fromJson(Map<String, dynamic> json) {
    return PopularProvince(
      provinceId: json['provinceId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      packageCount:
          json['packageCount'] is int
              ? json['packageCount'] as int
              : int.tryParse(json['packageCount']?.toString() ?? '0') ?? 0,
      imageUrl: () {
        final u = json['imageUrl']?.toString().trim();
        if (u == null || u.isEmpty) return null;
        return AppConfig.mediaUrl(u);
      }(),
    );
  }
}

/// Data model for package type item parsed from API JSON.
class PackageTypeItem {
  final String typeId;
  final String typeName;
  final int packageCount;
  final String? imageUrl;

  const PackageTypeItem({
    required this.typeId,
    required this.typeName,
    this.packageCount = 0,
    this.imageUrl,
  });

  factory PackageTypeItem.fromJson(Map<String, dynamic> json) {
    return PackageTypeItem(
      typeId: json['typeId']?.toString() ?? '',
      typeName: json['typeName']?.toString() ?? '',
      packageCount:
          json['packageCount'] is int
              ? json['packageCount'] as int
              : int.tryParse(json['packageCount']?.toString() ?? '0') ?? 0,
      imageUrl: () {
        final u = json['imageUrl']?.toString().trim();
        if (u == null || u.isEmpty) return null;
        return AppConfig.mediaUrl(u);
      }(),
    );
  }
}

/// Data model for tour season item parsed from API JSON.
class TourSeasonItem {
  final String seasonId;
  final String seasonName;
  final String? description;
  final String startDate;
  final String endDate;
  final String status;
  final String? imageUrl;

  const TourSeasonItem({
    required this.seasonId,
    required this.seasonName,
    this.description,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
    this.imageUrl,
  });

  factory TourSeasonItem.fromJson(Map<String, dynamic> json) {
    return TourSeasonItem(
      seasonId: json['seasonId']?.toString() ?? '',
      seasonName: json['seasonName']?.toString() ?? '',
      description: json['description']?.toString(),
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      imageUrl: () {
        final u = json['imageUrl']?.toString().trim();
        if (u == null || u.isEmpty) return null;
        return AppConfig.mediaUrl(u);
      }(),
    );
  }
}
