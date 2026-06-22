
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

/// Highlights Lao Epic's mission and key selling points on the home screen.
class HomeAboutHighlightsSection extends StatelessWidget {
  const HomeAboutHighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          i18n.tr('home.why_title'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _HighlightCard(
                title: i18n.tr('about_page.pillar_sustainability_title'),
                desc: i18n.tr('about_page.pillar_sustainability_desc'),
                titleColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HighlightCard(
                title: i18n.tr('about_page.pillar_community_title'),
                desc: i18n.tr('about_page.pillar_community_desc'),
                titleColor: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _HighlightCard(
          title: i18n.tr('about_page.pillar_discover_title'),
          desc: i18n.tr('about_page.pillar_discover_desc'),
          titleColor: AppColors.accent,
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String desc;
  final Color titleColor;

  const _HighlightCard({
    required this.title,
    required this.desc,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EDF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

