
import 'dart:convert';

import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/providers/price_display_provider.dart';
import 'package:laoepic_thesis_app/data/models/package_village.dart';
import 'package:laoepic_thesis_app/shared/utils/money_format.dart';

/// Data model for package social link parsed from API JSON.
class PackageSocialLink {
  final String platform;
  final String url;

  const PackageSocialLink({required this.platform, required this.url});

  factory PackageSocialLink.fromJson(Map<String, dynamic> json) {
    return PackageSocialLink(
      platform: json['platform']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

/// Data model for package gallery item parsed from API JSON.
class PackageGalleryItem {
  final String imageId;
  final String imageUrl;
  final int sortOrder;

  const PackageGalleryItem({
    required this.imageId,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory PackageGalleryItem.fromJson(Map<String, dynamic> json) {
    return PackageGalleryItem(
      imageId: json['imageId']?.toString() ?? '',
      imageUrl: AppConfig.mediaUrl(json['imageUrl']?.toString() ?? ''),
      sortOrder:
          json['sortOrder'] is int
              ? json['sortOrder'] as int
              : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Data model for schedule price parsed from API JSON.
class SchedulePrice {
  final String schedulePriceId;
  final String priceType;
  final String currencyCode;
  final String amount;
  final String? effectiveAt;

  const SchedulePrice({
    required this.schedulePriceId,
    required this.priceType,
    required this.currencyCode,
    required this.amount,
    this.effectiveAt,
  });

  factory SchedulePrice.fromJson(Map<String, dynamic> json) {
    return SchedulePrice(
      schedulePriceId: json['schedulePriceId']?.toString() ?? '',
      priceType: json['priceType']?.toString() ?? '',
      currencyCode: json['currencyCode']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      effectiveAt: json['effectiveAt']?.toString(),
    );
  }
}

/// Data model for package schedule parsed from API JSON.
class PackageSchedule {
  final String scheduleId;
  final String packageId;
  final String? seasonId;
  final String? departureDatetime;
  final String? returnDatetime;
  final int capacity;
  final int bookedCount;
  final String status;
  final String? note;
  final List<SchedulePrice> prices;

  const PackageSchedule({
    required this.scheduleId,
    required this.packageId,
    this.seasonId,
    this.departureDatetime,
    this.returnDatetime,
    required this.capacity,
    required this.bookedCount,
    required this.status,
    this.note,
    required this.prices,
  });

  int get seatsLeft => (capacity - bookedCount).clamp(0, capacity);

  factory PackageSchedule.fromJson(Map<String, dynamic> json) {
    final rawPrices = json['prices'] as List<dynamic>? ?? [];
    return PackageSchedule(
      scheduleId: json['scheduleId']?.toString() ?? '',
      packageId: json['packageId']?.toString() ?? '',
      seasonId: json['seasonId']?.toString(),
      departureDatetime: json['departureDatetime']?.toString(),
      returnDatetime: json['returnDatetime']?.toString(),
      capacity:
          json['capacity'] is int
              ? json['capacity'] as int
              : int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
      bookedCount:
          json['bookedCount'] is int
              ? json['bookedCount'] as int
              : int.tryParse(
                    json['bookedCount']?.toString() ??
                        json['booked_count']?.toString() ??
                        '0',
                  ) ??
                  0,
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      prices:
          rawPrices
              .map(
                (e) => SchedulePrice.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList(),
    );
  }
}

/// Data model for package type info parsed from API JSON.
class PackageTypeInfo {
  final String typeId;
  final String typeName;
  final String status;

  const PackageTypeInfo({
    required this.typeId,
    required this.typeName,
    required this.status,
  });

  factory PackageTypeInfo.fromJson(Map<String, dynamic> json) {
    return PackageTypeInfo(
      typeId: json['typeId']?.toString() ?? '',
      typeName: json['typeName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

/// Data model for guide info parsed from API JSON.
class GuideInfo {
  final String guideId;
  final String fullName;
  final String? email;
  final String? phone;
  final String? languages;
  final String? bio;
  final String? avatarUrl;
  final String status;

  const GuideInfo({
    required this.guideId,
    required this.fullName,
    this.email,
    this.phone,
    this.languages,
    this.bio,
    this.avatarUrl,
    required this.status,
  });

  factory GuideInfo.fromJson(Map<String, dynamic> json) {
    return GuideInfo(
      guideId: json['guideId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      languages: json['languages']?.toString(),
      bio: json['bio']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}

/// Change-notifier (or state holder) for provider info in the Lao Epic app.
class ProviderInfo {
  final String providerId;
  final String providerName;
  final String? contactName;
  final String? email;
  final String? phone;
  final String status;

  const ProviderInfo({
    required this.providerId,
    required this.providerName,
    this.contactName,
    this.email,
    this.phone,
    required this.status,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      providerId: json['providerId']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      contactName: json['contactName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}

/// Mirrors Lao Epic `GET /api/packages` serialized package (list + detail).
class PackageModel {
  final int id;
  final String title;
  final String mainImageUrl;
  final String about;
  final String? location;
  final PackageVillage? village;
  final List<String> gettingThere;
  final List<String> activities;
  final List<String> fees;
  final List<String> facilities;
  final List<String> openingHours;
  final List<String> tipsForVisitors;
  final List<String> bringMustHave;
  final List<String> bringOptional;
  final List<PackageSocialLink> socialLinks;
  final String? resolvedLocale;
  final int? durationDays;
  final double priceInUsd;
  final String baseCurrency;
  final String status;
  final PackageTypeInfo? packageType;
  final GuideInfo? guide;
  final ProviderInfo? provider;
  final List<PackageGalleryItem> gallery;
  final List<PackageSchedule> schedules;

  PackageModel({
    required this.id,
    required this.title,
    required this.mainImageUrl,
    required this.about,
    this.location,
    this.village,
    this.gettingThere = const [],
    this.activities = const [],
    this.fees = const [],
    this.facilities = const [],
    this.openingHours = const [],
    this.tipsForVisitors = const [],
    this.bringMustHave = const [],
    this.bringOptional = const [],
    this.socialLinks = const [],
    this.resolvedLocale,
    this.durationDays,
    required this.priceInUsd,
    this.baseCurrency = 'LAK',
    this.status = 'active',
    this.packageType,
    this.guide,
    this.provider,
    this.gallery = const [],
    this.schedules = const [],
  });

  /// Back-compat: combined activities + fees (e.g. legacy cards).
  List<String> get tourInfo => [...activities, ...fees];

  List<String> get bring => [...bringMustHave, ...bringOptional];

  String get formattedPrice => MoneyFormat.format(
        priceInUsd,
        currency: baseCurrency,
      );

  /// Display price for this module.
  String displayPrice(PriceDisplayProvider pdp) =>
      pdp.formatAmount(priceInUsd, baseCurrency: baseCurrency);

  /// Cover first, then gallery (deduped), for banners / carousel.
  List<String> get bannerImageUrls {
    final out = <String>[];
    if (mainImageUrl.isNotEmpty) out.add(mainImageUrl);
    final sorted = List<PackageGalleryItem>.from(gallery)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (final g in sorted) {
      if (g.imageUrl.isNotEmpty && !out.contains(g.imageUrl)) {
        out.add(g.imageUrl);
      }
    }
    return out;
  }

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic raw) {
      try {
        if (raw is List) {
          return raw.map((e) => e.toString()).toList();
        } else if (raw is String) {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        }
      } catch (_) {}
      return [];
    }

    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    final packageId = json['packageId'] ?? json['package_id'];
    final basePriceRaw = json['basePrice'] ?? json['price_in_usd'];
    final basePrice =
        basePriceRaw is String
            ? double.tryParse(basePriceRaw) ?? 0.0
            : (basePriceRaw is num ? basePriceRaw.toDouble() : 0.0);

    final activities = parseList(json['activities']);
    final fees = parseList(json['fees']);
    final legacyTour = parseList(json['tour_info']);
    final mergedActivities =
        activities.isEmpty && fees.isEmpty && legacyTour.isNotEmpty
            ? legacyTour
            : activities;

    final bringMust = parseList(json['bringMustHave']);
    final bringOpt = parseList(json['bringOptional']);
    final legacyBring = parseList(json['bring']);
    final mergedMust =
        bringMust.isEmpty && legacyBring.isNotEmpty ? legacyBring : bringMust;

    final rawSocial = json['socialLinks'] as List<dynamic>? ?? [];
    final social =
        rawSocial
            .map((e) => PackageSocialLink.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((s) => s.platform.isNotEmpty && s.url.isNotEmpty)
            .toList();

    final rawGallery = json['gallery'] as List<dynamic>? ?? [];
    final galleryItems =
        rawGallery
            .map(
              (e) => PackageGalleryItem.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();

    final rawSchedules = json['schedules'] as List<dynamic>? ?? [];
    final scheduleItems =
        rawSchedules
            .map(
              (e) => PackageSchedule.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();

    PackageTypeInfo? pt;
    final ptRaw = json['packageType'];
    if (ptRaw is Map<String, dynamic>) {
      pt = PackageTypeInfo.fromJson(ptRaw);
    }

    GuideInfo? gd;
    final gdRaw = json['guide'];
    if (gdRaw is Map<String, dynamic>) {
      gd = GuideInfo.fromJson(gdRaw);
    }

    ProviderInfo? pv;
    final pvRaw = json['provider'];
    if (pvRaw is Map<String, dynamic>) {
      pv = ProviderInfo.fromJson(pvRaw);
    }

    final durationRaw = json['durationDays'];
    final durationDays =
        durationRaw == null
            ? null
            : durationRaw is int
            ? durationRaw
            : int.tryParse(durationRaw.toString());

    return PackageModel(
      id: parseId(packageId),
      title: json['title']?.toString() ?? '',
      about: json['description']?.toString() ?? json['about']?.toString() ?? '',
      location: () {
        final loc = json['location']?.toString().trim();
        if (loc == null || loc.isEmpty) return null;
        return loc;
      }(),
      village: () {
        final v = json['village'];
        if (v is Map<String, dynamic>) return PackageVillage.fromJson(v);
        return null;
      }(),
      gettingThere: parseList(json['gettingThere']),
      activities: mergedActivities,
      fees: fees,
      facilities: parseList(json['facilities']),
      openingHours: parseList(json['openingHours']),
      tipsForVisitors: parseList(json['tipsForVisitors']),
      bringMustHave: mergedMust,
      bringOptional: bringOpt,
      socialLinks: social,
      resolvedLocale: json['resolvedLocale']?.toString(),
      durationDays: durationDays,
      mainImageUrl: AppConfig.mediaUrl(
        json['coverImage']?.toString() ??
            json['main_image_url']?.toString() ??
            '',
      ),
      priceInUsd: basePrice,
      baseCurrency: MoneyFormat.normalizeCurrency(
        json['baseCurrency']?.toString(),
      ),
      status: json['status']?.toString() ?? 'active',
      packageType: pt,
      guide: gd,
      provider: pv,
      gallery: galleryItems,
      schedules: scheduleItems,
    );
  }
}
