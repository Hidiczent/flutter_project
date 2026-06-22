
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/shared/utils/open_filtered_packages.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_list_filters.dart';
import 'package:laoepic_thesis_app/data/models/package_village.dart';
import 'package:laoepic_thesis_app/data/services/catalog_api.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/utils/app_date_format.dart';
import 'package:provider/provider.dart';

/// Ranked list of top-rated tour packages fetched from the catalog API.
class HomeBestTopSection extends StatefulWidget {
  const HomeBestTopSection({super.key});

  @override
  State<HomeBestTopSection> createState() => _HomeBestTopSectionState();
}

class _HomeBestTopSectionState extends State<HomeBestTopSection> {
  List<PopularProvince> _provinces = [];
  List<TourSeasonItem> _seasons = [];
  List<PackageTypeItem> _types = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        CatalogApi.fetchPopularProvinces(limit: 3),
        CatalogApi.fetchTourSeasons(),
        CatalogApi.fetchPackageTypes(limit: 50),
      ]);
      if (!mounted) return;
      setState(() {
        _provinces = results[0] as List<PopularProvince>;
        _seasons = (results[1] as List<TourSeasonItem>).take(3).toList();
        _types = (results[2] as List<PackageTypeItem>).take(3).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _seasonDescription(TourSeasonItem s, String localeCode) {
    if (s.description != null && s.description!.trim().isNotEmpty) {
      return s.description!.trim();
    }
    try {
      final start = DateTime.parse(s.startDate);
      final end = DateTime.parse(s.endDate);
      return formatDateRangeLocalized(s.startDate, s.endDate, localeCode);
    } catch (_) {
      return '';
    }
  }

  void _openFilter(BuildContext context, PackageListFilters filters, String title) {
    openFilteredPackagesPage(
      context,
      initialFilters: filters,
      title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        _TopColumn(
          title: i18n.tr(I18nKey.homePopularProvince),
          icon: Icons.map_outlined,
          emptyText: i18n.tr(I18nKey.homeBestTopEmpty),
          items: _provinces
              .map(
                (p) => _RankItem(
                  title: p.name,
                  subtitle: i18n.tr(
                    I18nKey.homeBestTopPackageCount,
                    params: {'count': '${p.packageCount}'},
                  ),
                  imageUrl: p.imageUrl,
                  onTap: () => _openFilter(
                    context,
                    PackageListFilters(provinceId: p.provinceId),
                    p.name,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _TopColumn(
          title: i18n.tr(I18nKey.homePopularActivities),
          icon: Icons.local_activity_outlined,
          emptyText: i18n.tr(I18nKey.homeBestTopEmpty),
          items: _types
              .map(
                (t) => _RankItem(
                  title: t.typeName,
                  subtitle: i18n.tr(
                    I18nKey.homeBestTopPackageCount,
                    params: {'count': '${t.packageCount}'},
                  ),
                  imageUrl: t.imageUrl,
                  onTap: () => _openFilter(
                    context,
                    PackageListFilters(typeId: t.typeId),
                    t.typeName,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        _TopColumn(
          title: i18n.tr(I18nKey.homeBestTopSeasons),
          icon: Icons.calendar_month_outlined,
          emptyText: i18n.tr(I18nKey.homeBestTopEmpty),
          items: _seasons
              .map(
                (s) => _RankItem(
                  title: s.seasonName,
                  subtitle: _seasonDescription(
                    s,
                    context.read<ApiLocaleProvider>().code,
                  ),
                  imageUrl: s.imageUrl,
                  onTap: () => _openFilter(
                    context,
                    PackageListFilters(seasonId: s.seasonId),
                    s.seasonName,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RankItem {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  _RankItem({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.onTap,
  });
}

class _TopColumn extends StatelessWidget {
  final String title;
  final IconData icon;
  final String emptyText;
  final List<_RankItem> items;

  const _TopColumn({
    required this.title,
    required this.icon,
    required this.emptyText,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF2).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(emptyText, style: const TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...List.generate(items.length, (index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
                child: _RankCard(rank: index + 1, item: item),
              );
            }),
        ],
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  final int rank;
  final _RankItem item;

  const _RankCard({required this.rank, required this.item});

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      const Color(0xFFF59E0B),
      const Color(0xFF94A3B8),
      const Color(0xFFCD7F32),
    ];
    final rankColor = rankColors[(rank - 1).clamp(0, 2)];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (item.subtitle.isNotEmpty)
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Icon(Icons.image_outlined, color: AppColors.primary.withValues(alpha: 0.4)),
    );
  }
}
