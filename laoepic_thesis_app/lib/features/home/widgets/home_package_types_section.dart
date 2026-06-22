
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_list_filters.dart';
import 'package:laoepic_thesis_app/data/models/package_village.dart';
import 'package:laoepic_thesis_app/data/services/catalog_api.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/utils/open_filtered_packages.dart';
import 'package:provider/provider.dart';

/// Horizontal scroller of package type chips that deep-link into filtered package lists.
class HomePackageTypesSection extends StatefulWidget {
  final int limit;

  const HomePackageTypesSection({super.key, this.limit = 10});

  @override
  State<HomePackageTypesSection> createState() => _HomePackageTypesSectionState();
}

class _HomePackageTypesSectionState extends State<HomePackageTypesSection> {
  List<PackageTypeItem> _types = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await CatalogApi.fetchPackageTypes(limit: widget.limit);
      if (!mounted) return;
      setState(() {
        _types = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final types = _types;
    if (_loading) return const SizedBox.shrink();
    if (types.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          i18n.tr('home.package_types_title'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 156,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: types.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final t = types[i];
              return _TypeCard(
                title: t.typeName,
                count: t.packageCount,
                imageUrl: t.imageUrl ?? '',
                onTap: () => _openType(ctx, i18n, t),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openType(BuildContext context, UiI18n i18n, PackageTypeItem t) {
    openFilteredPackagesPage(
      context,
      initialFilters: PackageListFilters(typeId: t.typeId),
      title: t.typeName,
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final int count;
  final String imageUrl;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.count,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF111827),
          image: imageUrl.trim().isEmpty
              ? null
              : DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.45),
                    BlendMode.darken,
                  ),
                ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              title.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                height: 1.15,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Text(
                '$count ${count == 1 ? 'package' : 'packages'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

