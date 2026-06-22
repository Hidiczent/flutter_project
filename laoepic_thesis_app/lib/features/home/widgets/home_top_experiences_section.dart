
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/package/pages/package_detail_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/utils/package_display.dart';
import 'package:provider/provider.dart';

/// Curated experience rows highlighting popular destinations and activities.
class HomeTopExperiencesSection extends StatelessWidget {
  final List<PackageModel> packages;

  const HomeTopExperiencesSection({super.key, required this.packages});

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final locale = uiLocaleFromCode(context.read<ApiLocaleProvider>().code);
    final rows = packages.take(3).toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          i18n.tr(I18nKey.homeTopExperiencesTitle),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          i18n.tr(I18nKey.homeTopExperiencesSubtitle),
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < rows.length; i++) ...[
          _ExperienceRow(
            pkg: rows[i],
            imageOnRight: i.isEven,
            locale: locale,
            seeMore: i18n.tr(I18nKey.homeSeeMore),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _ExperienceRow extends StatelessWidget {
  final PackageModel pkg;
  final bool imageOnRight;
  final UiLocale locale;
  final String seeMore;

  const _ExperienceRow({
    required this.pkg,
    required this.imageOnRight,
    required this.locale,
    required this.seeMore,
  });

  @override
  Widget build(BuildContext context) {
    final loc = getPackageDisplayLocation(pkg, locale);
    final desc =
        pkg.about.trim().isNotEmpty
            ? pkg.about.trim()
            : (loc.isNotEmpty ? loc : '');

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child:
          pkg.mainImageUrl.isNotEmpty
              ? Image.network(
                pkg.mainImageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
              : _placeholder(),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pkg.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          height: 2,
          color: AppColors.accent,
        ),
        if (desc.isNotEmpty)
          Text(
            desc,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PackageDetailPage(packageId: pkg.id),
              ),
            ),
            child: Text(seeMore),
          ),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          imageOnRight
              ? [Expanded(child: text), const SizedBox(width: 12), Expanded(child: image)]
              : [Expanded(child: image), const SizedBox(width: 12), Expanded(child: text)],
    );
  }

  Widget _placeholder() {
    return Container(
      height: 160,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
    );
  }
}
